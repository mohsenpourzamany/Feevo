import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class YouTubeService {
  static const String _serverUrl =
      'https://web-production-9ed2c.up.railway.app/stream';

  final Map<String, String> _cache = {};

  Future<String?> getStreamUrl(String trackTitle, String artist) async {
    try {
      debugPrint('Railway: requesting stream for "$trackTitle"');

      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': trackTitle, 'artist': artist}),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url  = data['url'] as String?;
        if (url != null) {
          debugPrint('Railway: got stream for "$trackTitle"');
          return url;
        }
      }
      debugPrint('Railway: failed ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Railway error: $e');
      return null;
    }
  }

  Future<String?> getStreamUrlCached(String trackTitle, String artist) async {
    final key = '$trackTitle-$artist';
    if (_cache.containsKey(key)) return _cache[key];
    final url = await getStreamUrl(trackTitle, artist);
    if (url != null) _cache[key] = url;
    return url;
  }

  void dispose() {}
}
