import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/bottom_nav_widget.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/playlist_provider.dart';
import '../../core/services/audio_player_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _catController, _floatController, _contentController;
  late Animation<double> _catScale, _catOpacity, _catFloat, _contentOpacity;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _catController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _catScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _catController, curve: Curves.elasticOut));
    _catOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _catController, curve: Curves.easeIn));
    _floatController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3500))
      ..repeat(reverse: true);
    _catFloat = Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _contentController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _contentController, curve: Curves.easeOutCubic));
    _catController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _contentController.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchProfile();
      context.read<PlaylistProvider>().fetchPlaylists();
      context.read<PlaylistProvider>().fetchLikedSongs();
    });
  }

  @override
  void dispose() {
    _catController.dispose();
    _floatController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().signOut();
    context.read<UserProvider>().clear();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(
              top: -120,
              left: -80,
              child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppColors.purple.withOpacity(0.15),
                        AppColors.purple.withOpacity(0)
                      ])))),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: Consumer2<UserProvider, PlaylistProvider>(
                        builder: (context, up, pp, _) {
                          final user = up.user;
                          final initial = user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : '?';
                          return ListView(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(l.profile,
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                            letterSpacing: -0.3)),
                                    GestureDetector(
                                        onTap: () =>
                                            context.push(AppRoutes.settings),
                                        child: Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                                color: AppColors.surface,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: AppColors.border)),
                                            child: const Icon(
                                                Icons.settings_outlined,
                                                color: AppColors.textSecond,
                                                size: 18))),
                                  ]),
                              const SizedBox(height: 20),

                              // profile card
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.purple.withOpacity(0.2),
                                          AppColors.cyan.withOpacity(0.08)
                                        ]),
                                    borderRadius: BorderRadius.circular(22),
                                    border:
                                        Border.all(color: AppColors.border2)),
                                child: Column(children: [
                                  Row(children: [
                                    Stack(children: [
                                      Container(
                                          width: 72,
                                          height: 72,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient:
                                                  AppColors.primaryGradient,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: AppColors.purple
                                                        .withOpacity(0.4),
                                                    blurRadius: 16,
                                                    offset: const Offset(0, 6))
                                              ]),
                                          child: up.isLoading
                                              ? const Center(
                                                  child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                              strokeWidth: 2)))
                                              : Center(
                                                  child: Text(initial,
                                                      style: const TextStyle(
                                                          fontSize: 28,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color:
                                                              Colors.white)))),
                                      Positioned(
                                          bottom: -2,
                                          right: -2,
                                          child: AnimatedBuilder(
                                            animation: Listenable.merge([
                                              _catController,
                                              _floatController
                                            ]),
                                            builder: (_, __) => Opacity(
                                                opacity: _catOpacity.value,
                                                child: Transform.scale(
                                                    scale: _catScale.value,
                                                    child: Transform.translate(
                                                        offset: Offset(
                                                            0,
                                                            _catFloat.value *
                                                                0.5),
                                                        child: Image.asset(
                                                            AppConstants.cat4,
                                                            width: 36,
                                                            height: 36,
                                                            fit: BoxFit
                                                                .contain)))),
                                          )),
                                    ]),
                                    const SizedBox(width: 14),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Text(user?.name ?? '...',
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.textPrimary,
                                                  letterSpacing: -0.3)),
                                          const SizedBox(height: 2),
                                          Text(user?.email ?? '...',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textSecond)),
                                          const SizedBox(height: 6),
                                          Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                  color: AppColors.surface,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          999),
                                                  border: Border.all(
                                                      color: AppColors.border)),
                                              child: Text(
                                                  user?.isPremium == true
                                                      ? '⚡ ${l.premium}'
                                                      : '🎵 ${l.freePlan}',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          AppColors.textSecond,
                                                      fontWeight:
                                                          FontWeight.w500))),
                                        ])),
                                    GestureDetector(
                                        onTap: () =>
                                            context.push(AppRoutes.editProfile),
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 7),
                                            decoration: BoxDecoration(
                                                gradient:
                                                    AppColors.primaryGradient,
                                                borderRadius:
                                                    BorderRadius.circular(999)),
                                            child: const Text('Edit',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white)))),
                                  ]),
                                  const SizedBox(height: 16),
                                  Row(children: [
                                    _Stat('${pp.likedSongs.length}', l.liked),
                                    _Sep(),
                                    _Stat(
                                        '${pp.playlists.length}', l.playlists),
                                    _Sep(),
                                    _Stat('0', l.memories),
                                    _Sep(),
                                    _Stat('0', l.rooms),
                                  ]),
                                ]),
                              ),

                              const SizedBox(height: 16),

                              // premium banner
                              if (user?.isPremium != true)
                                GestureDetector(
                                  onTap: () => context.push(AppRoutes.premium),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [
                                          Color(0xFF7C3AED),
                                          Color(0xFF06B6D4)
                                        ]),
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                              color: AppColors.purple
                                                  .withOpacity(0.4),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6))
                                        ]),
                                    child: Row(children: [
                                      const Text('⚡',
                                          style: TextStyle(fontSize: 28)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Text(l.upgradeToPremium,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white)),
                                            const SizedBox(height: 2),
                                            const Text(
                                                'Unlimited music, AI features & more',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white70)),
                                          ])),
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(999)),
                                          child: Text(l.tryFree,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white))),
                                    ]),
                                  ),
                                ),

                              const SizedBox(height: 20),

                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('❤️ ${l.likedSongs}',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary)),
                                    Text('${pp.likedSongs.length} songs',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecond)),
                                  ]),
                              const SizedBox(height: 10),

                              if (pp.isLoadingLiked)
                                const Center(
                                    child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 20),
                                        child: CircularProgressIndicator(
                                            color: AppColors.purple,
                                            strokeWidth: 2)))
                              else if (pp.likedSongs.isEmpty)
                                Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: AppColors.border)),
                                    child: Center(
                                        child: Text(l.noLikedSongs,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecond,
                                                height: 1.6),
                                            textAlign: TextAlign.center)))
                              else
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border:
                                          Border.all(color: AppColors.border)),
                                  child: Column(
                                    children: pp.likedSongs
                                        .take(5)
                                        .toList()
                                        .asMap()
                                        .entries
                                        .map((e) {
                                      final i = e.key;
                                      final song = e.value;
                                      final track = song.toDeezerTrack();
                                      return GestureDetector(
                                        onTap: () {
                                          final tracks = pp.likedSongs
                                              .map((s) => FeevoTrack(
                                                  id: s.trackId,
                                                  title: s.title,
                                                  artist: s.artist,
                                                  album: s.album,
                                                  emoji: '🎵',
                                                  url: s.previewUrl ?? '',
                                                  artworkUrl: s.albumArt))
                                              .toList();
                                          context
                                              .read<AudioPlayerService>()
                                              .playQueue(tracks, startIndex: i);
                                          context.push(AppRoutes.nowPlaying);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                              border: i <
                                                      pp.likedSongs
                                                              .take(5)
                                                              .length -
                                                          1
                                                  ? const Border(
                                                      bottom: BorderSide(
                                                          color:
                                                              AppColors.border))
                                                  : null),
                                          child: Row(children: [
                                            ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: song.albumArt != null
                                                    ? Image.network(song.albumArt!,
                                                        width: 40,
                                                        height: 40,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => Container(
                                                            width: 40,
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                        colors: [
                                                                  AppColors
                                                                      .purple
                                                                      .withOpacity(
                                                                          0.5),
                                                                  AppColors.cyan
                                                                      .withOpacity(
                                                                          0.3)
                                                                ])),
                                                            child: const Center(child: Text('🎵', style: TextStyle(fontSize: 18)))))
                                                    : Container(width: 40, height: 40, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.purple.withOpacity(0.5), AppColors.cyan.withOpacity(0.3)])), child: const Center(child: Text('🎵', style: TextStyle(fontSize: 18))))),
                                            const SizedBox(width: 10),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Text(song.title,
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppColors
                                                              .textPrimary),
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                  Text(song.artist,
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: AppColors
                                                              .textSecond)),
                                                ])),
                                            GestureDetector(
                                                onTap: () =>
                                                    pp.toggleLike(track),
                                                child: const Icon(
                                                    Icons.favorite_rounded,
                                                    color: AppColors.purple3,
                                                    size: 18)),
                                          ]),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),

                              if (pp.likedSongs.length > 5) ...[
                                const SizedBox(height: 8),
                                GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: AppColors.border)),
                                        child: Center(
                                            child: Text(
                                                '${l.seeAll} ${pp.likedSongs.length} songs →',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.purple3,
                                                    fontWeight:
                                                        FontWeight.w600))))),
                              ],

                              const SizedBox(height: 20),

                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('🎵 ${l.myPlaylists}',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary)),
                                    GestureDetector(
                                        onTap: () =>
                                            _showCreatePlaylist(context, pp, l),
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                                gradient:
                                                    AppColors.primaryGradient,
                                                borderRadius:
                                                    BorderRadius.circular(999)),
                                            child: const Text('+ New',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white)))),
                                  ]),
                              const SizedBox(height: 10),

                              if (pp.isLoadingPlaylists)
                                const Center(
                                    child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 20),
                                        child: CircularProgressIndicator(
                                            color: AppColors.purple,
                                            strokeWidth: 2)))
                              else if (pp.playlists.isEmpty)
                                Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: AppColors.border)),
                                    child: Center(
                                        child: Text(l.noPlaylists,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecond,
                                                height: 1.6),
                                            textAlign: TextAlign.center)))
                              else
                                ...pp.playlists.map((playlist) =>
                                    GestureDetector(
                                      onTap: () => context.push(
                                          '${AppRoutes.playlist}?id=${playlist.id}'),
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                                color: AppColors.border)),
                                        child: Row(children: [
                                          Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  gradient: AppColors
                                                      .primaryGradient),
                                              child: Center(
                                                  child: Text(playlist.emoji,
                                                      style: const TextStyle(
                                                          fontSize: 22)))),
                                          const SizedBox(width: 12),
                                          Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                Text(playlist.name,
                                                    style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColors
                                                            .textPrimary)),
                                                Text(
                                                    playlist.description ??
                                                        'Playlist',
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color: AppColors
                                                            .textSecond)),
                                              ])),
                                          GestureDetector(
                                              onTap: () => _confirmDelete(
                                                  context,
                                                  pp,
                                                  playlist.id,
                                                  playlist.name,
                                                  l),
                                              child: const Icon(
                                                  Icons.more_horiz_rounded,
                                                  color: AppColors.textThird,
                                                  size: 20)),
                                        ]),
                                      ),
                                    )),

                              const SizedBox(height: 20),

                              const Text('Your Top Genres',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 10),
                              Row(children: [
                                _Genre('🎹', 'Electronic', 42),
                                const SizedBox(width: 8),
                                _Genre('🌙', 'Lo-Fi', 28),
                                const SizedBox(width: 8),
                                _Genre('🔥', 'Pop', 18),
                              ]),

                              const SizedBox(height: 20),
                              Text(l.account.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textThird,
                                      letterSpacing: 1.5)),
                              const SizedBox(height: 8),
                              _Item(Icons.person_outline_rounded, l.editProfile,
                                  () => context.push(AppRoutes.editProfile)),
                              _Item(
                                  Icons.notifications_outlined,
                                  l.notifications,
                                  () => context.push(AppRoutes.notifications)),
                              _Item(Icons.language_outlined, l.language,
                                  () => context.push(AppRoutes.language)),

                              const SizedBox(height: 16),
                              Text(l.more.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textThird,
                                      letterSpacing: 1.5)),
                              const SizedBox(height: 8),
                              _Item(Icons.star_outline_rounded, l.rateFeevo,
                                  () {}),
                              _Item(Icons.share_outlined, l.shareWithFriends,
                                  () {}),
                              _Item(Icons.help_outline_rounded, l.helpSupport,
                                  () {}),

                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: _logout,
                                child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    decoration: BoxDecoration(
                                        color: AppColors.errorBg,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: AppColors.error
                                                .withOpacity(0.3))),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.logout_rounded,
                                              color: AppColors.error, size: 18),
                                          const SizedBox(width: 8),
                                          Text(l.logout,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.error))
                                        ])),
                              ),
                              const SizedBox(height: 8),
                              const Center(
                                  child: Text('Feevo v1.0.0 · feevo.music',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textThird))),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const FeevoBottomNav(currentIndex: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylist(
      BuildContext context, PlaylistProvider pp, AppLocalizations l) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
              color: Color(0xFF0F0F22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999))),
            const SizedBox(height: 16),
            Text(l.newPlaylist,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            Container(
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border)),
                child: TextField(
                    controller: ctrl,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                        hintText: 'Playlist name...',
                        hintStyle:
                            TextStyle(fontSize: 12, color: AppColors.textThird),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14)))),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                if (ctrl.text.trim().isEmpty) return;
                await pp.createPlaylist(ctrl.text.trim());
                if (mounted) Navigator.pop(context);
              },
              child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14)),
                  child: Center(
                      child: Text(l.createPlaylist,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)))),
            ),
          ]),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, PlaylistProvider pp, String id,
      String name, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
            color: Color(0xFF0F0F22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999))),
          const SizedBox(height: 16),
          Text('"$name"',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Delete this playlist?',
              style: TextStyle(fontSize: 13, color: AppColors.textSecond)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border)),
                        child: Center(
                            child: Text(l.cancel,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecond)))))),
            const SizedBox(width: 10),
            Expanded(
                child: GestureDetector(
                    onTap: () async {
                      await pp.deletePlaylist(id);
                      if (mounted) Navigator.pop(context);
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.3))),
                        child: Center(
                            child: Text(l.delete,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.error)))))),
          ]),
        ]),
      ),
    );
  }
}

Widget _Stat(String v, String l) => Expanded(
        child: Column(children: [
      Text(v,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary)),
      Text(l, style: const TextStyle(fontSize: 9, color: AppColors.textThird))
    ]));
Widget _Sep() => Container(width: 1, height: 30, color: AppColors.border);
Widget _Genre(String e, String l, int p) => Expanded(
    child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.purple.withOpacity(0.15),
              AppColors.cyan.withOpacity(0.07)
            ]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border2)),
        child: Column(children: [
          Text(e, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(l,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          Text('$p%',
              style: const TextStyle(fontSize: 9, color: AppColors.purple3))
        ])));
Widget _Item(IconData icon, String label, VoidCallback onTap,
        {String? value}) =>
    GestureDetector(
        onTap: onTap,
        child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppColors.purple.withOpacity(0.2),
                        AppColors.cyan.withOpacity(0.1)
                      ]),
                      borderRadius: BorderRadius.circular(9)),
                  child: Icon(icon, color: AppColors.purple3, size: 16)),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary))),
              if (value != null) ...[
                Text(value,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecond)),
                const SizedBox(width: 6)
              ],
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textThird, size: 18)
            ])));

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
