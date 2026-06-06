import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/deezer_service.dart';

class Memory {
  final String id;
  final String userId;
  final String trackId;
  final String title;
  final String artist;
  final String? albumArt;
  final String? previewUrl;
  final String mood;
  final int plays;
  final String? note;
  final String? aiInsight;
  final DateTime createdAt;

  const Memory({
    required this.id,
    required this.userId,
    required this.trackId,
    required this.title,
    required this.artist,
    this.albumArt,
    this.previewUrl,
    required this.mood,
    required this.plays,
    this.note,
    this.aiInsight,
    required this.createdAt,
  });

  factory Memory.fromJson(Map<String, dynamic> json) => Memory(
    id:         json['id'],
    userId:     json['user_id'],
    trackId:    json['track_id'] ?? '',
    title:      json['title'] ?? '',
    artist:     json['artist'] ?? '',
    albumArt:   json['album_art'],
    previewUrl: json['preview_url'],
    mood:       json['mood'] ?? 'chill',
    plays:      json['plays'] ?? 1,
    note:       json['note'],
    aiInsight:  json['ai_insight'],
    createdAt:  DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
  );

  String get moodEmoji {
    switch (mood) {
      case 'energetic':   return '⚡';
      case 'hype':        return '🔥';
      case 'chill':       return '🌙';
      case 'focused':     return '💭';
      case 'melancholic': return '🌧';
      case 'happy':       return '💗';
      default:            return '🎵';
    }
  }

  DeezerTrack toDeezerTrack() => DeezerTrack(
    id:          trackId,
    title:       title,
    artist:      artist,
    artistId:    '',
    album:       '',
    albumArt:    albumArt,
    previewUrl:  previewUrl,
    durationSec: 0,
    rank:        0,
  );
}

class MemoryProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Memory> _memories    = [];
  bool _isLoading           = false;
  String? _error;
  String? _aiInsight;
  bool _isLoadingInsight    = false;

  List<Memory> get memories       => _memories;
  bool get isLoading              => _isLoading;
  String? get error               => _error;
  String? get aiInsight           => _aiInsight;
  bool get isLoadingInsight       => _isLoadingInsight;

  int get totalPlays => _memories.fold(0, (sum, m) => sum + m.plays);
  Set<String> get moods => _memories.map((m) => m.mood).toSet();

  // ── Fetch memories ────────────────────────────────────────
  Future<void> fetchMemories() async {
    _isLoading = true;
    _error     = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('memories')
          .select()
          .eq('user_id', userId)
          .order('plays', ascending: false);

      _memories = (data as List).map((m) => Memory.fromJson(m)).toList();

      // Generate AI insight if we have memories
      if (_memories.isNotEmpty && _aiInsight == null) {
        _generateAiInsight();
      }
    } catch (e) {
      _error = 'خطا در دریافت خاطرات';
      debugPrint('MemoryProvider fetchMemories error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Save memory (when user plays a track) ─────────────────
  DateTime? _lastSaved;
  String?   _lastTrackId;

  Future<void> saveMemory(DeezerTrack track, String mood) async {
    // throttle — فقط وقتی آهنگ عوض شد یا ۳۰ ثانیه گذشته
    final now = DateTime.now();
    final sameTrack = _lastTrackId == track.id;
    if (sameTrack && _lastSaved != null && now.difference(_lastSaved!).inSeconds < 30) return;
    _lastSaved   = now;
    _lastTrackId = track.id;

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final existing = await _supabase
          .from('memories')
          .select('id, plays')
          .eq('user_id', userId)
          .eq('track_id', track.id)
          .maybeSingle();

      if (existing != null) {
        await _supabase.from('memories').update({
          'plays': (existing['plays'] as int) + 1,
          'mood':  mood,
        }).eq('id', existing['id']);
      } else {
        await _supabase.from('memories').insert({
          'user_id':     userId,
          'track_id':    track.id,
          'title':       track.title,
          'artist':      track.artist,
          'album_art':   track.albumArt,
          'preview_url': track.previewUrl,
          'mood':        mood,
          'plays':       1,
        });
      }

      await fetchMemories();
    } catch (e) {
      debugPrint('MemoryProvider saveMemory error: $e');
    }
  }

  // ── Delete memory ─────────────────────────────────────────
  Future<void> deleteMemory(String memoryId) async {
    try {
      await _supabase.from('memories').delete().eq('id', memoryId);
      _memories.removeWhere((m) => m.id == memoryId);
      notifyListeners();
    } catch (e) {
      debugPrint('MemoryProvider deleteMemory error: $e');
    }
  }

  // ── Generate AI insight ───────────────────────────────────
  Future<void> _generateAiInsight() async {
    if (_memories.isEmpty) return;
    _isLoadingInsight = true;
    notifyListeners();

    try {
      final topTracks = _memories.take(5).map((m) => '${m.title} by ${m.artist} (${m.plays} plays, mood: ${m.mood})').join(', ');
      final moodCount = <String, int>{};
      for (final m in _memories) {
        moodCount[m.mood] = (moodCount[m.mood] ?? 0) + 1;
      }
      final topMood = moodCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {'Content-Type': 'application/json', 'anthropic-version': '2023-06-01'},
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 100,
          'messages': [{
            'role': 'user',
            'content': 'Based on this music listening data, write ONE short insight (max 20 words) about this person\'s music habits. Be personal and specific. Top tracks: $topTracks. Most common mood: $topMood. Reply in same language as track names.',
          }],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _aiInsight = data['content'][0]['text'] as String;
      }
    } catch (e) {
      debugPrint('MemoryProvider _generateAiInsight error: $e');
    } finally {
      _isLoadingInsight = false;
      notifyListeners();
    }
  }
}
