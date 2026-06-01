import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/deezer_service.dart';

class MoodResult {
  final String mood;
  final String genre;
  final int genreId;
  final String message;

  const MoodResult({
    required this.mood,
    required this.genre,
    required this.genreId,
    required this.message,
  });
}

class MoodProvider extends ChangeNotifier {
  final DeezerService _deezer = DeezerService();

  List<DeezerTrack> _tracks     = [];
  MoodResult?       _moodResult;
  bool    _isLoading  = false;
  String? _error;

  List<DeezerTrack> get tracks     => _tracks;
  MoodResult?       get moodResult => _moodResult;
  bool    get isLoading  => _isLoading;
  String? get error      => _error;

  // ── Analyze mood with Claude API ─────────────────────────────
  Future<void> analyzeMoodAndGenerate(String userText) async {
    _isLoading = true;
    _error     = null;
    _tracks    = [];
    _moodResult = null;
    notifyListeners();

    try {
      // Call Claude API
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type':      'application/json',
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model':      'claude-sonnet-4-20250514',
          'max_tokens': 256,
          'messages': [
            {
              'role':    'user',
              'content': '''Analyze this mood description and return ONLY a JSON object (no markdown, no explanation):
"$userText"

Return exactly this format:
{
  "mood": "one of: energetic, chill, focused, melancholic, hype, happy",
  "genre": "genre name",
  "genreId": <deezer genre id>,
  "message": "short empathetic message in same language as input, max 10 words"
}

Deezer genre IDs: Electronic=106, Pop=132, Rock=152, HipHop=116, Jazz=129, Classical=98, RnB=165, Dance=113, Metal=464, Country=84

Match mood to genre intelligently.'''
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data    = jsonDecode(response.body);
        final content = data['content'][0]['text'] as String;

        // Parse JSON response
        final json = jsonDecode(content.trim());
        _moodResult = MoodResult(
          mood:    json['mood']    ?? 'chill',
          genre:   json['genre']   ?? 'Pop',
          genreId: json['genreId'] ?? 132,
          message: json['message'] ?? 'Here is your playlist',
        );

        // Get tracks from Deezer
        _tracks = await _deezer.getTracksByGenre(_moodResult!.genreId, limit: 10);
      } else {
        throw Exception('Claude API error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MoodProvider error: $e');
      _error = 'خطا در تحلیل mood. لطفاً دوباره امتحان کنید.';

      // Fallback: از mood مستقیم استفاده کن
      if (userText.isNotEmpty) {
        final genreId = DeezerService.moodToGenreId(userText.toLowerCase());
        _tracks = await _deezer.getTracksByGenre(genreId, limit: 10);
        _error  = null;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Generate از mood مستقیم (بدون Claude) ───────────────────
  Future<void> generateFromMood(String moodId) async {
    _isLoading  = true;
    _error      = null;
    _tracks     = [];
    notifyListeners();

    try {
      final genreId = DeezerService.moodToGenreId(moodId);
      _tracks = await _deezer.getTracksByGenre(genreId, limit: 10);
    } catch (e) {
      _error = 'خطا در دریافت آهنگ‌ها';
      debugPrint('MoodProvider generateFromMood error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _tracks     = [];
    _moodResult = null;
    _error      = null;
    notifyListeners();
  }
}
