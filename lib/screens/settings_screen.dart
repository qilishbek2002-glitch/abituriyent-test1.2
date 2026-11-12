import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../config.dart';
import '../l10n.dart';
import '../ui.dart';
import 'api_key_screen.dart';
import 'language_screen.dart';
import 'paywall_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _langLabel() {
    switch (app.lang) {
      case 'ru':
        return 'Русский';
      case 'kk':
        return 'Qaraqalpaqsha';
      default:
        return "O'zbekcha";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final subText = app.subscribed
            ? tr('sub_active', {'d': app.daysLeft.toString()})
            : (app.trialLeft > 0
                ? tr('trial_left', {'n': app.trialLeft.toString()})
                : tr('sub_none'));
        return Scaffold(
          appBar: AppBar(title: Text(tr('settings'))),
          body: SafeArea(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(tr('language')),
                  subtitle: Text(_langLabel()),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LanguageScreen()),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.key),
                  title: Text(tr('api_key')),
                  subtitle: Text(
                      app.apiKey.isEmpty ? tr('key_none') : tr('key_saved')),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ApiKeyScreen()),
                  ),
                ),
                if (kSubscriptionRequired)
                  ListTile(
                  leading: const Icon(Icons.workspace_premium),
                  title: Text(tr('subscription')),
                  subtitle: Text(subText),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.phone_android),
                  title: Text(tr('device_id')),
                  subtitle: Text(app.deviceId),
                  trailing: const Icon(Icons.copy),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: app.deviceId));
                    if (context.mounted) showSnack(context, tr('copied'));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(tr('version')),
                  subtitle: Text('$kAppName $kAppVersion'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
