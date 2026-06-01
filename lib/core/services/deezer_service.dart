import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DeezerTrack {
  final String id;
  final String title;
  final String artist;
  final String artistId;
  final String album;
  final String? albumArt;
  final String? previewUrl;
  final int durationSec;
  final int rank;

  const DeezerTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.artistId,
    required this.album,
    this.albumArt,
    this.previewUrl,
    required this.durationSec,
    required this.rank,
  });

  factory DeezerTrack.fromJson(Map<String, dynamic> json) {
    final artist = json['artist'] as Map<String, dynamic>? ?? {};
    final album = json['album'] as Map<String, dynamic>? ?? {};
    final contributors = json['contributors'] as List?;
    final contrib = (contributors != null && contributors.isNotEmpty)
        ? contributors[0] as Map<String, dynamic>
        : <String, dynamic>{};

    // برای search نتایج، album.cover_medium هست
    // برای artist/top، فقط contributors هست
    String? albumArt = album['cover_medium'] ??
        album['cover_big'] ??
        album['cover'] ??
        contrib['picture_medium'] ??
        contrib['picture_big'] ??
        contrib['picture'] ??
        artist['picture_medium'] ??
        artist['picture'];

    // اگه URL از نوع api.deezer.com/artist/xx/image بود، مستقیم picture_medium از contributor بگیر
    if (albumArt != null && albumArt.contains('api.deezer.com')) {
      albumArt = contrib['picture_medium'] ??
          contrib['picture_big'] ??
          contrib['picture'];
    }

    debugPrint('Track: ${json['title']} | albumArt: $albumArt');

    return DeezerTrack(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      artist: artist['name'] ?? contrib['name'] ?? '',
      artistId: artist['id']?.toString() ?? contrib['id']?.toString() ?? '',
      album: album['title'] ?? '',
      albumArt: albumArt,
      previewUrl: json['preview'],
      durationSec: json['duration'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }

  String get durationFormatted {
    final m = (durationSec / 60).floor();
    final s = (durationSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class DeezerArtist {
  final String id;
  final String name;
  final String? imageUrl;
  final int fans;
  final int albumCount;

  const DeezerArtist({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.fans,
    required this.albumCount,
  });

  factory DeezerArtist.fromJson(Map<String, dynamic> json) {
    return DeezerArtist(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      imageUrl: json['picture_xl'] ??
          json['picture_big'] ??
          json['picture_medium'] ??
          json['picture'],
      fans: json['nb_fan'] ?? 0,
      albumCount: json['nb_album'] ?? 0,
    );
  }

  String get fansFormatted {
    if (fans >= 1000000) return '${(fans / 1000000).toStringAsFixed(1)}M';
    if (fans >= 1000) return '${(fans / 1000).toStringAsFixed(0)}K';
    return fans.toString();
  }
}

class DeezerService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.deezer.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<DeezerTrack>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio
          .get('/search', queryParameters: {'q': query, 'limit': limit});
      final items = response.data['data'] as List? ?? [];
      return items.map((t) => DeezerTrack.fromJson(t)).toList();
    } catch (e) {
      debugPrint('Deezer searchTracks error: $e');
      return [];
    }
  }

  Future<List<DeezerArtist>> searchArtists(String query,
      {int limit = 10}) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio
          .get('/search/artist', queryParameters: {'q': query, 'limit': limit});
      final items = response.data['data'] as List? ?? [];
      return items.map((a) => DeezerArtist.fromJson(a)).toList();
    } catch (e) {
      debugPrint('Deezer searchArtists error: $e');
      return [];
    }
  }

  Future<DeezerArtist?> getArtist(String artistId) async {
    try {
      final response = await _dio.get('/artist/$artistId');
      return DeezerArtist.fromJson(response.data);
    } catch (e) {
      debugPrint('Deezer getArtist error: $e');
      return null;
    }
  }

  Future<List<DeezerTrack>> getArtistTopTracks(String artistId,
      {int limit = 10}) async {
    try {
      final response = await _dio
          .get('/artist/$artistId/top', queryParameters: {'limit': limit});
      final items = response.data['data'] as List? ?? [];
      return items.map((t) => DeezerTrack.fromJson(t)).toList();
    } catch (e) {
      debugPrint('Deezer getArtistTopTracks error: $e');
      return [];
    }
  }

  Future<List<DeezerArtist>> getRelatedArtists(String artistId,
      {int limit = 5}) async {
    try {
      final response = await _dio
          .get('/artist/$artistId/related', queryParameters: {'limit': limit});
      final items = response.data['data'] as List? ?? [];
      return items.map((a) => DeezerArtist.fromJson(a)).toList();
    } catch (e) {
      debugPrint('Deezer getRelatedArtists error: $e');
      return [];
    }
  }

  Future<List<DeezerTrack>> getTracksByGenre(int genreId,
      {int limit = 10}) async {
    try {
      final response = await _dio
          .get('/chart/$genreId/tracks', queryParameters: {'limit': limit});
      final items = response.data['data'] as List? ?? [];
      return items.map((t) => DeezerTrack.fromJson(t)).toList();
    } catch (e) {
      return getTopCharts(limit: limit);
    }
  }

  Future<List<DeezerTrack>> getTopCharts({int limit = 10}) async {
    try {
      final response =
          await _dio.get('/chart/0/tracks', queryParameters: {'limit': limit});
      final items = response.data['data'] as List? ?? [];
      return items.map((t) => DeezerTrack.fromJson(t)).toList();
    } catch (e) {
      debugPrint('Deezer getTopCharts error: $e');
      return [];
    }
  }

  static int moodToGenreId(String mood) {
    switch (mood) {
      case 'energetic':
        return 106;
      case 'hype':
        return 116;
      case 'chill':
        return 129;
      case 'focused':
        return 106;
      case 'melancholic':
        return 152;
      case 'happy':
        return 132;
      default:
        return 0;
    }
  }
}
