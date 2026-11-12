import 'package:flutter/material.dart';

import '../app_state.dart';
import '../l10n.dart';

class LanguageScreen extends StatelessWidget {
  final bool first;
  const LanguageScreen({super.key, this.first = false});

  @override
  Widget build(BuildContext context) {
    final langs = <List<String>>[
      ['uz', "O'zbekcha"],
      ['kk', 'Qaraqalpaqsha'],
      ['ru', 'Русский'],
    ];
    return Scaffold(
      appBar: first ? null : AppBar(title: Text(tr('language'))),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.school, size: 80, color: Color(0xFF3F51B5)),
                const SizedBox(height: 16),
                const Text(
                  'Abituriyent Test',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tilni tanlang • Выберите язык • Tildi tańlań',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 32),
                for (final l in langs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(60),
                      ),
                      onPressed: () async {
                        await app.setLang(l[0]);
                        if (!first && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(l[1], style: const TextStyle(fontSize: 20)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
