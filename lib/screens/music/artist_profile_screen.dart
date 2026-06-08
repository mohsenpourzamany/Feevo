import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/providers/deezer_provider.dart';
import '../../core/services/deezer_service.dart';
import '../../core/services/audio_player_service.dart';

class ArtistProfileScreen extends StatefulWidget {
  final String artistId;
  const ArtistProfileScreen({super.key, required this.artistId});
  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen>
    with TickerProviderStateMixin {
  bool _isFollowing = false;
  int _selectedTab = 0;

  late AnimationController _contentController;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _contentController, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _contentController.forward();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.artistId.isNotEmpty)
        context.read<DeezerProvider>().loadArtist(widget.artistId);
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Consumer<DeezerProvider>(
      builder: (context, deezer, _) {
        final artist = deezer.currentArtist;
        final topTracks = deezer.artistTopTracks;
        final related = deezer.relatedArtists;
        final isLoading = deezer.isLoadingArtist;

        final tabs = [l.topCharts, 'Similar'];

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: const Color(0xFF0D0520),
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _buildHeaderBg(artist)),
              leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.4),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.15))),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 16)))),
              actions: [
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.4),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.15))),
                        child: const Icon(Icons.more_horiz_rounded,
                            color: Colors.white, size: 18)))
              ],
            ),
            SliverToBoxAdapter(
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.purple, strokeWidth: 2)))
                    : SlideTransition(
                        position: _contentSlide,
                        child: FadeTransition(
                            opacity: _contentOpacity,
                            child: Column(children: [
                              _buildActionButtons(l),
                              const SizedBox(height: 16),
                              if (artist != null) _buildStats(artist, l),
                              const SizedBox(height: 16),
                              _buildTabs(tabs),
                              const SizedBox(height: 12),
                              if (_selectedTab == 0)
                                _buildPopular(topTracks)
                              else
                                _buildSimilar(related),
                              const SizedBox(height: 40),
                            ])))),
          ]),
        );
      },
    );
  }

  Widget _buildHeaderBg(DeezerArtist? artist) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
            Color(0xFF1a0a40),
            Color(0xFF0891B2),
            Color(0xFF4C1D95)
          ])),
      child: Stack(children: [
        if (artist?.imageUrl != null)
          Positioned.fill(
              child: Image.network(artist!.imageUrl!,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.5),
                  colorBlendMode: BlendMode.darken,
                  errorBuilder: (_, __, ___) => const SizedBox())),
        Positioned(
            top: -40,
            right: -40,
            child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.cyan.withOpacity(0.25),
                      AppColors.cyan.withOpacity(0)
                    ])))),
        if (artist == null)
          Positioned(
              bottom: 80,
              right: 16,
              child: Image.asset(AppConstants.cat3,
                  width: 110, height: 110, fit: BoxFit.contain)),
        Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.cyan.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                      border:
                          Border.all(color: AppColors.cyan.withOpacity(0.4))),
                  child: const Text('✓ VERIFIED ARTIST',
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cyan2,
                          letterSpacing: 1.5))),
              const SizedBox(height: 6),
              Text(artist?.name ?? 'Loading...',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(color: Colors.black54, blurRadius: 10)
                      ])),
              if (artist != null)
                Text('${artist.fansFormatted} fans',
                    style:
                        const TextStyle(fontSize: 11, color: Colors.white70)),
            ])),
      ]),
    );
  }

  Widget _buildActionButtons(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        Expanded(
            child: GestureDetector(
          onTap: () => setState(() => _isFollowing = !_isFollowing),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44,
            decoration: BoxDecoration(
                gradient: _isFollowing ? null : AppColors.primaryGradient,
                color: _isFollowing ? AppColors.surface : null,
                borderRadius: BorderRadius.circular(999),
                border:
                    _isFollowing ? Border.all(color: AppColors.border) : null,
                boxShadow: _isFollowing
                    ? []
                    : [
                        BoxShadow(
                            color: AppColors.purple.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ]),
            child: Center(
                child: Text(_isFollowing ? '${l.liked} ✓' : l.invite,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _isFollowing
                            ? AppColors.textSecond
                            : Colors.white))),
          ),
        )),
        const SizedBox(width: 10),
        _IconBtn(icon: Icons.shuffle_rounded, onTap: () {}),
        const SizedBox(width: 8),
        _IconBtn(icon: Icons.share_outlined, onTap: () {}),
      ]),
    );
  }

  Widget _buildStats(DeezerArtist artist, AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        _StatItem(value: artist.fansFormatted, label: 'Fans'),
        Container(width: 1, height: 28, color: AppColors.border),
        _StatItem(value: '${artist.albumCount}', label: 'Albums'),
        Container(width: 1, height: 28, color: AppColors.border),
        const _StatItem(value: 'Artist', label: 'Type'),
      ]),
    );
  }

  Widget _buildTabs(List<String> tabs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border)),
        child: Row(
            children: List.generate(tabs.length, (i) {
          final active = _selectedTab == i;
          return Expanded(
              child: GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                  gradient: active ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: active
                      ? [
                          BoxShadow(
                              color: AppColors.purple.withOpacity(0.3),
                              blurRadius: 8)
                        ]
                      : []),
              child: Center(
                  child: Text(tabs[i],
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              active ? Colors.white : AppColors.textSecond))),
            ),
          ));
        })),
      ),
    );
  }

  Widget _buildPopular(List<DeezerTrack> tracks) {
    if (tracks.isEmpty)
      return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
              child: Text('No tracks found',
                  style: TextStyle(color: AppColors.textSecond))));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
          children: List.generate(tracks.length, (i) {
        final t = tracks[i];
        return GestureDetector(
          onTap: () {
            final feevoTracks = tracks
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
                gradient: i == 0
                    ? LinearGradient(colors: [
                        AppColors.purple.withOpacity(0.12),
                        AppColors.cyan.withOpacity(0.06)
                      ])
                    : null,
                color: i == 0 ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: i == 0 ? AppColors.border2 : AppColors.border)),
            child: Row(children: [
              SizedBox(
                  width: 24,
                  child: i == 0
                      ? const Icon(Icons.equalizer_rounded,
                          color: AppColors.purple3, size: 18)
                      : Text('${i + 1}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textThird),
                          textAlign: TextAlign.center)),
              const SizedBox(width: 10),
              ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: t.albumArt != null
                      ? Image.network(t.albumArt!,
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11),
                                  gradient: LinearGradient(colors: [
                                    AppColors.purple.withOpacity(0.5),
                                    AppColors.cyan.withOpacity(0.3)
                                  ])),
                              child: const Center(
                                  child: Text('🎵',
                                      style: TextStyle(fontSize: 20)))))
                      : Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                              gradient: LinearGradient(colors: [
                                AppColors.purple.withOpacity(0.5),
                                AppColors.cyan.withOpacity(0.3)
                              ])),
                          child: const Center(
                              child: Text('🎵', style: TextStyle(fontSize: 20))))),
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
                    Text(t.album.isNotEmpty ? t.album : t.artist,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecond)),
                  ])),
              Text(t.durationFormatted,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textThird)),
            ]),
          ),
        );
      })),
    );
  }

  Widget _buildSimilar(List<DeezerArtist> artists) {
    if (artists.isEmpty)
      return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
              child: Text('No similar artists found',
                  style: TextStyle(color: AppColors.textSecond))));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
          children: artists
              .map((a) => GestureDetector(
                    onTap: () => context.push('${AppRoutes.artist}?id=${a.id}'),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        ClipOval(
                            child: a.imageUrl != null
                                ? Image.network(a.imageUrl!,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                        width: 44,
                                        height: 44,
                                        color: AppColors.surface2,
                                        child: const Center(
                                            child: Text('🎤',
                                                style:
                                                    TextStyle(fontSize: 20)))))
                                : Container(
                                    width: 44,
                                    height: 44,
                                    color: AppColors.surface2,
                                    child: const Center(
                                        child: Text('🎤',
                                            style: TextStyle(fontSize: 20))))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(a.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              const Text('Artist',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecond)),
                            ])),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: AppColors.surface2,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.border)),
                            child: const Text('View',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecond))),
                      ]),
                    ),
                  ))
              .toList()),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.border)),
          child: Icon(icon, color: AppColors.textSecond, size: 18)));
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
          child: Column(children: [
        ShaderMask(
            shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
            child: Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white))),
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.textThird)),
      ]));
}
