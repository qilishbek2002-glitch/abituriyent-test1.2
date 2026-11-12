import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../models.dart';
import '../services/pdf_service.dart';
import '../ui.dart';
import 'api_key_screen.dart';
import 'generating_screen.dart';
import 'paywall_screen.dart';

class TestSetupScreen extends StatefulWidget {
  final Book book;
  const TestSetupScreen({super.key, required this.book});

  @override
  State<TestSetupScreen> createState() => _TestSetupScreenState();
}

class _TestSetupScreenState extends State<TestSetupScreen> {
  int? _pages; // null: yuklanmoqda, -1: ochilmadi
  int _count = 30;
  RangeValues _range = const RangeValues(1, 1);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    int n;
    try {
      final path = await resolveBookPath(widget.book);
      n = await pdfPageCount(path);
    } catch (_) {
      n = -1;
    }
    if (!mounted) return;
    setState(() {
      _pages = n;
      if (n > 0) _range = RangeValues(1, n.toDouble());
    });
  }

  void _start() {
    if (!app.canGenerate) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      return;
    }
    if (app.apiKey.isEmpty) {
      showSnack(context, tr('need_key_banner'));
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ApiKeyScreen()),
      );
      return;
    }
    final s = _range.start.round();
    final e = _range.end.round();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GeneratingScreen(
          book: widget.book,
          count: _count,
          startPage: s,
          endPage: e,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    return Scaffold(
      appBar: AppBar(title: Text(tr('make_test'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, size: 36),
                title: Text(widget.book.title),
                subtitle: pages == null
                    ? const LinearProgressIndicator()
                    : (pages > 0
                        ? Text(tr('pages_total', {'n': pages.toString()}))
                        : Text(tr('err_pdf_open'),
                            style: const TextStyle(color: Colors.red))),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tr('questions_count'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final c in const [10, 30, 50, 100])
                  ChoiceChip(
                    label: Text('$c'),
                    selected: _count == c,
                    onSelected: (_) => setState(() => _count = c),
                  ),
              ],
            ),
            if (pages != null && pages > 1) ...[
              const SizedBox(height: 24),
              Text(
                tr('page_range', {
                  'a': _range.start.round().toString(),
                  'b': _range.end.round().toString(),
                }),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(tr('page_range_hint'),
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
              RangeSlider(
                values: _range,
                min: 1,
                max: pages.toDouble(),
                divisions: pages - 1,
                labels: RangeLabels(
                  _range.start.round().toString(),
                  _range.end.round().toString(),
                ),
                onChanged: (v) => setState(() {
                  _range = RangeValues(
                    v.start.roundToDouble(),
                    v.end.roundToDouble(),
                  );
                }),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
              onPressed: (pages != null && pages > 0) ? _start : null,
              icon: const Icon(Icons.auto_awesome),
              label: Text(tr('make_test'), style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
