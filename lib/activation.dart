import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'config.dart';

// Aktivatsiya kodi formati:  QURILMAID-KUN-SERIYA-IMZO
// masalan:                   K7M2QX9A-030-4F8Z-1A2B3C4D5E
// IMZO = HMAC-SHA256(maxfiy_so'z, "QURILMAID|KUN|SERIYA") ning birinchi 10 belgisi (hex, katta harf).
// Kod faqat o'sha qurilma uchun ishlaydi va faqat bir marta qo'llanadi.

enum CodeStatus { ok, badFormat, badSignature, wrongDevice }

class ParsedCode {
  final CodeStatus status;
  final int days;
  final String key;
  const ParsedCode(this.status, {this.days = 0, this.key = ''});
}

String _signature(String payload) {
  final hmac = Hmac(sha256, utf8.encode(kActivationSecret));
  final digest = hmac.convert(utf8.encode(payload));
  return digest.toString().substring(0, 10).toUpperCase();
}

ParsedCode parseCode(String raw, String deviceId) {
  final code = raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  final parts = code.split('-');
  if (parts.length != 4) return const ParsedCode(CodeStatus.badFormat);

  final dev = parts[0];
  final days = int.tryParse(parts[1]);
  final serial = parts[2];
  final sig = parts[3];

  if (days == null || days <= 0 || days > 999 || dev.isEmpty || serial.isEmpty) {
    return const ParsedCode(CodeStatus.badFormat);
  }
  if (sig != _signature('$dev|$days|$serial')) {
    return const ParsedCode(CodeStatus.badSignature);
  }
  if (dev != deviceId.toUpperCase()) {
    return const ParsedCode(CodeStatus.wrongDevice);
  }
  return ParsedCode(CodeStatus.ok, days: days, key: '$dev-$serial');
}
