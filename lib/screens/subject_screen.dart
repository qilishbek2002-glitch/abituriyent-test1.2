import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';
import '../models.dart';
import '../pick_pdf.dart';
import '../ui.dart';
import 'test_setup_screen.dart';

class SubjectScreen extends StatelessWidget {
  final Subject subject;
  const SubjectScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(subjectName(subject.id))),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card(context, tr('ready_materials'), Icons.fact_check,
                    'materials'),
                const SizedBox(height: 12),
                _card(context, tr('textbooks'), Icons.menu_book, 'textbooks'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _card(BuildContext context, String title, IconData icon, String kind) {
    final count = app.bookCount(subject.id, kind);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BookListScreen(
              subject: subject,
              kind: kind,
              title: title,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: subject.color.withAlpha(40),
                child: Icon(icon, size: 32, color: subject.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(tr('books_count', {'n': count.toString()})),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class BookListScreen extends StatefulWidget {
  final Subject subject;
  final String kind;
  final String title;
  const BookListScreen({
    super.key,
    required this.subject,
    required this.kind,
    required this.title,
  });

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  bool _busy = false;

  Future<void> _add() async {
    setState(() => _busy = true);
    await pickAndAddPdf(
      context,
      subjectId: widget.subject.id,
      kind: widget.kind,
    );
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _remove(PersonalBook b) async {
    final ok = await confirmDialog(context, tr('delete_book_q'));
    if (ok) await app.removePersonalBook(b.id);
  }

  void _open(Book b) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TestSetupScreen(book: b)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final assets = app.assetBooks(subject.id, widget.kind);
        final mine = app.userBooks(subject.id, widget.kind);
        final empty = assets.isEmpty && mine.isEmpty;

        return Scaffold(
          appBar: AppBar(
            title: Text('${subjectName(subject.id)} • ${widget.title}'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _busy ? null : _add,
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
            child: empty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        tr('no_books'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                    children: [
                      for (final b in mine)
                        Card(
                          child: ListTile(
                            leading: Icon(Icons.picture_as_pdf,
                                color: subject.color),
                            title: Text(b.title),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _remove(b),
                            ),
                            onTap: () => _open(Book(
                              id: b.id,
                              title: b.title,
                              filePath: b.path,
                              subjectId: subject.id,
                            )),
                          ),
                        ),
                      for (final b in assets)
                        Card(
                          child: ListTile(
                            leading: Icon(Icons.picture_as_pdf,
                                color: subject.color),
                            title: Text(b.title),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _open(b),
                          ),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
