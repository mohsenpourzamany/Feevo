import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'youtube_service.dart';

// ── Track Model ───────────────────────────────────────────────
class FeevoTrack {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String emoji;
  final String url;
  final String? artworkUrl;

  const FeevoTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.emoji,
    required this.url,
    this.artworkUrl,
  });

  MediaItem toMediaItem() => MediaItem(
        id: url.isNotEmpty ? url : id,
        title: title,
        artist: artist,
        album: album,
        artUri: artworkUrl != null ? Uri.parse(artworkUrl!) : null,
        extras: {'emoji': emoji},
      );

  static List<FeevoTrack> get mockTracks => [];
}

// ── Audio Player Service ──────────────────────────────────────
class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final YouTubeService _youtube = YouTubeService();

  List<FeevoTrack> _queue = [];
  int _currentIdx = 0;
  bool _isLoading = false;
  String? _error;

  AudioPlayer get player => _player;
  List<FeevoTrack> get queue => _queue;
  int get currentIndex => _currentIdx;
  int get currentIdx => _currentIdx;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPlaying => _player.playing;
  bool get hasPrevious => _currentIdx > 0;
  bool get hasNext => _currentIdx < _queue.length - 1;
  FeevoTrack? get currentTrack =>
      _queue.isNotEmpty ? _queue[_currentIdx] : null;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  double get volume => _player.volume;
  LoopMode get loopMode => _player.loopMode;

  double get progress {
    final dur = duration.inMilliseconds;
    if (dur == 0) return 0;
    return (position.inMilliseconds / dur).clamp(0.0, 1.0);
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;

  AudioPlayerService() : _currentIdx = 0 {
    _init();
  }

  void _init() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed)
        _onTrackComplete();
      notifyListeners();
    });
    _player.positionStream.listen((_) => notifyListeners());
    _player.durationStream.listen((_) => notifyListeners());
  }

  void _onTrackComplete() {
    if (hasNext) {
      playNext();
    } else {
      _player.seek(Duration.zero);
      _player.pause();
      notifyListeners();
    }
  }

  void loadQueue(List<FeevoTrack> tracks) {
    if (tracks.isEmpty) return;
    _queue = tracks;
    _currentIdx = 0;
    notifyListeners();
  }

  Future<void> playTrack(FeevoTrack track) async {
    _queue = [track];
    _currentIdx = 0;
    await _loadAndPlay(track);
  }

  Future<void> playQueue(List<FeevoTrack> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;
    _queue = tracks;
    _currentIdx = startIndex.clamp(0, tracks.length - 1);
    await _loadAndPlay(_queue[_currentIdx]);
  }

  // ── Load and play — YouTube اول، Deezer fallback ─────────────
  Future<void> _loadAndPlay(FeevoTrack track) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String? playUrl;

      // ۱. سعی کن YouTube URL بگیر
      debugPrint('AudioPlayer: trying YouTube for "${track.title}"');
      playUrl = await _youtube.getStreamUrlCached(track.title, track.artist);

      // ۲. اگه YouTube نشد، از Deezer preview استفاده کن
      if (playUrl == null || playUrl.isEmpty) {
        debugPrint(
            'AudioPlayer: YouTube failed, falling back to Deezer preview');
        playUrl = track.url;
      }

      if (playUrl.isEmpty) {
        _error = 'No audio available';
        _isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint(
          'AudioPlayer: playing from ${playUrl.contains('railway.app') ? 'Railway' : playUrl.contains('googlevideo') ? 'YouTube' : 'Deezer'}: ${track.title}');

      final isRailway = playUrl.contains('railway.app');
      final isYouTube = playUrl.contains('googlevideo.com');

      if (isRailway) {
        // فایل رو دانلود کن به حافظه موقت iPhone
        debugPrint('Railway: downloading file for "${track.title}"');
        final httpClient = http.Client();
        final response = await httpClient
            .get(Uri.parse(playUrl))
            .timeout(const Duration(seconds: 60));
        httpClient.close();

        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/${track.id}.m4a');
          await tempFile.writeAsBytes(response.bodyBytes);
          debugPrint('Railway: file saved, playing from local cache');

          await _player.setAudioSource(
            AudioSource.file(tempFile.path, tag: track.toMediaItem()),
          );
          await _player.play();
        } else {
          throw Exception('Download failed: ${response.statusCode}');
        }
      } else if (isYouTube) {
        await _player.setAudioSource(
          AudioSource.uri(
            Uri.parse(playUrl),
            tag: track.toMediaItem(),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)',
              'Origin': 'https://www.youtube.com',
              'Referer': 'https://www.youtube.com/',
            },
          ),
        );
      } else {
        await _player.setAudioSource(
          AudioSource.uri(
            Uri.parse(playUrl),
            tag: track.toMediaItem(),
          ),
        );
      }
      await _player.play();
    } catch (e) {
      _error = 'Failed to load track: $e';
      debugPrint('AudioPlayerService error: $e');

      // اگه YouTube URL خراب شد، Deezer رو امتحان کن
      if (track.url.isNotEmpty) {
        try {
          debugPrint('AudioPlayer: retrying with Deezer preview...');
          await _player.setAudioSource(
            AudioSource.uri(Uri.parse(track.url), tag: track.toMediaItem()),
          );
          await _player.play();
          _error = null;
        } catch (e2) {
          debugPrint('AudioPlayer: Deezer fallback also failed: $e2');
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> play() async => await _player.play();
  Future<void> pause() async => await _player.pause();

  Future<void> togglePlay() async {
    if (_player.playing) {
      await pause();
    } else {
      if (currentTrack != null && duration == Duration.zero) {
        await _loadAndPlay(currentTrack!);
      } else {
        await play();
      }
    }
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    notifyListeners();
  }

  Future<void> seekToProgress(double progress) async {
    final dur = duration;
    if (dur == Duration.zero) return;
    await seek(Duration(milliseconds: (progress * dur.inMilliseconds).round()));
  }

  Future<void> playNext() async {
    if (!hasNext) return;
    _currentIdx++;
    await _loadAndPlay(_queue[_currentIdx]);
  }

  Future<void> playPrevious() async {
    if (position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    if (!hasPrevious) return;
    _currentIdx--;
    await _loadAndPlay(_queue[_currentIdx]);
  }

  Future<void> playAtIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _currentIdx = index;
    await _loadAndPlay(_queue[_currentIdx]);
  }

  Future<void> shuffle() async {
    if (_queue.isEmpty) return;
    final current = _queue[_currentIdx];
    _queue.shuffle();
    _currentIdx = _queue.indexOf(current);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
    notifyListeners();
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
    notifyListeners();
  }

  void addToQueue(FeevoTrack track) {
    _queue.add(track);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    if (index == _currentIdx) return;
    if (index < _currentIdx) _currentIdx--;
    _queue.removeAt(index);
    notifyListeners();
  }

  void clearQueueAfterCurrent() {
    if (_currentIdx < _queue.length - 1) {
      _queue.removeRange(_currentIdx + 1, _queue.length);
      notifyListeners();
    }
  }

  static String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _youtube.dispose();
    _player.dispose();
    super.dispose();
  }
}
