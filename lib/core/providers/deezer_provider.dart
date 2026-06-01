import 'package:flutter/foundation.dart';
import '../services/deezer_service.dart';

class DeezerProvider extends ChangeNotifier {
  final DeezerService _service = DeezerService();

  // ── Search ────────────────────────────────────────────────────
  List<DeezerTrack> _searchTracks = [];
  List<DeezerArtist> _searchArtists = [];
  bool _isSearching = false;
  String? _searchError;

  List<DeezerTrack> get searchTracks => _searchTracks;
  List<DeezerArtist> get searchArtists => _searchArtists;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;

  // ── Artist ────────────────────────────────────────────────────
  DeezerArtist? _currentArtist;
  List<DeezerTrack> _artistTopTracks = [];
  List<DeezerArtist> _relatedArtists = [];
  bool _isLoadingArtist = false;

  DeezerArtist? get currentArtist => _currentArtist;
  List<DeezerTrack> get artistTopTracks => _artistTopTracks;
  List<DeezerArtist> get relatedArtists => _relatedArtists;
  bool get isLoadingArtist => _isLoadingArtist;

  // ── Mood ──────────────────────────────────────────────────────
  List<DeezerTrack> _moodTracks = [];
  bool _isLoadingMood = false;
  String? _moodError;

  List<DeezerTrack> get moodTracks => _moodTracks;
  bool get isLoadingMood => _isLoadingMood;
  String? get moodError => _moodError;

  // ── Search ────────────────────────────────────────────────────
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchTracks = [];
      _searchArtists = [];
      notifyListeners();
      return;
    }

    _searchTracks = [];
    _searchArtists = [];
    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.searchTracks(query, limit: 15),
        _service.searchArtists(query, limit: 5),
      ]);
      _searchTracks = results[0] as List<DeezerTrack>;
      _searchArtists = results[1] as List<DeezerArtist>;
    } catch (e) {
      _searchError = 'خطا در جستجو';
      debugPrint('DeezerProvider search error: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchTracks = [];
    _searchArtists = [];
    _searchError = null;
    notifyListeners();
  }

  // ── Artist ────────────────────────────────────────────────────
  Future<void> loadArtist(String artistId) async {
    _currentArtist = null;
    _artistTopTracks = [];
    _relatedArtists = [];
    _isLoadingArtist = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getArtist(artistId),
        _service.getArtistTopTracks(artistId),
        _service.getRelatedArtists(artistId),
      ]);
      _currentArtist = results[0] as DeezerArtist?;
      _artistTopTracks = results[1] as List<DeezerTrack>;
      _relatedArtists = results[2] as List<DeezerArtist>;
    } catch (e) {
      debugPrint('DeezerProvider loadArtist error: $e');
    } finally {
      _isLoadingArtist = false;
      notifyListeners();
    }
  }

  // ── Mood Recommendations ──────────────────────────────────────
  Future<void> loadMoodTracks(String mood) async {
    _isLoadingMood = true;
    _moodError = null;
    _moodTracks = [];
    notifyListeners();

    try {
      final genreId = DeezerService.moodToGenreId(mood);
      _moodTracks = await _service.getTracksByGenre(genreId);
    } catch (e) {
      _moodError = 'خطا در دریافت پیشنهادات';
      debugPrint('DeezerProvider moodTracks error: $e');
    } finally {
      _isLoadingMood = false;
      notifyListeners();
    }
  }
}
