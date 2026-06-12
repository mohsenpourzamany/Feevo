import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/providers/playlist_provider.dart';
import '../../core/providers/memory_provider.dart';
import '../../core/services/deezer_service.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});
  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  bool _isShuffling = false;
  late AnimationController _vinylController,
      _contentController,
      _pulseController;
  late Animation<double> _contentOpacity, _pulse;
  late Animation<Offset> _contentSlide;
  AudioPlayerService? _audioService;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playEntrance();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _audioService = context.read<AudioPlayerService>();
      if (_audioService!.currentTrack == null)
        _audioService!.loadQueue(FeevoTrack.mockTracks);
      context.read<PlaylistProvider>().fetchPlaylists();
      context.read<PlaylistProvider>().fetchLikedSongs();
      _audioService!.addListener(_onTrackChanged);
    });
  }

  void _setupAnimations() {
    _vinylController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat();
    _contentController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _contentController, curve: Curves.easeOutCubic));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  void _playEntrance() => Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _contentController.forward();
      });

  void _onTrackChanged() {
    if (!mounted || _audioService == null) return;
    final track = _audioService!.currentTrack;
    if (track != null && _audioService!.isPlaying) {
      final deezerTrack = DeezerTrack(
          id: track.id,
          title: track.title,
          artist: track.artist,
          artistId: '',
          album: track.album,
          albumArt: track.artworkUrl,
          previewUrl: track.url,
          durationSec: 0,
          rank: 0);
      context.read<MemoryProvider>().saveMemory(deezerTrack, 'chill');
    }
  }

  @override
  void dispose() {
    _audioService?.removeListener(_onTrackChanged);
    _vinylController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    final track = context.read<AudioPlayerService>().currentTrack;
    if (track == null) return;
    await Share.share(
        '🎵 I\'m listening to "${track.title}" by ${track.artist} on Feevo!\n\nhttps://feevo.music');
  }

  void _showAddToPlaylist(AppLocalizations l) {
    final track = context.read<AudioPlayerService>().currentTrack;
    if (track == null) return;
    final pp = context.read<PlaylistProvider>();
    if (pp.playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.noPlaylists),
          backgroundColor: AppColors.purple,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
      return;
    }
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => _RealPlaylistSheet(track: track, provider: pp, l: l));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final isSmall = screenH < 700; // iPhone SE
    final isMed = screenH < 812; // iPhone 8 / X

    // فاصله‌های متناسب با اندازه صفحه
    final vGap = isSmall
        ? 6.0
        : isMed
            ? 12.0
            : 20.0;
    final vinylSize = isSmall
        ? 170.0
        : isMed
            ? 200.0
            : 220.0;
    final titleSize = isSmall ? 18.0 : 22.0;
    final btnSize = isSmall ? 50.0 : 60.0;
    final prevSize = isSmall ? 38.0 : 44.0;

    return Consumer<AudioPlayerService>(
      builder: (context, service, _) {
        final track = service.currentTrack;
        final isPlaying = service.isPlaying;

        if (isPlaying && !_vinylController.isAnimating)
          _vinylController.repeat();
        else if (!isPlaying && _vinylController.isAnimating)
          _vinylController.stop();

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Stack(children: [
            Positioned.fill(
                child: Container(
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF0D0520), Color(0xFF06060F)])))),
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),
            Positioned(
                top: -100,
                left: -80,
                child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppColors.purple.withOpacity(0.22),
                          AppColors.purple.withOpacity(0)
                        ])))),
            SafeArea(
              child: SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentOpacity,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(children: [
                        GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: AppColors.border)),
                                child: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.textSecond,
                                    size: 22))),
                        const Spacer(),
                        Text(l.nowPlaying.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecond,
                                letterSpacing: 2)),
                        const Spacer(),
                        Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border)),
                            child: const Icon(Icons.more_horiz_rounded,
                                color: AppColors.textSecond, size: 20)),
                      ]),
                    ),
                    SizedBox(height: vGap),
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (_, child) => Transform.scale(
                              scale: isPlaying ? _pulse.value : 1.0,
                              child: child),
                          child: AnimatedBuilder(
                            animation: _vinylController,
                            builder: (_, child) => Transform.rotate(
                                angle: isPlaying
                                    ? _vinylController.value * 2 * 3.14159
                                    : 0,
                                child: child),
                            child: Container(
                              width: vinylSize,
                              height: vinylSize,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            AppColors.purple.withOpacity(0.6),
                                        blurRadius: 40,
                                        spreadRadius: 4)
                                  ]),
                              child: ClipOval(
                                  child: track?.artworkUrl != null
                                      ? Image.network(track!.artworkUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _buildVinyl())
                                      : _buildVinyl()),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(children: [
                          Row(children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(track?.title ?? 'No track',
                                      style: TextStyle(
                                          fontSize: titleSize,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                          letterSpacing: -0.5),
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 3),
                                  Text(
                                      track != null
                                          ? '${track.artist} · ${track.album}'
                                          : '',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecond),
                                      overflow: TextOverflow.ellipsis),
                                ])),
                            GestureDetector(
                              onTap: () {
                                if (track == null) return;
                                context.read<PlaylistProvider>().toggleLike(
                                    DeezerTrack(
                                        id: track.id,
                                        title: track.title,
                                        artist: track.artist,
                                        artistId: '',
                                        album: track.album,
                                        albumArt: track.artworkUrl,
                                        previewUrl: track.url,
                                        durationSec: 0,
                                        rank: 0));
                              },
                              child: Consumer<PlaylistProvider>(
                                builder: (context, pp, _) {
                                  final liked =
                                      track != null && pp.isLiked(track.id);
                                  return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: liked
                                              ? AppColors.purple
                                                  .withOpacity(0.2)
                                              : AppColors.surface,
                                          border: Border.all(
                                              color: liked
                                                  ? AppColors.purple2
                                                  : AppColors.border)),
                                      child: Icon(
                                          liked
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          color: liked
                                              ? AppColors.purple3
                                              : AppColors.textThird,
                                          size: 20));
                                },
                              ),
                            ),
                          ]),
                          SizedBox(height: vGap),
                          StreamBuilder<Duration>(
                            stream: service.positionStream,
                            builder: (context, snapshot) {
                              final pos = snapshot.data ?? Duration.zero;
                              final dur = service.duration;
                              final progress = dur.inMilliseconds > 0
                                  ? (pos.inMilliseconds / dur.inMilliseconds)
                                      .clamp(0.0, 1.0)
                                  : 0.0;
                              return Column(children: [
                                SliderTheme(
                                    data: SliderThemeData(
                                        trackHeight: 3,
                                        thumbShape: const RoundSliderThumbShape(
                                            enabledThumbRadius: 6),
                                        overlayShape:
                                            const RoundSliderOverlayShape(
                                                overlayRadius: 12),
                                        activeTrackColor: AppColors.purple,
                                        inactiveTrackColor: AppColors.surface2,
                                        thumbColor: Colors.white,
                                        overlayColor:
                                            AppColors.purple.withOpacity(0.2)),
                                    child: Slider(
                                        value: progress,
                                        onChanged: (v) =>
                                            service.seekToProgress(v))),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          AudioPlayerService.formatDuration(
                                              pos),
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textThird)),
                                      Text(
                                          AudioPlayerService.formatDuration(
                                              dur),
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textThird)),
                                    ]),
                              ]);
                            },
                          ),
                          SizedBox(height: vGap),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      setState(
                                          () => _isShuffling = !_isShuffling);
                                      if (_isShuffling) service.shuffle();
                                    },
                                    child: Icon(Icons.shuffle_rounded,
                                        size: 22,
                                        color: _isShuffling
                                            ? AppColors.purple3
                                            : AppColors.textThird)),
                                GestureDetector(
                                    onTap: () => service.playPrevious(),
                                    child: Container(
                                        width: prevSize,
                                        height: prevSize,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.surface,
                                            border: Border.all(
                                                color: AppColors.border)),
                                        child: const Icon(
                                            Icons.skip_previous_rounded,
                                            color: AppColors.textSecond,
                                            size: 24))),
                                GestureDetector(
                                    onTap: () => service.togglePlay(),
                                    child: Container(
                                        width: btnSize,
                                        height: btnSize,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: AppColors.primaryGradient,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: AppColors.purple
                                                      .withOpacity(0.55),
                                                  blurRadius: 24,
                                                  offset: const Offset(0, 6))
                                            ]),
                                        child: service.isLoading
                                            ? const Center(
                                                child: SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                            color: Colors.white,
                                                            strokeWidth: 2)))
                                            : Icon(
                                                isPlaying
                                                    ? Icons.pause_rounded
                                                    : Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 32))),
                                GestureDetector(
                                    onTap: () => service.playNext(),
                                    child: Container(
                                        width: prevSize,
                                        height: prevSize,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.surface,
                                            border: Border.all(
                                                color: AppColors.border)),
                                        child: const Icon(
                                            Icons.skip_next_rounded,
                                            color: AppColors.textSecond,
                                            size: 24))),
                                GestureDetector(
                                    onTap: () => service.setLoopMode(
                                        service.loopMode == LoopMode.off
                                            ? LoopMode.one
                                            : LoopMode.off),
                                    child: Icon(Icons.repeat_rounded,
                                        size: 22,
                                        color: service.loopMode != LoopMode.off
                                            ? AppColors.purple3
                                            : AppColors.textThird)),
                              ]),
                          SizedBox(height: vGap),
                          StreamBuilder<double>(
                            stream: Stream.periodic(
                                const Duration(milliseconds: 100),
                                (_) => service.volume),
                            initialData: service.volume,
                            builder: (context, snapshot) {
                              final vol = snapshot.data ?? 1.0;
                              return Row(children: [
                                const Icon(Icons.volume_down_rounded,
                                    color: AppColors.textThird, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: SliderTheme(
                                        data: SliderThemeData(
                                            trackHeight: 3,
                                            thumbShape:
                                                const RoundSliderThumbShape(
                                                    enabledThumbRadius: 6),
                                            overlayShape:
                                                const RoundSliderOverlayShape(
                                                    overlayRadius: 12),
                                            activeTrackColor: AppColors.purple,
                                            inactiveTrackColor:
                                                AppColors.surface2,
                                            thumbColor: Colors.white,
                                            overlayColor: AppColors.purple
                                                .withOpacity(0.2)),
                                        child: Slider(
                                            value: vol.clamp(0.0, 1.0),
                                            onChanged: (v) =>
                                                service.setVolume(v)))),
                                const SizedBox(width: 8),
                                const Icon(Icons.volume_up_rounded,
                                    color: AppColors.textThird, size: 18),
                              ]);
                            },
                          ),
                          SizedBox(height: isSmall ? 4 : 12),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _ActionBtn(
                                    icon: Icons.queue_music_rounded,
                                    label: l.queue,
                                    onTap: () => context.push(AppRoutes.queue)),
                                _ActionBtn(
                                    icon: Icons.lyrics_outlined,
                                    label: l.lyrics,
                                    onTap: () =>
                                        context.push(AppRoutes.lyrics)),
                                _ActionBtn(
                                    icon: Icons.share_outlined,
                                    label: 'Share',
                                    onTap: _share),
                                _ActionBtn(
                                    icon: Icons.add_to_photos_outlined,
                                    label: l.playlists,
                                    onTap: () => _showAddToPlaylist(l)),
                              ]),
                        ]),
                      ),
                    ),
                    SizedBox(height: isSmall ? 8 : 20),
                  ]),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildVinyl() => Container(
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(colors: [
              Color(0xFF1a1a2e),
              Color(0xFF7C3AED),
              Color(0xFF9D5CF6),
              Color(0xFF2a1f4a),
              Color(0xFF4a2f8a),
              Color(0xFF6d40cc),
              Color(0xFF1a1230),
              Color(0xFF3a2060),
              Color(0xFF7C3AED),
              Color(0xFF1a0d30),
              Color(0xFF1a1a2e)
            ])),
        child: Center(
            child: Image.asset(AppConstants.cat3,
                width: 90, height: 90, fit: BoxFit.contain)),
      );
}

class _RealPlaylistSheet extends StatefulWidget {
  final FeevoTrack track;
  final PlaylistProvider provider;
  final AppLocalizations l;
  const _RealPlaylistSheet(
      {required this.track, required this.provider, required this.l});
  @override
  State<_RealPlaylistSheet> createState() => _RealPlaylistSheetState();
}

class _RealPlaylistSheetState extends State<_RealPlaylistSheet> {
  final Set<String> _added = {};
  @override
  Widget build(BuildContext context) {
    final playlists = widget.provider.playlists;
    final l = widget.l;
    return Container(
      decoration: const BoxDecoration(
          color: Color(0xFF0F0F22),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999))),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('${l.addToPlaylist} 🎵',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(l.myPlaylists,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecond))
              ]))
        ]),
        const SizedBox(height: 16),
        ...playlists.map((playlist) {
          final isAdded = _added.contains(playlist.id);
          return GestureDetector(
            onTap: () async {
              if (isAdded) return;
              setState(() => _added.add(playlist.id));
              final deezerTrack = DeezerTrack(
                  id: widget.track.id,
                  title: widget.track.title,
                  artist: widget.track.artist,
                  artistId: '',
                  album: widget.track.album,
                  albumArt: widget.track.artworkUrl,
                  previewUrl: widget.track.url,
                  durationSec: 0,
                  rank: 0);
              await widget.provider
                  .addTrackToPlaylist(playlist.id, deezerTrack);
              if (mounted)
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Added to "${playlist.name}" ✓'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                  gradient: isAdded
                      ? LinearGradient(colors: [
                          AppColors.purple.withOpacity(0.2),
                          AppColors.cyan.withOpacity(0.08)
                        ])
                      : null,
                  color: isAdded ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: isAdded ? AppColors.purple2 : AppColors.border,
                      width: isAdded ? 1.5 : 1)),
              child: Row(children: [
                Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        gradient: LinearGradient(colors: [
                          AppColors.purple.withOpacity(isAdded ? 0.5 : 0.3),
                          AppColors.cyan.withOpacity(0.2)
                        ])),
                    child: Center(
                        child: Text(playlist.emoji,
                            style: const TextStyle(fontSize: 20)))),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(playlist.name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary))),
                AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isAdded ? AppColors.primaryGradient : null,
                        color: isAdded ? null : AppColors.surface2,
                        border: isAdded
                            ? null
                            : Border.all(color: AppColors.border)),
                    child: Icon(
                        isAdded ? Icons.check_rounded : Icons.add_rounded,
                        color: isAdded ? Colors.white : AppColors.textThird,
                        size: 14)),
              ]),
            ),
          );
        }),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: AppColors.border)),
              child: Icon(icon, color: AppColors.textSecond, size: 20)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 9, color: AppColors.textThird)),
        ]),
      );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.purple.withOpacity(0.04)
      ..strokeWidth = 1;
    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
