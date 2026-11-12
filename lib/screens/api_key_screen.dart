import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../config.dart';
import '../l10n.dart';
import '../services/gemini_service.dart';
import '../ui.dart';

class ApiKeyScreen extends StatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  late final TextEditingController _ctrl;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: app.apiKey);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _openKeyPage() async {
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(kGeminiKeyUrl),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && mounted) showSnack(context, tr('cannot_open_link'));
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text;
    if (text != null && text.trim().isNotEmpty) {
      setState(() => _ctrl.text = text.trim());
    }
  }

  Future<void> _save() async {
    final key = _ctrl.text.replaceAll(RegExp(r'\s+'), '');
    if (key.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    var saved = false;
    try {
      await GeminiService(key).verify();
      saved = true;
    } on GeminiException catch (e) {
      // Limit tugagan yoki server band bo'lsa ham kalit to'g'ri hisoblanadi.
      if (e.code == 'quota' || e.code == 'overloaded') {
        saved = true;
      } else {
        _error = errorText(e);
      }
    } catch (e) {
      _error = errorText(e);
    }
    if (saved) await app.setApiKey(key);
    if (!mounted) return;
    setState(() => _busy = false);
    if (saved) {
      showSnack(context, tr('key_ok'));
      Navigator.of(context).pop();
    }
  }

  Future<void> _remove() async {
    await app.setApiKey('');
    if (!mounted) return;
    setState(() {
      _ctrl.text = '';
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('api_key'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(tr('key_steps'),
                    style: const TextStyle(fontSize: 15, height: 1.45)),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _openKeyPage,
              icon: const Icon(Icons.open_in_new),
              label: Text(tr('get_key')),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _ctrl,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: tr('paste_key'),
                border: const OutlineInputBorder(),
                errorText: _error,
                suffixIcon: IconButton(
                  tooltip: tr('paste'),
                  icon: const Icon(Icons.content_paste),
                  onPressed: _paste,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(tr('save_check')),
            ),
            if (app.apiKey.isNotEmpty)
              TextButton(
                onPressed: _remove,
                child: Text(tr('key_remove')),
              ),
          ],
        ),
      ),
    );
  }
}
