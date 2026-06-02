import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/deezer_service.dart';

class Playlist {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final List<DeezerTrack> tracks;
  final DateTime createdAt;

  const Playlist({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.tracks,
    required this.createdAt,
  });

  factory Playlist.fromJson(Map<String, dynamic> json,
          {List<DeezerTrack> tracks = const []}) =>
      Playlist(
        id: json['id'],
        userId: json['user_id'],
        name: json['name'] ?? 'Playlist',
        description: json['description'],
        tracks: tracks,
        createdAt: DateTime.parse(json['created_at']),
      );

  String get emoji {
    final emojis = ['🎵', '🌙', '⚡', '🔥', '💗', '🎸', '🎹', '🌊'];
    return emojis[name.length % emojis.length];
  }
}

class LikedSong {
  final String id;
  final String userId;
  final String trackId;
  final String title;
  final String artist;
  final String album;
  final String? albumArt;
  final String? previewUrl;
  final DateTime likedAt;

  const LikedSong({
    required this.id,
    required this.userId,
    required this.trackId,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArt,
    this.previewUrl,
    required this.likedAt,
  });

  factory LikedSong.fromJson(Map<String, dynamic> json) => LikedSong(
        id: json['id'],
        userId: json['user_id'],
        trackId: json['track_id'],
        title: json['title'] ?? '',
        artist: json['artist'] ?? '',
        album: json['album'] ?? '',
        albumArt: json['album_art'],
        previewUrl: json['preview_url'],
        likedAt: DateTime.parse(json['created_at']),
      );

  DeezerTrack toDeezerTrack() => DeezerTrack(
        id: trackId,
        title: title,
        artist: artist,
        artistId: '',
        album: album,
        albumArt: albumArt,
        previewUrl: previewUrl,
        durationSec: 0,
        rank: 0,
      );
}

class PlaylistProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  // ── Playlists ─────────────────────────────────────────────
  List<Playlist> _playlists = [];
  bool _isLoadingPlaylists = false;

  List<Playlist> get playlists => _playlists;
  bool get isLoadingPlaylists => _isLoadingPlaylists;

  // ── Liked Songs ───────────────────────────────────────────
  List<LikedSong> _likedSongs = [];
  bool _isLoadingLiked = false;
  Set<String> _likedTrackIds = {};

  List<LikedSong> get likedSongs => _likedSongs;
  bool get isLoadingLiked => _isLoadingLiked;
  bool isLiked(String trackId) => _likedTrackIds.contains(trackId);

  // ── Fetch Playlists ───────────────────────────────────────
  Future<void> fetchPlaylists() async {
    _isLoadingPlaylists = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('playlists')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _playlists = (data as List).map((p) => Playlist.fromJson(p)).toList();
    } catch (e) {
      debugPrint('PlaylistProvider fetchPlaylists error: $e');
    } finally {
      _isLoadingPlaylists = false;
      notifyListeners();
    }
  }

  // ── Create Playlist ───────────────────────────────────────
  Future<Playlist?> createPlaylist(String name, {String? description}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final data = await _supabase
          .from('playlists')
          .insert({
            'user_id': userId,
            'name': name,
            'description': description,
          })
          .select()
          .single();

      final playlist = Playlist.fromJson(data);
      _playlists.insert(0, playlist);
      notifyListeners();
      return playlist;
    } catch (e) {
      debugPrint('PlaylistProvider createPlaylist error: $e');
      return null;
    }
  }

  // ── Add Track to Playlist ─────────────────────────────────
  Future<void> addTrackToPlaylist(String playlistId, DeezerTrack track) async {
    try {
      await _supabase.from('playlist_tracks').insert({
        'playlist_id': playlistId,
        'track_id': track.id,
        'title': track.title,
        'artist': track.artist,
        'album': track.album,
        'album_art': track.albumArt,
        'preview_url': track.previewUrl,
      });
    } catch (e) {
      debugPrint('PlaylistProvider addTrackToPlaylist error: $e');
    }
  }

  // ── Fetch Playlist Tracks ─────────────────────────────────
  Future<List<DeezerTrack>> fetchPlaylistTracks(String playlistId) async {
    try {
      final data = await _supabase
          .from('playlist_tracks')
          .select()
          .eq('playlist_id', playlistId)
          .order('created_at');

      return (data as List)
          .map((t) => DeezerTrack(
                id: t['track_id'],
                title: t['title'] ?? '',
                artist: t['artist'] ?? '',
                artistId: '',
                album: t['album'] ?? '',
                albumArt: t['album_art'],
                previewUrl: t['preview_url'],
                durationSec: 0,
                rank: 0,
              ))
          .toList();
    } catch (e) {
      debugPrint('PlaylistProvider fetchPlaylistTracks error: $e');
      return [];
    }
  }

  // ── Liked Songs ───────────────────────────────────────────
  Future<void> fetchLikedSongs() async {
    _isLoadingLiked = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('liked_songs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _likedSongs = (data as List).map((s) => LikedSong.fromJson(s)).toList();
      _likedTrackIds = _likedSongs.map((s) => s.trackId).toSet();
    } catch (e) {
      debugPrint('PlaylistProvider fetchLikedSongs error: $e');
    } finally {
      _isLoadingLiked = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(DeezerTrack track) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    if (_likedTrackIds.contains(track.id)) {
      // Unlike
      _likedTrackIds.remove(track.id);
      _likedSongs.removeWhere((s) => s.trackId == track.id);
      notifyListeners();
      try {
        await _supabase
            .from('liked_songs')
            .delete()
            .eq('user_id', userId)
            .eq('track_id', track.id);
      } catch (e) {
        debugPrint('PlaylistProvider unlike error: $e');
      }
    } else {
      // Like
      _likedTrackIds.add(track.id);
      notifyListeners();
      try {
        await _supabase.from('liked_songs').insert({
          'user_id': userId,
          'track_id': track.id,
          'title': track.title,
          'artist': track.artist,
          'album': track.album,
          'album_art': track.albumArt,
          'preview_url': track.previewUrl,
        });
        await fetchLikedSongs();
      } catch (e) {
        debugPrint('PlaylistProvider like error: $e');
      }
    }
  }

  // ── Remove Track from Playlist ───────────────────────────
  Future<void> removeTrackFromPlaylist(
      String playlistId, String trackId) async {
    try {
      await _supabase
          .from('playlist_tracks')
          .delete()
          .eq('playlist_id', playlistId)
          .eq('track_id', trackId);
    } catch (e) {
      debugPrint('PlaylistProvider removeTrackFromPlaylist error: $e');
    }
  }

  // ── Delete Playlist ───────────────────────────────────────
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _supabase.from('playlists').delete().eq('id', playlistId);
      _playlists.removeWhere((p) => p.id == playlistId);
      notifyListeners();
    } catch (e) {
      debugPrint('PlaylistProvider deletePlaylist error: $e');
    }
  }
}
