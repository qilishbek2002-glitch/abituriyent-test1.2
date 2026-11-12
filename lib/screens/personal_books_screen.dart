import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../models.dart';
import '../pick_pdf.dart';
import '../ui.dart';
import 'test_setup_screen.dart';

class PersonalBooksScreen extends StatefulWidget {
  const PersonalBooksScreen({super.key});

  @override
  State<PersonalBooksScreen> createState() => _PersonalBooksScreenState();
}

class _PersonalBooksScreenState extends State<PersonalBooksScreen> {
  bool _busy = false;

  Future<void> _pick() async {
    setState(() => _busy = true);
    await pickAndAddPdf(context);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _remove(PersonalBook b) async {
    final ok = await confirmDialog(context, tr('delete_book_q'));
    if (ok) await app.removePersonalBook(b.id);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final books = app.userBooks(null, null);
        return Scaffold(
          appBar: AppBar(title: Text(tr('my_books'))),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _busy ? null : _pick,
            icon: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            label: Text(tr('add_pdf')),
          ),
          body: SafeArea(
            child: books.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        tr('personal_empty'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final pb = books[i];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.picture_as_pdf),
                          title: Text(pb.title),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _remove(pb),
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TestSetupScreen(
                                book: Book(
                                  id: pb.id,
                                  title: pb.title,
                                  filePath: pb.path,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
