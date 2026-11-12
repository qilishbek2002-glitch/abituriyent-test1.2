import 'package:flutter/material.dart';

import '../app_state.dart';
import '../config.dart';
import '../l10n.dart';
import '../models.dart';
import 'api_key_screen.dart';
import 'history_screen.dart';
import 'paywall_screen.dart';
import 'personal_books_screen.dart';
import 'settings_screen.dart';
import 'subject_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(tr('app_title')),
            actions: [
              IconButton(
                tooltip: tr('history'),
                icon: const Icon(Icons.history),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
              ),
              IconButton(
                tooltip: tr('settings'),
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _banner(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                  child: Text(
                    tr('home_subjects'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.1,
                  children: [
                    for (final s in kSubjects)
                      _tile(
                        label: subjectName(s.id),
                        color: s.color,
                        icon: s.icon,
                        image: app.subjectImages[s.id],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => SubjectScreen(subject: s)),
                        ),
                      ),
                    _tile(
                      label: tr('personal_book'),
                      color: const Color(0xFF455A64),
                      icon: Icons.upload_file,
                      image: app.subjectImages['personal'],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const PersonalBooksScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _banner(BuildContext context) {
    final items = <Widget>[];
    if (!kSubscriptionRequired) {
      // Bepul rejim: obuna haqida xabar ko'rsatilmaydi.
    } else if (app.subscribed) {
      items.add(_infoCard(
        icon: Icons.verified,
        color: Colors.green,
        text: tr('sub_active', {'d': app.daysLeft.toString()}),
      ));
    } else {
      final text = app.trialLeft > 0
          ? tr('trial_left', {'n': app.trialLeft.toString()})
          : tr('trial_over');
      items.add(_infoCard(
        icon: Icons.lock_open,
        color: Colors.orange,
        text: text,
        button: tr('subscribe'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PaywallScreen()),
        ),
      ));
    }
    if (app.apiKey.isEmpty) {
      items.add(_infoCard(
        icon: Icons.key,
        color: Colors.red,
        text: tr('need_key_banner'),
        button: tr('enter'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ApiKeyScreen()),
        ),
      ));
    }
    return Column(children: items);
  }

  Widget _infoCard({
    required IconData icon,
    required Color color,
    required String text,
    String? button,
    VoidCallback? onPressed,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
            if (button != null && onPressed != null)
              TextButton(onPressed: onPressed, child: Text(button)),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    String? image,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              Image.asset(image, fit: BoxFit.cover)
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withAlpha(170)],
                  ),
                ),
                child: Center(
                  child: Icon(icon,
                      size: 56, color: Colors.white.withAlpha(230)),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black.withAlpha(120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
