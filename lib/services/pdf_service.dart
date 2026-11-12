import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../models.dart';

class PdfException implements Exception {
  /// 'open' yoki 'no_text'
  final String code;
  PdfException(this.code);
  @override
  String toString() => 'PdfException($code)';
}

/// Kitobdan ajratib olingan matn bo'lagi.
class PdfWindow {
  final String text;
  final int firstPage; // 1 dan boshlanadi
  final int lastPage;
  const PdfWindow(this.text, this.firstPage, this.lastPage);
}

/// Kitob faylining yo'lini qaytaradi (ilova ichidagi kitob vaqtincha papkaga ko'chiriladi).
Future<String> resolveBookPath(Book b) async {
  if (b.filePath != null) return b.filePath!;
  final assetPath = b.assetPath!;
  final dir = await getTemporaryDirectory();
  final safe = assetPath.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  final f = File('${dir.path}/$safe');
  if (!await f.exists() || await f.length() == 0) {
    final data = await rootBundle.load(assetPath);
    await f.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
  }
  return f.path;
}

/// Sahifalar soni; ochib bo'lmasa -1.
Future<int> pdfPageCount(String path) async {
  try {
    return await compute(_pageCountIsolate, path);
  } catch (_) {
    return -1;
  }
}

int _pageCountIsolate(String path) {
  try {
    final bytes = File(path).readAsBytesSync();
    final doc = PdfDocument(inputBytes: bytes);
    final n = doc.pages.count;
    doc.dispose();
    return n;
  } catch (_) {
    return -1;
  }
}

/// [startPage]..[endPage] (0 dan boshlanadigan, ikkalasi ham kiradi) oralig'idan
/// teng taqsimlangan [windows] ta matn bo'lagini ajratadi.
Future<List<PdfWindow>> extractWindows(
  String path, {
  required int startPage,
  required int endPage,
  required int windows,
  int cap = 12000,
}) async {
  List<Map<String, dynamic>>? raw;
  try {
    raw = await compute(_extractIsolate, <String, dynamic>{
      'path': path,
      'start': startPage,
      'end': endPage,
      'windows': windows,
      'cap': cap,
    });
  } catch (_) {
    raw = null;
  }
  if (raw == null) throw PdfException('open');
  return [
    for (final m in raw)
      PdfWindow(m['text'] as String, m['first'] as int, m['last'] as int)
  ];
}

List<Map<String, dynamic>> _extractIsolate(Map<String, dynamic> a) {
  final String path = a['path'] as String;
  final int start = a['start'] as int;
  final int end = a['end'] as int;
  final int windows = a['windows'] as int;
  final int cap = a['cap'] as int;

  final bytes = File(path).readAsBytesSync();
  final doc = PdfDocument(inputBytes: bytes);
  final out = <Map<String, dynamic>>[];
  try {
    final total = doc.pages.count;
    final s = math.max(0, math.min(start, total - 1));
    final e = math.max(s, math.min(end, total - 1));
    final n = e - s + 1;
    final extractor = PdfTextExtractor(doc);

    for (var i = 0; i < windows; i++) {
      final ws = s + (i * n) ~/ windows;
      final we = s + ((i + 1) * n) ~/ windows - 1;
      if (we < ws) continue;

      final buf = StringBuffer();
      var first = -1;
      var last = -1;
      var len = 0;
      for (var p = ws; p <= we && len < cap; p++) {
        var t = '';
        try {
          t = extractor.extractText(startPageIndex: p, endPageIndex: p);
        } catch (_) {
          t = '';
        }
        t = _clean(t);
        if (t.length < 40) continue;
        if (first < 0) first = p;
        last = p;
        buf.write(t);
        buf.write('\n');
        len += t.length + 1;
      }
      var text = buf.toString().trim();
      if (text.length > cap) text = text.substring(0, cap);
      if (text.length >= 200) {
        out.add({'text': text, 'first': first + 1, 'last': last + 1});
      }
    }
  } finally {
    doc.dispose();
  }
  return out;
}

String _clean(String t) {
  return t
      .replaceAll('\u0000', '')
      .replaceAll('­', '')
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\s*\n\s*'), '\n')
      .trim();
}
