import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../models.dart';
import '../ui.dart';

class TestScreen extends StatefulWidget {
  final List<Question> questions;
  final String title;

  /// Natijani tarixga yozish uchun (null bo'lsa yozilmaydi, masalan "xatolarni qayta yechish").
  final String? testId;
  const TestScreen({
    super.key,
    required this.questions,
    required this.title,
    this.testId,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _i = 0;
  int? _sel;
  late final List<int?> _answers;

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.questions.length, null);
  }

  void _pick(int idx) {
    if (_sel != null) return;
    setState(() {
      _sel = idx;
      _answers[_i] = idx;
    });
  }

  Future<void> _next() async {
    final n = widget.questions.length;
    if (_i + 1 < n) {
      setState(() {
        _i += 1;
        _sel = null;
      });
      return;
    }
    var correct = 0;
    for (var k = 0; k < n; k++) {
      if (_answers[k] == widget.questions[k].answer) correct++;
    }
    final percent = n == 0 ? 0 : (correct * 100 / n).round();
    final id = widget.testId;
    if (id != null) await app.recordResult(id, percent);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          questions: widget.questions,
          answers: List<int?>.from(_answers),
          title: widget.title,
          testId: widget.testId,
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    final ok = await confirmDialog(context, tr('exit_test_q'));
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[_i];
    final n = widget.questions.length;
    final answered = _sel != null;
    final isLast = _i + 1 == n;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('question_of', {'i': '${_i + 1}', 'n': '$n'})),
        ),
        body: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(value: (_i + (answered ? 1 : 0)) / n),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(q.text,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              height: 1.35)),
                      const SizedBox(height: 16),
                      for (var k = 0; k < q.options.length; k++) _option(k, q),
                      if (answered) _feedback(q),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: answered ? _next : null,
                  child: Text(isLast ? tr('finish') : tr('next'),
                      style: const TextStyle(fontSize: 17)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(int idx, Question q) {
    final answered = _sel != null;
    final isCorrect = idx == q.answer;
    final isSel = _sel == idx;
    final scheme = Theme.of(context).colorScheme;

    Color bg = scheme.surface;
    Color border = scheme.outlineVariant;
    if (answered) {
      if (isCorrect) {
        bg = Colors.green.withAlpha(40);
        border = Colors.green;
      } else if (isSel) {
        bg = Colors.red.withAlpha(40);
        border = Colors.red;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _pick(idx),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text(String.fromCharCode(65 + idx),
                      style: const TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(q.options[idx],
                      style: const TextStyle(fontSize: 16, height: 1.3)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _feedback(Question q) {
    final ok = _sel == q.answer;
    final letter = String.fromCharCode(65 + q.answer);
    return Card(
      color: ok ? Colors.green.withAlpha(30) : Colors.red.withAlpha(25),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ok ? tr('correct') : tr('wrong', {'a': letter}),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ok ? Colors.green.shade800 : Colors.red.shade800,
              ),
            ),
            if (q.explanation.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('${tr('explanation')}: ${q.explanation}'),
            ],
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final List<Question> questions;
  final List<int?> answers;
  final String title;
  final String? testId;
  const ResultScreen({
    super.key,
    required this.questions,
    required this.answers,
    required this.title,
    this.testId,
  });

  @override
  Widget build(BuildContext context) {
    final n = questions.length;
    final wrong = <int>[
      for (var i = 0; i < n; i++)
        if (answers[i] != questions[i].answer) i
    ];
    final correct = n - wrong.length;
    final pct = n == 0 ? 0 : (correct * 100 / n).round();
    final color = pct >= 70
        ? Colors.green
        : (pct >= 40 ? Colors.orange : Colors.red);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('result_title')),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: pct / 100,
                      strokeWidth: 12,
                      color: color,
                      backgroundColor: color.withAlpha(40),
                    ),
                    Center(
                      child: Text('$pct%',
                          style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: color)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tr('result_score', {'c': '$correct', 'n': '$n'}),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (wrong.isNotEmpty)
              FilledButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => TestScreen(
                      questions: [for (final i in wrong) questions[i]],
                      title: title,
                    ),
                  ),
                ),
                child: Text(tr('retry_mistakes')),
              ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => TestScreen(
                    questions: List<Question>.of(questions)..shuffle(),
                    title: title,
                    testId: testId,
                  ),
                ),
              ),
              child: Text(tr('retry_all')),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: Text(tr('home')),
            ),
            const SizedBox(height: 12),
            Text(
              wrong.isEmpty ? tr('no_mistakes') : tr('mistakes'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final i in wrong) _mistake(i),
          ],
        ),
      ),
    );
  }

  Widget _mistake(int i) {
    final q = questions[i];
    final mine = answers[i];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${i + 1}. ${q.text}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (mine != null)
              Text(
                '${tr('your_answer')}: ${q.options[mine]}',
                style: TextStyle(color: Colors.red.shade800),
              ),
            Text(
              '${tr('right_answer')}: ${q.options[q.answer]}',
              style: TextStyle(
                  color: Colors.green.shade800, fontWeight: FontWeight.w600),
            ),
            if (q.explanation.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('${tr('explanation')}: ${q.explanation}'),
            ],
          ],
        ),
      ),
    );
  }
}
