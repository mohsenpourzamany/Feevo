import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/bottom_nav_widget.dart';
import '../../core/services/audio_player_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _vinylController;
  late AnimationController _catController;
  late AnimationController _floatController;
  late AnimationController _contentController;

  late Animation<double> _catScale;
  late Animation<double> _catOpacity;
  late Animation<double> _catFloat;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playEntrance();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = context.read<AudioPlayerService>();
      if (service.currentTrack == null) {
        // فقط queue رو load می‌کنیم، پلی نمی‌کنیم
        service.loadQueue(FeevoTrack.mockTracks);
      }
    });
  }

  void _setupAnimations() {
    _vinylController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _catController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _catScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _catController, curve: Curves.elasticOut),
    );
    _catOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _catController, curve: Curves.easeIn),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _catFloat = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
  }

  void _playEntrance() {
    _catController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _vinylController.dispose();
    _catController.dispose();
    _floatController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(
            top: -120, left: -80,
            child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.purple.withOpacity(0.15), AppColors.purple.withOpacity(0)]))),
          ),
          Positioned(
            bottom: -60, right: -60,
            child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.cyan.withOpacity(0.08), AppColors.cyan.withOpacity(0)]))),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        children: [
                          _buildGreeting(),
                          const SizedBox(height: 16),
                          _buildNowPlaying(),
                          const SizedBox(height: 20),
                          _buildMoodStrip(),
                          const SizedBox(height: 20),
                          _buildRecentlyPlayed(),
                          const SizedBox(height: 20),
                          _buildLiveRooms(),
                        ],
                      ),
                    ),
                  ),
                ),
                const FeevoBottomNav(currentIndex: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_catController, _floatController]),
          builder: (_, __) => Opacity(
            opacity: _catOpacity.value,
            child: Transform.scale(
              scale: _catScale.value,
              child: Transform.translate(
                offset: Offset(0, _catFloat.value),
                child: Container(
                  decoration: BoxDecoration(boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))]),
                  child: Image.asset(AppConstants.cat4, width: 64, height: 64, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Good evening 🌙', style: TextStyle(fontSize: 11, color: AppColors.textSecond)),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(children: [
                  const TextSpan(text: 'Hey, ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3)),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: ShaderMask(
                      shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                      child: const Text('Barad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3)),
                    ),
                  ),
                  const TextSpan(text: ' 👋', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ]),
              ),
              const SizedBox(height: 2),
              const Text('⚡ Feeling energetic today!', style: TextStyle(fontSize: 11, color: AppColors.purple3)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.notifications),
          child: Stack(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.notifications_outlined, color: AppColors.textSecond, size: 20),
            ),
            Positioned(top: 8, right: 8, child: Container(width: 7, height: 7, decoration: BoxDecoration(color: AppColors.purple, shape: BoxShape.circle, border: Border.all(color: AppColors.bg, width: 1.5)))),
          ]),
        ),
      ],
    );
  }

  Widget _buildNowPlaying() {
    return Consumer<AudioPlayerService>(
      builder: (context, service, _) {
        final track = service.currentTrack;
        final isPlaying = service.isPlaying;

        if (isPlaying && !_vinylController.isAnimating) {
          _vinylController.repeat();
        } else if (!isPlaying && _vinylController.isAnimating) {
          _vinylController.stop();
        }

        return GestureDetector(
          onTap: () => context.push(AppRoutes.nowPlaying),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.purple.withOpacity(0.22), AppColors.cyan.withOpacity(0.1)]),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _vinylController,
                      builder: (_, child) => Transform.rotate(
                        angle: isPlaying ? _vinylController.value * 2 * 3.14159 : 0,
                        child: child,
                      ),
                      child: Container(
                        width: 54, height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const SweepGradient(colors: [Color(0xFF1a1a2e), Color(0xFF7C3AED), Color(0xFF9D5CF6), Color(0xFF2a1f4a), Color(0xFF4a2f8a), Color(0xFF6d40cc), Color(0xFF1a1230), Color(0xFF3a2060), Color(0xFF7C3AED), Color(0xFF1a0d30), Color(0xFF1a1a2e)]),
                          boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.5), blurRadius: 16)],
                        ),
                        child: Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.purple3, AppColors.purple])))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPlaying ? '▶ NOW PLAYING' : '⏸ PAUSED',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.cyan2, letterSpacing: 2),
                          ),
                          const SizedBox(height: 3),
                          Text(track?.title ?? 'Tap play to start', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                          Text(track != null ? '${track.artist} · ${track.album}' : '', style: const TextStyle(fontSize: 11, color: AppColors.textSecond)),
                        ],
                      ),
                    ),
                    _WaveIndicator(isPlaying: isPlaying),
                  ],
                ),
                const SizedBox(height: 12),

                StreamBuilder<Duration>(
                  stream: service.positionStream,
                  builder: (context, snapshot) {
                    final pos = snapshot.data ?? Duration.zero;
                    final dur = service.duration;
                    final progress = dur.inMilliseconds > 0 ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0) : 0.0;
                    return Column(children: [
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: AppColors.purple,
                          inactiveTrackColor: AppColors.surface2,
                          thumbColor: Colors.white,
                          overlayColor: AppColors.purple.withOpacity(0.2),
                        ),
                        child: Slider(value: progress.toDouble(), onChanged: (v) => service.seekToProgress(v)),
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(AudioPlayerService.formatDuration(pos), style: const TextStyle(fontSize: 9, color: AppColors.textThird)),
                        Text(AudioPlayerService.formatDuration(dur), style: const TextStyle(fontSize: 9, color: AppColors.textThird)),
                      ]),
                    ]);
                  },
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ControlBtn(icon: Icons.skip_previous_rounded, size: 28, onTap: () => service.playPrevious()),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => service.togglePlay(),
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient, boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 4))]),
                        child: service.isLoading
                            ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                            : Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 26),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _ControlBtn(icon: Icons.skip_next_rounded, size: 28, onTap: () => service.playNext()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoodStrip() {
    final moods = AppConstants.moods;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('🌊 Mood Flow', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          GestureDetector(onTap: () => context.go(AppRoutes.moodFlow), child: const Text('See all', style: TextStyle(fontSize: 11, color: AppColors.purple3))),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: moods.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final active = i == 0;
              return GestureDetector(
                onTap: () => context.go(AppRoutes.moodFlow),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    gradient: active ? LinearGradient(colors: [AppColors.purple.withOpacity(0.25), AppColors.cyan.withOpacity(0.12)]) : null,
                    color: active ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: active ? AppColors.purple2 : AppColors.border),
                  ),
                  child: Center(child: Text('${moods[i]['emoji']} ${moods[i]['label']}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: active ? AppColors.purple3 : AppColors.textSecond))),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyPlayed() {
    final albums = [
      {'title': 'Hurry Up Tomorrow', 'artist': 'The Weeknd', 'emoji': '🎵', 'colors': [const Color(0xFF7C3AED), const Color(0xFF06B6D4)]},
      {'title': 'The Slow Rush',     'artist': 'Tame Impala', 'emoji': '🎸', 'colors': [const Color(0xFF0891B2), const Color(0xFF7C3AED)]},
      {'title': 'After Hours',       'artist': 'The Weeknd', 'emoji': '🌙', 'colors': [const Color(0xFF4C1D95), const Color(0xFF06B6D4)]},
      {'title': 'SOS',               'artist': 'SZA',        'emoji': '💗', 'colors': [const Color(0xFFBE185D), const Color(0xFF7C3AED)]},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('🎵 Recently Played', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          GestureDetector(onTap: () => context.push(AppRoutes.playlist), child: const Text('See all', style: TextStyle(fontSize: 11, color: AppColors.purple3))),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: albums.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final album = albums[i];
              final colors = album['colors'] as List<Color>;
              return GestureDetector(
                onTap: () => context.push(AppRoutes.nowPlaying),
                child: SizedBox(
                  width: 92,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 92, height: 92,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors), boxShadow: [BoxShadow(color: colors.first.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
                      child: Center(child: Text(album['emoji'] as String, style: const TextStyle(fontSize: 36))),
                    ),
                    const SizedBox(height: 7),
                    Text(album['title'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                    Text(album['artist'] as String, style: const TextStyle(fontSize: 10, color: AppColors.textSecond), overflow: TextOverflow.ellipsis),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLiveRooms() {
    final rooms = [
      {'name': 'Late Night Chill', 'track': 'Tame Impala',  'listeners': '241',  'emoji': '🌙', 'color': const Color(0xFF4C1D95)},
      {'name': 'Friday Hype',      'track': 'Travis Scott', 'listeners': '1.2k', 'emoji': '🔥', 'color': const Color(0xFFC2410C)},
      {'name': 'Study With Me',    'track': 'Lo-Fi Beats',  'listeners': '892',  'emoji': '🎹', 'color': const Color(0xFF1D4ED8)},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('🏠 Live Rooms', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          GestureDetector(onTap: () => context.go(AppRoutes.liveRooms), child: const Text('See all', style: TextStyle(fontSize: 11, color: AppColors.purple3))),
        ]),
        const SizedBox(height: 10),
        ...rooms.map((room) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.liveRoomIn),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), gradient: LinearGradient(colors: [room['color'] as Color, AppColors.purple])),
                  child: Center(child: Text(room['emoji'] as String, style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(room['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text(room['track'] as String, style: const TextStyle(fontSize: 10, color: AppColors.textSecond)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.error.withOpacity(0.3))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.error)),
                      const SizedBox(width: 3),
                      const Text('LIVE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.error, letterSpacing: 1)),
                    ]),
                  ),
                  const SizedBox(height: 4),
                  Text('${room['listeners']} 🎧', style: const TextStyle(fontSize: 10, color: AppColors.textThird)),
                ]),
              ]),
            ),
          ),
        )),
      ],
    );
  }
}

class _WaveIndicator extends StatefulWidget {
  final bool isPlaying;
  const _WaveIndicator({required this.isPlaying});
  @override
  State<_WaveIndicator> createState() => _WaveIndicatorState();
}

class _WaveIndicatorState extends State<_WaveIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(8, (i) => AnimationController(vsync: this, duration: Duration(milliseconds: 600 + i * 80))..repeat(reverse: true));
    _animations  = _controllers.map((c) => Tween<double>(begin: 0.2, end: 1.0).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28, height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(8, (i) => AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) => Container(
            width: 2,
            height: widget.isPlaying ? 24 * _animations[i].value : 4,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: AppColors.primaryGradient),
          ),
        )),
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;
  const _ControlBtn({required this.icon, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surface),
        child: Icon(icon, color: AppColors.textSecond, size: size),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.purple.withOpacity(0.04)..strokeWidth = 1;
    const step = 44.0;
    for (double x = 0; x < size.width; x += step) { canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint); }
    for (double y = 0; y < size.height; y += step) { canvas.drawLine(Offset(0, y), Offset(size.width, y), paint); }
  }
  @override
  bool shouldRepaint(_GridPainter old) => false;
}
