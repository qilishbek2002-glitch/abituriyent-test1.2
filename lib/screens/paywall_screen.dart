import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../config.dart';
import '../l10n.dart';
import '../ui.dart';
import 'language_screen.dart';

class PaywallScreen extends StatefulWidget {
  /// true bo'lsa: orqaga qaytib bo'lmaydi (obuna kerak).
  final bool locked;
  const PaywallScreen({super.key, this.locked = false});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String? _msg;
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) showSnack(context, tr('copied'));
  }

  Future<void> _openTelegram() async {
    final text = Uri.encodeComponent(
        "Salom! Abituriyent Test ilovasi uchun obuna to'lovini qildim. Qurilma ID: ${app.deviceId}");
    final uri = Uri.parse('https://t.me/$kAdminTelegram?text=$text');
    var ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && mounted) showSnack(context, tr('cannot_open_link'));
  }

  Future<void> _activate() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _msg = null;
    });
    final r = await app.activate(_ctrl.text);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case ActivateResult.ok:
        showSnack(context, tr('code_ok', {'d': app.lastActivatedDays.toString()}));
        if (!widget.locked) Navigator.of(context).pop();
        break;
      case ActivateResult.bad:
        setState(() => _msg = tr('code_bad'));
        break;
      case ActivateResult.wrongDevice:
        setState(() => _msg = tr('code_other_device'));
        break;
      case ActivateResult.used:
        setState(() => _msg = tr('code_used'));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final price = fmtMoney(kPriceSom);
        final scheme = Theme.of(context).colorScheme;
        return PopScope(
          canPop: !widget.locked,
          child: Scaffold(
            appBar: AppBar(
              title: Text(tr('subscription')),
              automaticallyImplyLeading: !widget.locked,
              actions: [
                IconButton(
                  icon: const Icon(Icons.language),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LanguageScreen()),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: scheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.workspace_premium, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            tr('tariff_monthly'),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tr('price_month', {'p': price}),
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          if (!app.subscribed && app.trialLeft <= 0) ...[
                            const SizedBox(height: 8),
                            Text(tr('trial_over'), textAlign: TextAlign.center),
                          ],
                          if (app.subscribed) ...[
                            const SizedBox(height: 8),
                            Text(
                              tr('sub_active', {'d': app.daysLeft.toString()}),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(tr('pay_steps', {'p': price}),
                      style: const TextStyle(fontSize: 15, height: 1.4)),
                  const SizedBox(height: 12),
                  _copyCard(tr('card_number'), kPayCardNumber,
                      subtitle: kPayCardOwner),
                  _copyCard(tr('device_id'), app.deviceId),
                  const SizedBox(height: 4),
                  FilledButton.icon(
                    onPressed: _openTelegram,
                    icon: const Icon(Icons.send),
                    label: Text(tr('write_tg')),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _ctrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: tr('enter_code'),
                      border: const OutlineInputBorder(),
                      errorText: _msg,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _busy ? null : _activate,
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(tr('activate')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _copyCard(String label, String value, {String? subtitle}) {
    return Card(
      child: ListTile(
        title: Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
        subtitle: Text(subtitle == null ? label : '$label • $subtitle'),
        trailing: IconButton(
          tooltip: tr('copy'),
          icon: const Icon(Icons.copy),
          onPressed: () => _copy(value),
        ),
      ),
    );
  }
}
