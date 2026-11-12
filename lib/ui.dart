import 'package:flutter/material.dart';

import 'l10n.dart';
import 'services/gemini_service.dart';
import 'services/pdf_service.dart';

void showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg)));
}

Future<bool> confirmDialog(BuildContext context, String msg) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(msg),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(tr('no')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(tr('yes')),
        ),
      ],
    ),
  );
  return r ?? false;
}

String errorText(Object e) {
  if (e is PdfException) {
    return e.code == 'no_text' ? tr('err_no_text') : tr('err_pdf_open');
  }
  if (e is GeminiException) {
    switch (e.code) {
      case 'key':
        return tr('err_key_invalid');
      case 'quota':
        return tr('err_quota');
      case 'network':
        return tr('err_network');
      case 'region':
        return tr('err_region');
      case 'overloaded':
        return tr('err_overloaded');
      case 'bad_response':
        return tr('err_bad');
      default:
        return tr('err_generic', {'e': e.detail.isEmpty ? e.code : e.detail});
    }
  }
  return tr('err_generic', {'e': e.toString()});
}

String fmtMoney(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return b.toString();
}

String formatDate(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}
