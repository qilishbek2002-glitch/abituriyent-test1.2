import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

class GeminiException implements Exception {
  /// 'key' | 'quota' | 'network' | 'region' | 'overloaded' | 'bad_response' | 'model' | 'http' | 'cancelled'
  final String code;
  final String detail;
  GeminiException(this.code, [this.detail = '']);
  @override
  String toString() => 'GeminiException($code, $detail)';
}

class GeminiService {
  final String apiKey;
  GeminiService(this.apiKey);

  /// Kalit ishlashini tekshiradi (xato bo'lsa GeminiException tashlaydi).
  Future<void> verify() async {
    await generateText({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': 'Reply with the single word: OK'}
          ]
        }
      ],
      'generationConfig': {'temperature': 0},
    });
  }

  /// Gemini'ga so'rov yuboradi va matnli javobni qaytaradi.
  /// Kerak bo'lsa qayta urinadi va zaxira modellarga o'tadi.
  Future<String> generateText(Map<String, dynamic> body) async {
    GeminiException? last;
    for (final model in kGeminiModels) {
      final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent');
      for (var attempt = 0; attempt < 3; attempt++) {
        http.Response? res;
        try {
          res = await http
              .post(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'x-goog-api-key': apiKey,
                },
                body: jsonEncode(body),
              )
              .timeout(const Duration(seconds: 120));
        } catch (e) {
          res = null;
          last = GeminiException('network', e.toString());
        }
        if (res == null) {
          if (attempt == 0) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          throw last ?? GeminiException('network');
        }

        final code = res.statusCode;
        final text = utf8.decode(res.bodyBytes, allowMalformed: true);
        final lower = text.toLowerCase();

        if (code == 200) return _extract(text);

        if (code == 400 &&
            (lower.contains('api key not valid') ||
                lower.contains('api_key_invalid'))) {
          throw GeminiException('key');
        }
        if (code == 401) throw GeminiException('key');
        if (code == 403) {
          if (lower.contains('location') || lower.contains('region')) {
            throw GeminiException('region', _message(text));
          }
          throw GeminiException('key', _message(text));
        }
        if (code == 404) {
          last = GeminiException('model', model);
          break; // keyingi modelga o'tamiz
        }
        if (code == 429) {
          last = GeminiException('quota', _message(text));
          if (lower.contains('perday') || lower.contains('per day')) {
            break; // kunlik limit tugagan: keyingi modelni sinaymiz
          }
          await Future.delayed(Duration(seconds: _retryDelay(text, attempt)));
          continue;
        }
        if (code >= 500) {
          last = GeminiException('overloaded', _message(text));
          await Future.delayed(Duration(seconds: 3 * (attempt + 1)));
          continue;
        }
        throw GeminiException('http', '$code ${_message(text)}');
      }
    }
    throw last ?? GeminiException('http', 'unknown');
  }

  String _extract(String body) {
    try {
      final j = jsonDecode(body);
      if (j is Map) {
        final cands = j['candidates'];
        if (cands is List && cands.isNotEmpty) {
          final first = cands[0];
          if (first is Map) {
            final content = first['content'];
            if (content is Map) {
              final parts = content['parts'];
              if (parts is List) {
                final sb = StringBuffer();
                for (final p in parts) {
                  if (p is Map && p['text'] is String && p['thought'] != true) {
                    sb.write(p['text'] as String);
                  }
                }
                return sb.toString();
              }
            }
          }
        }
      }
    } catch (_) {}
    return '';
  }

  String _message(String text) {
    try {
      final j = jsonDecode(text);
      if (j is Map && j['error'] is Map) {
        final m = (j['error'] as Map)['message'];
        if (m is String) return m;
      }
    } catch (_) {}
    return text.length > 200 ? text.substring(0, 200) : text;
  }

  int _retryDelay(String text, int attempt) {
    final m1 = RegExp(r'retry in (\d+(?:\.\d+)?)s').firstMatch(text);
    final m2 = RegExp(r'retryDelay"\s*:\s*"(\d+(?:\.\d+)?)s').firstMatch(text);
    final m = m1 ?? m2;
    if (m != null) {
      final v = double.tryParse(m.group(1) ?? '');
      if (v != null) {
        final s = v.ceil() + 1;
        return s > 30 ? 30 : s;
      }
    }
    return 8 * (attempt + 1);
  }
}
