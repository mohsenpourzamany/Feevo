import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/providers/playlist_provider.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/services/deezer_service.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});
  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen>
    with TickerProviderStateMixin {
  List<DeezerTrack> _tracks = [];
  bool _isLoading = true;
  Playlist? _playlist;

  late AnimationController _contentController, _headerController;
  late Animation<double> _contentOpacity, _headerScale;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _headerScale = Tween<double>(begin: 0.94, end: 1.0).animate(
        CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));
    _contentController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _contentController, curve: Curves.easeOutCubic));
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlaylist());
  }

  @override
  void dispose() {
    _contentController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaylist() async {
    final pp = context.read<PlaylistProvider>();
    final playlists = pp.playlists;
    if (playlists.isNotEmpty) {
      try {
        _playlist = playlists.firstWhere((p) => p.id == widget.playlistId);
      } catch (_) {}
    }
    final tracks = await pp.fetchPlaylistTracks(widget.playlistId);
    if (mounted)
      setState(() {
        _tracks = tracks;
        _isLoading = false;
      });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.purple,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1200),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        CustomScrollView(slivers: [
          SliverToBoxAdapter(
              child:
                  ScaleTransition(scale: _headerScale, child: _buildHeader(l))),
          SliverToBoxAdapter(
              child: SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                      opacity: _contentOpacity,
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 60),
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.purple, strokeWidth: 2)))
                          : _buildTrackList(l)))),
        ]),
      ]),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    final name = _playlist?.name ?? l.playlists;
    final emoji = _playlist?.emoji ?? '🎵';
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1a0535), Color(0xFF06060F)])),
      child: Stack(children: [
        Positioned(
            top: -80,
            right: -60,
            child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.purple.withOpacity(0.25),
                      AppColors.purple.withOpacity(0)
                    ])))),
        SafeArea(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(children: [
            Row(children: [
              GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15))),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16))),
              const Spacer(),
              GestureDetector(
                  onTap: () => _showSnackBar(l.comingSoon),
                  child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15))),
                      child: const Icon(Icons.more_horiz_rounded,
                          color: Colors.white, size: 18))),
            ]),
            const SizedBox(height: 20),
            Stack(alignment: Alignment.center, children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF4C1D95),
                          Color(0xFF7C3AED),
                          Color(0xFF0891B2)
                        ]),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.purple.withOpacity(0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 10))
                    ]),
                child: _tracks.isEmpty
                    ? Center(
                        child:
                            Text(emoji, style: const TextStyle(fontSize: 60)))
                    : Stack(
                        children: List.generate(
                            _minVal(4, _tracks.length),
                            (i) => Positioned(
                                top: (i ~/ 2) * 80.0 + 20,
                                left: (i % 2) * 80.0 + 20,
                                child: _tracks[i].albumArt != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                            _tracks[i].albumArt!,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover))
                                    : const Text('🎵',
                                        style: TextStyle(fontSize: 28))))),
              ),
              Positioned(
                  bottom: -10,
                  right: -10,
                  child: Image.asset(AppConstants.cat3,
                      width: 55, height: 55, fit: BoxFit.contain)),
            ]),
            const SizedBox(height: 16),
            Text(name,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('${_tracks.length} songs',
                style: const TextStyle(fontSize: 12, color: Colors.white60)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: GestureDetector(
                onTap: _tracks.isEmpty
                    ? null
                    : () {
                        final feevoTracks = _tracks
                            .map((t) => FeevoTrack(
                                id: t.id,
                                title: t.title,
                                artist: t.artist,
                                album: t.album,
                                emoji: '🎵',
                                url: t.previewUrl ?? '',
                                artworkUrl: t.albumArt))
                            .toList();
                        context
                            .read<AudioPlayerService>()
                            .playQueue(feevoTracks);
                        context.push(AppRoutes.nowPlaying);
                      },
                child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                        gradient:
                            _tracks.isEmpty ? null : AppColors.primaryGradient,
                        color: _tracks.isEmpty ? AppColors.surface : null,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: _tracks.isEmpty
                            ? []
                            : [
                                BoxShadow(
                                    color: AppColors.purple.withOpacity(0.4),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4))
                              ]),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              color: _tracks.isEmpty
                                  ? AppColors.textThird
                                  : Colors.white,
                              size: 22),
                          const SizedBox(width: 6),
                          Text(l.playAll,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _tracks.isEmpty
                                      ? AppColors.textThird
                                      : Colors.white))
                        ])),
              )),
              const SizedBox(width: 10),
              GestureDetector(
                  onTap: () => _showSnackBar('Shuffle on!'),
                  child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15))),
                      child: const Icon(Icons.shuffle_rounded,
                          color: Colors.white60, size: 20))),
            ]),
          ]),
        )),
      ]),
    );
  }

  Widget _buildTrackList(AppLocalizations l) {
    if (_tracks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
        child: Center(
            child: Column(children: [
          Image.asset(AppConstants.cat3, width: 80, height: 80),
          const SizedBox(height: 12),
          Text(l.noPlaylists,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Add songs from Now Playing → Playlist',
              style: TextStyle(fontSize: 12, color: AppColors.textSecond),
              textAlign: TextAlign.center),
        ])),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('TRACKS',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textThird,
                letterSpacing: 2)),
        const SizedBox(height: 10),
        ...List.generate(_tracks.length, (i) {
          final t = _tracks[i];
          return GestureDetector(
            onTap: () {
              final feevoTracks = _tracks
                  .map((dt) => FeevoTrack(
                      id: dt.id,
                      title: dt.title,
                      artist: dt.artist,
                      album: dt.album,
                      emoji: '🎵',
                      url: dt.previewUrl ?? '',
                      artworkUrl: dt.albumArt))
                  .toList();
              context
                  .read<AudioPlayerService>()
                  .playQueue(feevoTracks, startIndex: i);
              context.push(AppRoutes.nowPlaying);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border)),
              child: Row(children: [
                SizedBox(
                    width: 20,
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textThird),
                        textAlign: TextAlign.center)),
                const SizedBox(width: 10),
                ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: t.albumArt != null
                        ? Image.network(t.albumArt!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _artFallback())
                        : _artFallback()),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(t.title,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis),
                      Text(t.artist,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecond)),
                    ])),
                GestureDetector(
                  onTap: () async {
                    final pp = context.read<PlaylistProvider>();
                    await pp.removeTrackFromPlaylist(widget.playlistId, t.id);
                    setState(() => _tracks.removeAt(i));
                  },
                  child: const Icon(Icons.remove_circle_outline_rounded,
                      color: AppColors.textThird, size: 18),
                ),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  Widget _artFallback() => Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(colors: [
            AppColors.purple.withOpacity(0.4),
            AppColors.cyan.withOpacity(0.2)
          ])),
      child: const Center(child: Text('🎵', style: TextStyle(fontSize: 20))));

  int _minVal(int a, int b) => a < b ? a : b;
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
