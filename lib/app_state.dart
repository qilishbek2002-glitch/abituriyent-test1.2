import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'activation.dart';
import 'config.dart';
import 'l10n.dart';
import 'models.dart';

enum ActivateResult { ok, bad, wrongDevice, used }

/// Butun ilova holati (til, kalit, obuna, kitoblar, testlar).
final AppState app = AppState();

String subjectName(String id) => tr('subject_$id');

class AppState extends ChangeNotifier {
  late SharedPreferences _p;

  String lang = 'uz';
  bool langChosen = false;
  String apiKey = '';
  String deviceId = '';
  int expiresAt = 0;
  int lastSeen = 0;
  int trialLeft = kFreeTests;
  int lastActivatedDays = 0;
  Set<String> usedCodes = <String>{};
  List<PersonalBook> personalBooks = [];
  List<SavedTest> tests = [];
  Map<String, String> subjectImages = {};
  List<String> pdfAssets = [];

  Future<void> init() async {
    _p = await SharedPreferences.getInstance();

    final savedLang = _p.getString('lang');
    langChosen = savedLang != null;
    lang = savedLang ?? 'uz';
    currentLang = lang;

    apiKey = _p.getString('apiKey') ?? '';
    deviceId = _p.getString('deviceId') ?? '';
    if (deviceId.isEmpty) {
      deviceId = _newDeviceId();
      await _p.setString('deviceId', deviceId);
    }
    expiresAt = _p.getInt('expiresAt') ?? 0;
    lastSeen = _p.getInt('lastSeen') ?? 0;
    trialLeft = _p.getInt('trialLeft') ?? kFreeTests;
    usedCodes = (_p.getStringList('usedCodes') ?? <String>[]).toSet();

    try {
      final raw = _p.getString('personal');
      if (raw != null) {
        personalBooks = (jsonDecode(raw) as List)
            .map((e) => PersonalBook.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {
      personalBooks = [];
    }

    await _touch();

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final all = manifest.listAssets();
      pdfAssets = all
          .where((a) =>
              a.startsWith('assets/books/') && a.toLowerCase().endsWith('.pdf'))
          .toList()
        ..sort();
      final ids = <String>[...kSubjects.map((s) => s.id), 'personal'];
      for (final id in ids) {
        for (final ext in const ['png', 'jpg', 'jpeg', 'webp']) {
          final path = 'assets/subjects/$id.$ext';
          if (all.contains(path)) {
            subjectImages[id] = path;
            break;
          }
        }
      }
    } catch (_) {}

    await _loadTests();
  }

  // ---------------- vaqt va obuna ----------------

  Future<void> _touch() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now > lastSeen) {
      lastSeen = now;
      await _p.setInt('lastSeen', now);
    }
  }

  /// Soatni orqaga surib aldashni oldini olish uchun: eng so'nggi ko'rilgan vaqtdan kichik bo'lmaydi.
  int get nowMs => max(DateTime.now().millisecondsSinceEpoch, lastSeen);

  bool get subscribed => expiresAt > nowMs;

  int get daysLeft {
    final d = ((expiresAt - nowMs) / 86400000).ceil();
    return d < 0 ? 0 : d;
  }

  bool get canGenerate => !kSubscriptionRequired || subscribed || trialLeft > 0;

  Future<ActivateResult> activate(String raw) async {
    await _touch();
    final r = parseCode(raw, deviceId);
    if (r.status == CodeStatus.badFormat || r.status == CodeStatus.badSignature) {
      return ActivateResult.bad;
    }
    if (r.status == CodeStatus.wrongDevice) return ActivateResult.wrongDevice;
    if (usedCodes.contains(r.key)) return ActivateResult.used;

    final base = max(nowMs, expiresAt);
    expiresAt = base + r.days * 86400000;
    usedCodes.add(r.key);
    lastActivatedDays = r.days;
    await _p.setInt('expiresAt', expiresAt);
    await _p.setStringList('usedCodes', usedCodes.toList());
    notifyListeners();
    return ActivateResult.ok;
  }

  Future<void> consumeTrial() async {
    if (!subscribed && trialLeft > 0) {
      trialLeft -= 1;
      await _p.setInt('trialLeft', trialLeft);
      notifyListeners();
    }
  }

  // ---------------- til va kalit ----------------

  Future<void> setLang(String l) async {
    lang = l;
    langChosen = true;
    currentLang = l;
    await _p.setString('lang', l);
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    apiKey = key;
    await _p.setString('apiKey', key);
    notifyListeners();
  }

  // ---------------- kitoblar ----------------

  List<Book> assetBooks(String subjectId, String kind) {
    final prefix = 'assets/books/$subjectId/$kind/';
    return pdfAssets
        .where((a) => a.startsWith(prefix))
        .map((a) => Book(
              id: a,
              title: _titleFromPath(a),
              assetPath: a,
              subjectId: subjectId,
            ))
        .toList();
  }

  int assetBookCount(String subjectId, String kind) =>
      assetBooks(subjectId, kind).length;

  String _titleFromPath(String p) {
    var name = p.split('/').last;
    try {
      name = Uri.decodeComponent(name);
    } catch (_) {}
    if (name.toLowerCase().endsWith('.pdf')) {
      name = name.substring(0, name.length - 4);
    }
    return name.replaceAll('_', ' ').trim();
  }

  /// Foydalanuvchi qo'shgan kitoblar: [subjectId] null = "Shaxsiy kitob" bo'limi.
  List<PersonalBook> userBooks(String? subjectId, String? kind) {
    return personalBooks
        .where((b) =>
            b.subjectId == subjectId && (subjectId == null || b.kind == kind))
        .toList();
  }

  int bookCount(String subjectId, String kind) =>
      assetBookCount(subjectId, kind) + userBooks(subjectId, kind).length;

  Future<void> addPersonalBook(XFile file,
      {String? subjectId, String? kind}) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/personal');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final dest = '${folder.path}/$id.pdf';
    final bytes = await file.readAsBytes();
    await File(dest).writeAsBytes(bytes, flush: true);

    var title = file.name;
    if (title.toLowerCase().endsWith('.pdf')) {
      title = title.substring(0, title.length - 4);
    }
    if (title.trim().isEmpty) title = 'PDF';
    personalBooks = [
      PersonalBook(
        id: id,
        title: title,
        path: dest,
        subjectId: subjectId,
        kind: kind,
      ),
      ...personalBooks,
    ];
    await _savePersonal();
    notifyListeners();
  }

  Future<void> removePersonalBook(String id) async {
    final matches = personalBooks.where((b) => b.id == id).toList();
    for (final b in matches) {
      try {
        final f = File(b.path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    personalBooks = personalBooks.where((b) => b.id != id).toList();
    await _savePersonal();
    notifyListeners();
  }

  Future<void> _savePersonal() async {
    await _p.setString(
        'personal', jsonEncode(personalBooks.map((b) => b.toJson()).toList()));
  }

  // ---------------- saqlangan testlar ----------------

  Future<File> _testsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tests.json');
  }

  Future<void> _loadTests() async {
    try {
      final f = await _testsFile();
      if (await f.exists()) {
        final raw = await f.readAsString();
        tests = (jsonDecode(raw) as List)
            .map((e) => SavedTest.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {
      tests = [];
    }
  }

  Future<void> _saveTests() async {
    try {
      final f = await _testsFile();
      await f.writeAsString(jsonEncode(tests.map((t) => t.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> addTest(SavedTest t) async {
    tests = [t, ...tests];
    if (tests.length > 40) tests = tests.sublist(0, 40);
    await _saveTests();
    notifyListeners();
  }

  Future<void> deleteTest(String id) async {
    tests = tests.where((t) => t.id != id).toList();
    await _saveTests();
    notifyListeners();
  }

  Future<void> recordResult(String id, int percent) async {
    for (final t in tests) {
      if (t.id == id) {
        t.attempts += 1;
        if (percent > t.bestPercent) t.bestPercent = percent;
      }
    }
    await _saveTests();
    notifyListeners();
  }

  String _newDeviceId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
  }
}
