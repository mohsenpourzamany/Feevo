import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';

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
        id: url,
        title: title,
        artist: artist,
        album: album,
        artUri: artworkUrl != null ? Uri.parse(artworkUrl!) : null,
        extras: {'emoji': emoji},
      );

  static List<FeevoTrack> get mockTracks => [
        const FeevoTrack(
          id: '1',
          title: 'Midnight City',
          artist: 'M83',
          album: 'Hurry Up, We\'re Dreaming',
          emoji: '🎵',
          url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        ),
        const FeevoTrack(
          id: '2',
          title: 'Electronic Dreams',
          artist: 'Feevo Radio',
          album: 'Chill Mix',
          emoji: '🌊',
          url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        ),
        const FeevoTrack(
          id: '3',
          title: 'Night Drive',
          artist: 'Feevo Radio',
          album: 'Late Night',
          emoji: '🌙',
          url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        ),
        const FeevoTrack(
          id: '4',
          title: 'Deep Focus',
          artist: 'Feevo Radio',
          album: 'Study Mode',
          emoji: '💭',
          url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
        ),
        const FeevoTrack(
          id: '5',
          title: 'Energy Boost',
          artist: 'Feevo Radio',
          album: 'Workout',
          emoji: '⚡',
          url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
        ),
      ];
}

// ── Audio Player Service ──────────────────────────────────────
class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

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

  double get progress {
    final dur = duration.inMilliseconds;
    if (dur == 0) return 0;
    return (position.inMilliseconds / dur).clamp(0.0, 1.0);
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;

  AudioPlayerService() {
    _init();
  }

  void _init() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onTrackComplete();
      }
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

  // ── Load queue بدون پلی کردن ─────────────────────────────────
  void loadQueue(List<FeevoTrack> tracks) {
    if (tracks.isEmpty) return;
    _queue = tracks;
    _currentIdx = 0;
    notifyListeners(); // فقط UI آپدیت میشه، پلی نمیشه
  }

  // ── Play a single track ───────────────────────────────────────
  Future<void> playTrack(FeevoTrack track) async {
    _queue = [track];
    _currentIdx = 0;
    await _loadAndPlay(track);
  }

  // ── Play a queue ──────────────────────────────────────────────
  Future<void> playQueue(List<FeevoTrack> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;
    _queue = tracks;
    _currentIdx = startIndex.clamp(0, tracks.length - 1);
    await _loadAndPlay(_queue[_currentIdx]);
  }

  // ── Load and play ─────────────────────────────────────────────
  Future<void> _loadAndPlay(FeevoTrack track) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (track.url.isEmpty) {
        _error = 'No preview available';
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(track.url),
          tag: track.toMediaItem(),
        ),
      );

      await _player.play();
    } catch (e) {
      _error = 'Failed to load track: $e';
      debugPrint('AudioPlayerService error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Controls ──────────────────────────────────────────────────
  Future<void> play() async => await _player.play();
  Future<void> pause() async => await _player.pause();

  Future<void> togglePlay() async {
    if (_player.playing) {
      await pause();
    } else {
      // اگه هنوز source لود نشده، اول لود کن
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

  double get volume => _player.volume;

  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
    notifyListeners();
  }

  LoopMode get loopMode => _player.loopMode;

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
    _player.dispose();
    super.dispose();
  }
}
