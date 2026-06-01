import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  // ── Get stream URL for a track ────────────────────────────────
  Future<String?> getStreamUrl(String trackTitle, String artist) async {
    try {
      final query   = '$trackTitle $artist official audio';
      final results = await _yt.search.search(query);

      if (results.isEmpty) {
        debugPrint('YouTube: no results for "$query"');
        return null;
      }

      // اولین نتیجه رو بگیر
      final video    = results.first;
      final manifest = await _yt.videos.streamsClient.getManifest(video.id);

      // بهترین audio stream رو انتخاب کن
      final audioStreams = manifest.audioOnly.sortByBitrate();
      if (audioStreams.isEmpty) return null;

      final streamUrl = audioStreams.last.url.toString();
      debugPrint('YouTube: found stream for "${video.title}"');
      return streamUrl;
    } catch (e) {
      debugPrint('YouTubeService error: $e');
      return null;
    }
  }

  // ── Cache برای جلوگیری از request مکرر ───────────────────────
  final Map<String, String> _cache = {};

  Future<String?> getStreamUrlCached(String trackTitle, String artist) async {
    final key = '$trackTitle-$artist';
    if (_cache.containsKey(key)) return _cache[key];

    final url = await getStreamUrl(trackTitle, artist);
    if (url != null) _cache[key] = url;
    return url;
  }

  void dispose() => _yt.close();
}
