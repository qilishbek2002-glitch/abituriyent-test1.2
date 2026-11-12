import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/test_generator.dart';
import '../ui.dart';
import 'test_screen.dart';

class GeneratingScreen extends StatefulWidget {
  final Book book;
  final int count;
  final int startPage;
  final int endPage;
  const GeneratingScreen({
    super.key,
    required this.book,
    required this.count,
    required this.startPage,
    required this.endPage,
  });

  @override
  State<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends State<GeneratingScreen> {
  String _phase = 'reading';
  int _done = 0;
  int _total = 1;
  Object? _error;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void dispose() {
    _cancelled = true;
    super.dispose();
  }

  Future<void> _run() async {
    try {
      final res = await TestGenerator.generate(
        book: widget.book,
        count: widget.count,
        startPage: widget.startPage,
        endPage: widget.endPage,
        apiKey: app.apiKey,
        lang: app.lang,
        subjectName:
            widget.book.subjectId == null ? null : subjectName(widget.book.subjectId!),
        onProgress: (phase, done, total) {
          if (!mounted || _cancelled) return;
          setState(() {
            _phase = phase;
            _done = done;
            _total = total;
          });
        },
        cancelled: () => _cancelled,
      );
      if (_cancelled || !mounted) return;

      await app.consumeTrial();
      final test = SavedTest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: widget.book.title,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        questions: res.questions,
      );
      await app.addTest(test);
      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      if (res.questions.length < widget.count) {
        messenger.showSnackBar(SnackBar(
          content: Text(tr('partial', {
            'n': res.questions.length.toString(),
            'm': widget.count.toString(),
          })),
        ));
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TestScreen(
            questions: test.questions,
            title: test.title,
            testId: test.id,
          ),
        ),
      );
    } catch (e) {
      if (!mounted || _cancelled) return;
      setState(() => _error = e);
    }
  }

  void _retry() {
    setState(() {
      _error = null;
      _phase = 'reading';
      _done = 0;
      _total = 1;
    });
    _run();
  }

  @override
  Widget build(BuildContext context) {
    final err = _error;
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: err != null ? _errorView(err) : _progressView(),
          ),
        ),
      ),
    );
  }

  Widget _progressView() {
    final reading = _phase == 'reading';
    final value = reading ? null : (_total == 0 ? 0.0 : _done / _total);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.auto_awesome, size: 64, color: Color(0xFF3F51B5)),
        const SizedBox(height: 24),
        Text(
          reading
              ? tr('reading_pdf')
              : tr('generating', {
                  'done': _done.toString(),
                  'total': _total.toString(),
                }),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: value, minHeight: 8),
        const SizedBox(height: 16),
        Text(tr('generating_hint'), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _errorView(Object err) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(tr('error_title'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(errorText(err), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton(onPressed: _retry, child: Text(tr('retry'))),
      ],
    );
  }
}
