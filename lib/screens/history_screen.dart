import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../models.dart';
import '../ui.dart';
import 'test_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final tests = app.tests;
        return Scaffold(
          appBar: AppBar(title: Text(tr('history'))),
          body: SafeArea(
            child: tests.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        tr('history_empty'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: tests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final t = tests[i];
                      final parts = <String>[
                        formatDate(t.createdAt),
                        tr('questions_short', {'n': '${t.questions.length}'}),
                        if (t.attempts > 0)
                          tr('best_result', {'p': '${t.bestPercent}'}),
                      ];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.quiz),
                          title: Text(t.title,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text(parts.join(' • ')),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _remove(context, t),
                          ),
                          onTap: () => _open(context, t),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  void _open(BuildContext context, SavedTest t) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TestScreen(
          questions: List<Question>.of(t.questions)..shuffle(),
          title: t.title,
          testId: t.id,
        ),
      ),
    );
  }

  Future<void> _remove(BuildContext context, SavedTest t) async {
    final ok = await confirmDialog(context, tr('delete_test_q'));
    if (ok) await app.deleteTest(t.id);
  }
}
