import 'dart:convert';
import 'dart:math';

import '../models.dart';
import 'gemini_service.dart';
import 'pdf_service.dart';

class GenResult {
  final List<Question> questions;
  final int requested;
  const GenResult(this.questions, this.requested);
}

typedef ProgressCallback = void Function(String phase, int done, int total);

class TestGenerator {
  static final Random _rnd = Random();

  /// [startPage] va [endPage] — 1 dan boshlanadigan sahifa raqamlari (ikkalasi ham kiradi).
  static Future<GenResult> generate({
    required Book book,
    required int count,
    required int startPage,
    required int endPage,
    required String apiKey,
    required String lang,
    required String? subjectName,
    required ProgressCallback onProgress,
    required bool Function() cancelled,
  }) async {
    onProgress('reading', 0, 1);
    final path = await resolveBookPath(book);

    final pagesInRange = endPage - startPage + 1;
    var wantWindows = (count / 8).ceil();
    if (wantWindows < 1) wantWindows = 1;
    if (wantWindows > 14) wantWindows = 14;
    if (wantWindows > pagesInRange) wantWindows = pagesInRange;
    if (wantWindows < 1) wantWindows = 1;

    final windows = await extractWindows(
      path,
      startPage: startPage - 1,
      endPage: endPage - 1,
      windows: wantWindows,
    );
    if (windows.isEmpty) throw PdfException('no_text');
    if (cancelled()) throw GeminiException('cancelled');

    var perBatch = (count / windows.length).ceil() + 2;
    if (perBatch > 25) perBatch = 25;

    final gemini = GeminiService(apiKey);
    final results = List<List<Question>?>.filled(windows.length, null);
    GeminiException? fatal;
    GeminiException? lastError;
    var next = 0;
    var done = 0;
    onProgress('generating', 0, windows.length);

    Future<void> worker() async {
      while (true) {
        if (cancelled()) return;
        final i = next++;
        if (i >= windows.length) return;
        try {
          results[i] = await _batch(gemini, windows[i], perBatch, lang, subjectName);
        } on GeminiException catch (e) {
          if (e.code == 'key' || e.code == 'region' || e.code == 'network') {
            fatal ??= e;
            next = windows.length; // qolganlarini to'xtatamiz
          } else {
            lastError = e;
          }
        }
        done++;
        onProgress('generating', done, windows.length);
      }
    }

    await Future.wait([for (var k = 0; k < 3; k++) worker()]);
    if (cancelled()) throw GeminiException('cancelled');

    // Har bir bo'lakdan navbat bilan savollarni olamiz (kitobning turli joylaridan aralash chiqadi).
    final lists = results.whereType<List<Question>>().toList();
    final seen = <String>{};
    final picked = <Question>[];
    var idx = 0;
    var any = true;
    while (picked.length < count && any) {
      any = false;
      for (final l in lists) {
        if (idx < l.length) {
          any = true;
          if (picked.length < count) {
            final q = l[idx];
            final key = q.text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
            if (seen.add(key)) picked.add(q);
          }
        }
      }
      idx++;
    }

    if (picked.isEmpty) {
      final err = fatal ?? lastError;
      if (err != null) throw err;
      throw GeminiException('bad_response');
    }
    picked.shuffle(_rnd);
    return GenResult(picked, count);
  }

  static Future<List<Question>> _batch(
    GeminiService gemini,
    PdfWindow w,
    int n,
    String lang,
    String? subject,
  ) async {
    final body = <String, dynamic>{
      'systemInstruction': {
        'parts': [
          {
            'text':
                'You are an experienced teacher who writes high-quality multiple-choice questions '
                    'for university entrance exams. You write accurate, unambiguous questions that '
                    'test real understanding of the source text.'
          }
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': _prompt(n, lang, subject, w)}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.5,
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'ARRAY',
          'items': {
            'type': 'OBJECT',
            'properties': {
              'question': {'type': 'STRING'},
              'options': {
                'type': 'ARRAY',
                'items': {'type': 'STRING'}
              },
              'answerIndex': {'type': 'INTEGER'},
              'explanation': {'type': 'STRING'},
            },
            'required': ['question', 'options', 'answerIndex', 'explanation'],
          },
        },
      },
    };

    GeminiException? lastBad;
    for (var attempt = 0; attempt < 2; attempt++) {
      final raw = await gemini.generateText(body);
      final qs = _parse(raw);
      if (qs.isNotEmpty) return qs;
      lastBad = GeminiException('bad_response');
    }
    throw lastBad ?? GeminiException('bad_response');
  }

  static String _langName(String lang) {
    switch (lang) {
      case 'ru':
        return 'Russian';
      case 'kk':
        return 'Karakalpak (Latin alphabet)';
      default:
        return 'Uzbek (Latin alphabet)';
    }
  }

  static String _prompt(int n, String lang, String? subject, PdfWindow w) {
    final subj = subject ?? 'not specified';
    final b = StringBuffer();
    b.writeln('Subject: $subj');
    b.writeln('Language for questions, options and explanations: ${_langName(lang)}');
    b.writeln('Number of questions to write: $n');
    b.writeln();
    b.writeln('Rules:');
    b.writeln('- Base every question ONLY on the SOURCE TEXT below. Do not add outside facts.');
    b.writeln('- Write $n different questions that cover different parts of the text. Mix easy, medium and hard.');
    b.writeln('- Each question has exactly 4 answer options and exactly one correct option. Wrong options must be plausible. Do not use "all of the above" or "none of the above".');
    b.writeln('- Questions must be self-contained: never write "according to the text/passage/book/author", and never refer to page numbers, figures, tables or exercises.');
    b.writeln('- For math, physics and chemistry prefer calculation or application questions when the text contains formulas or worked examples. Write formulas in plain text (for example x^2, H2O, v = s/t).');
    b.writeln('- Skip table of contents, headings only, copyright and publisher notes.');
    b.writeln('- "explanation": 1-2 short sentences saying why the correct option is right.');
    b.writeln('- "answerIndex": index (0-3) of the correct option in "options".');
    b.writeln('- Do not put letters or numbers like "A)" or "1." before the options.');
    b.writeln();
    b.writeln('---SOURCE TEXT (pages ${w.firstPage}-${w.lastPage})---');
    b.writeln(w.text);
    b.writeln('---END OF SOURCE TEXT---');
    return b.toString();
  }

  static List<Question> _parse(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return [];
    if (s.startsWith('```')) {
      s = s.replaceFirst(RegExp(r'^```[a-zA-Z]*\s*'), '');
      s = s.replaceFirst(RegExp(r'\s*```$'), '');
    }
    dynamic data;
    try {
      data = jsonDecode(s);
    } catch (_) {
      return [];
    }
    List<dynamic>? items;
    if (data is List) {
      items = data;
    } else if (data is Map && data['questions'] is List) {
      items = data['questions'] as List;
    }
    if (items == null) return [];

    final out = <Question>[];
    for (final it in items) {
      if (it is! Map) continue;
      final qText = (it['question'] ?? '').toString().trim();
      final optsRaw = it['options'];
      if (qText.isEmpty || optsRaw is! List || optsRaw.length < 4) continue;

      final opts = optsRaw
          .take(4)
          .map((o) => o
              .toString()
              .replaceFirst(RegExp(r'^\s*(?:[A-Da-d]|[1-4])[\)\.\:]\s+'), '')
              .trim())
          .toList();
      if (opts.any((o) => o.isEmpty)) continue;
      if (opts.toSet().length != opts.length) continue;

      final ansRaw = it['answerIndex'];
      int? ans;
      if (ansRaw is int) {
        ans = ansRaw;
      } else if (ansRaw is num) {
        ans = ansRaw.toInt();
      } else if (ansRaw is String) {
        ans = int.tryParse(ansRaw.trim());
      }
      if (ans == null || ans < 0 || ans > 3) continue;

      // Variantlar tartibini aralashtiramiz (model javobni ko'pincha bir xil joyga qo'yadi).
      final order = List<int>.generate(4, (i) => i)..shuffle(_rnd);
      final shuffled = [for (final i in order) opts[i]];
      final newAns = order.indexOf(ans);

      out.add(Question(
        text: qText,
        options: shuffled,
        answer: newAns,
        explanation: (it['explanation'] ?? '').toString().trim(),
      ));
    }
    return out;
  }
}
