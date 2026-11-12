import 'package:flutter/material.dart';

import 'app_state.dart';
import 'config.dart';
import 'screens/home_screen.dart';
import 'screens/language_screen.dart';
import 'screens/paywall_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app.init();
  runApp(const AbituriyentApp());
}

class AbituriyentApp extends StatelessWidget {
  const AbituriyentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3F51B5),
      ),
      home: const _Gate(),
    );
  }
}

/// Qaysi ekran ochilishini hal qiladi: til -> (obuna kerak bo'lsa) to'lov -> bosh sahifa.
class _Gate extends StatelessWidget {
  const _Gate();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        if (!app.langChosen) return const LanguageScreen(first: true);
        if (kSubscriptionRequired && !app.subscribed && app.trialLeft <= 0) {
          return const PaywallScreen(locked: true);
        }
        return const HomeScreen();
      },
    );
  }
}
