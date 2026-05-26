import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {

  bool   _isPlaying   = true;
  bool   _isLiked     = false;
  double _progress    = 0.38;
  double _volume      = 0.7;
  bool   _isRepeating = false;
  bool   _isShuffling = false;

  // mock playlists
  final List<Map<String, dynamic>> _playlists = [
    {'name': 'Late Night Chill',   'emoji': '🌙', 'count': 24, 'added': false},
    {'name': 'Workout Bangers',    'emoji': '⚡', 'count': 18, 'added': false},
    {'name': 'Study Mode',         'emoji': '💭', 'count': 32, 'added': false},
    {'name': 'Friday Vibes',       'emoji': '🔥', 'count': 15, 'added': true},
    {'name': 'Road Trip Mix',      'emoji': '🚗', 'count': 41, 'added': false},
    {'name': 'Rainy Day Feels',    'emoji': '🌧', 'count': 12, 'added': false},
  ];

  late AnimationController _vinylController;
  late AnimationController _catController;
  late AnimationController _floatController;
  late AnimationController _contentController;
  late AnimationController _pulseController;

  late Animation<double> _catScale;
  late Animation<double> _catOpacity;
  late Animation<double> _catFloat;
  late Animation<double> _contentOpacity;
  late Animation<Offset>  _contentSlide;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playEntrance();
  }

  void _setupAnimations() {
    _vinylController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _catController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _catScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _catController, curve: Curves.elasticOut),
    );
    _catOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _catController, curve: Curves.easeIn),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _catFloat = Tween<double>(begin: 0, end: -10).animate(
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
      begin: const Offset(0, 0.08),
      end:   Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _playEntrance() {
    _catController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _vinylController.dispose();
    _catController.dispose();
    _floatController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _vinylController.repeat();
    } else {
      _vinylController.stop();
    }
  }

  // ── Share ─────────────────────────────────────────────────
  Future<void> _share() async {
    await Share.share(
      '🎵 I\'m listening to "Midnight City" by M83 on Feevo!\n\nJoin me: https://feevo.music',
      subject: 'Midnight City — M83',
    );
  }

  // ── Add to Playlist ───────────────────────────────────────
  void _showAddToPlaylist() {
    showModalBottomSheet(
      context:           context,
      backgroundColor:   Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddToPlaylistSheet(
        playlists: _playlists,
        onToggle:  (index) {
          setState(() {
            _playlists[index]['added'] = !_playlists[index]['added'];
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                  colors: [Color(0xFF0D0520), Color(0xFF06060F)],
                ),
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(
            top: -100, left: -80,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.purple.withOpacity(0.22),
                  AppColors.purple.withOpacity(0),
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -60, right: -60,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.cyan.withOpacity(0.1),
                  AppColors.cyan.withOpacity(0),
                ]),
              ),
            ),
          ),

          SafeArea(
            child: SlideTransition(
              position: _contentSlide,
              child: FadeTransition(
                opacity: _contentOpacity,
                child: Column(
                  children: [

                    // top bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color:        AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border:       Border.all(color: AppColors.border),
                              ),
                              child: const Icon(Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textSecond, size: 22),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'NOW PLAYING',
                            style: TextStyle(
                              fontSize:      10,
                              fontWeight:    FontWeight.w600,
                              color:         AppColors.textSecond,
                              letterSpacing: 2,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color:        AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border:       Border.all(color: AppColors.border),
                              ),
                              child: const Icon(Icons.more_horiz_rounded,
                                  color: AppColors.textSecond, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // vinyl + cat
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (_, __) => Transform.scale(
                                scale: _isPlaying ? _pulse.value : 1.0,
                                child: Container(
                                  width: 240, height: 240,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(colors: [
                                      AppColors.purple.withOpacity(0.3),
                                      AppColors.cyan.withOpacity(0.1),
                                      Colors.transparent,
                                    ]),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _vinylController,
                              builder: (_, child) => Transform.rotate(
                                angle: _vinylController.value * 2 * 3.14159,
                                child: child,
                              ),
                              child: Container(
                                width: 200, height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const SweepGradient(colors: [
                                    Color(0xFF1a1a2e), Color(0xFF7C3AED),
                                    Color(0xFF9D5CF6), Color(0xFF2a1f4a),
                                    Color(0xFF4a2f8a), Color(0xFF6d40cc),
                                    Color(0xFF1a1230), Color(0xFF3a2060),
                                    Color(0xFF7C3AED), Color(0xFF1a0d30),
                                    Color(0xFF1a1a2e),
                                  ]),
                                  boxShadow: [
                                    BoxShadow(
                                      color:        AppColors.purple.withOpacity(0.6),
                                      blurRadius:   40,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedBuilder(
                              animation: Listenable.merge([_catController, _floatController]),
                              builder: (_, __) => Opacity(
                                opacity: _catOpacity.value,
                                child: Transform.scale(
                                  scale: _catScale.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _catFloat.value),
                                    child: Image.asset(
                                      AppConstants.cat3,
                                      width:  90,
                                      height: 90,
                                      fit:    BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // controls
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          children: [

                            // track info
                            Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Midnight City',
                                        style: TextStyle(
                                          fontSize:      22,
                                          fontWeight:    FontWeight.w800,
                                          color:         AppColors.textPrimary,
                                          letterSpacing: -0.5,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        'M83 · Electronic',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color:    AppColors.textSecond,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _isLiked = !_isLiked),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _isLiked
                                          ? AppColors.purple.withOpacity(0.2)
                                          : AppColors.surface,
                                      border: Border.all(
                                        color: _isLiked
                                            ? AppColors.purple2
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: Icon(
                                      _isLiked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: _isLiked
                                          ? AppColors.purple3
                                          : AppColors.textThird,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // progress
                            _ProgressBar(progress: _progress),
                            const SizedBox(height: 6),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('1:48', style: TextStyle(fontSize: 10, color: AppColors.textThird)),
                                Text('4:23', style: TextStyle(fontSize: 10, color: AppColors.textThird)),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // playback controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => _isShuffling = !_isShuffling),
                                  child: Icon(Icons.shuffle_rounded, size: 22,
                                      color: _isShuffling ? AppColors.purple3 : AppColors.textThird),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.surface,
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: const Icon(Icons.skip_previous_rounded,
                                        color: AppColors.textSecond, size: 24),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _togglePlay,
                                  child: Container(
                                    width: 60, height: 60,
                                    decoration: BoxDecoration(
                                      shape:    BoxShape.circle,
                                      gradient: AppColors.primaryGradient,
                                      boxShadow: [
                                        BoxShadow(
                                          color:      AppColors.purple.withOpacity(0.55),
                                          blurRadius: 24,
                                          offset:     const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                      color: Colors.white, size: 32,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.surface,
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: const Icon(Icons.skip_next_rounded,
                                        color: AppColors.textSecond, size: 24),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _isRepeating = !_isRepeating),
                                  child: Icon(Icons.repeat_rounded, size: 22,
                                      color: _isRepeating ? AppColors.purple3 : AppColors.textThird),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // volume
                            Row(
                              children: [
                                const Icon(Icons.volume_down_rounded,
                                    color: AppColors.textThird, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight:        3,
                                      thumbShape:         const RoundSliderThumbShape(enabledThumbRadius: 6),
                                      overlayShape:       const RoundSliderOverlayShape(overlayRadius: 12),
                                      activeTrackColor:   AppColors.purple,
                                      inactiveTrackColor: AppColors.surface2,
                                      thumbColor:         Colors.white,
                                      overlayColor:       AppColors.purple.withOpacity(0.2),
                                    ),
                                    child: Slider(
                                      value:     _volume,
                                      onChanged: (v) => setState(() => _volume = v),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.volume_up_rounded,
                                    color: AppColors.textThird, size: 18),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _ActionBtn(
                                  icon:  Icons.queue_music_rounded,
                                  label: 'Queue',
                                  onTap: () => context.push(AppRoutes.queue),
                                ),
                                _ActionBtn(
                                  icon:  Icons.lyrics_outlined,
                                  label: 'Lyrics',
                                  onTap: () => context.push(AppRoutes.lyrics),
                                ),
                                _ActionBtn(
                                  icon:  Icons.share_outlined,
                                  label: 'Share',
                                  onTap: _share,
                                ),
                                _ActionBtn(
                                  icon:  Icons.add_to_photos_outlined,
                                  label: 'Playlist',
                                  onTap: _showAddToPlaylist,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add to Playlist Bottom Sheet ──────────────────────────────
class _AddToPlaylistSheet extends StatefulWidget {
  final List<Map<String, dynamic>> playlists;
  final void Function(int) onToggle;

  const _AddToPlaylistSheet({
    required this.playlists,
    required this.onToggle,
  });

  @override
  State<_AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends State<_AddToPlaylistSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color:        Color(0xFF0F0F22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color:        AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),

          // header
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add to Playlist 🎵',
                      style: TextStyle(
                        fontSize:   18,
                        fontWeight: FontWeight.w700,
                        color:      AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Midnight City — M83',
                      style: TextStyle(
                        fontSize: 11,
                        color:    AppColors.textSecond,
                      ),
                    ),
                  ],
                ),
              ),
              // create new playlist btn
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Create playlist coming soon!'),
                      backgroundColor: AppColors.purple,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient:     AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'New',
                        style: TextStyle(
                          fontSize:   11,
                          fontWeight: FontWeight.w600,
                          color:      Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // playlist list
          ...List.generate(widget.playlists.length, (i) {
            final pl      = widget.playlists[i];
            final isAdded = pl['added'] as bool;
            return GestureDetector(
              onTap: () {
                setState(() => widget.onToggle(i));
                if (!isAdded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added to "${pl['name']}" ✓'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isAdded
                      ? LinearGradient(colors: [
                          AppColors.purple.withOpacity(0.2),
                          AppColors.cyan.withOpacity(0.08),
                        ])
                      : null,
                  color:        isAdded ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isAdded ? AppColors.purple2 : AppColors.border,
                    width: isAdded ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // emoji icon
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        gradient: LinearGradient(colors: [
                          AppColors.purple.withOpacity(isAdded ? 0.5 : 0.3),
                          AppColors.cyan.withOpacity(0.2),
                        ]),
                      ),
                      child: Center(
                        child: Text(pl['emoji'] as String,
                            style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pl['name'] as String,
                            style: TextStyle(
                              fontSize:   13,
                              fontWeight: FontWeight.w600,
                              color: isAdded
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${pl['count']} songs',
                            style: const TextStyle(
                              fontSize: 10,
                              color:    AppColors.textSecond,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        shape:    BoxShape.circle,
                        gradient: isAdded ? AppColors.primaryGradient : null,
                        color:    isAdded ? null : AppColors.surface2,
                        border: isAdded ? null : Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        isAdded ? Icons.check_rounded : Icons.add_rounded,
                        color: isAdded ? Colors.white : AppColors.textThird,
                        size:  14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Progress Bar ──────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(children: [
        Container(
          height: 4, width: constraints.maxWidth,
          decoration: BoxDecoration(
            color:        AppColors.surface2,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Container(
          height: 4,
          width:  constraints.maxWidth * progress,
          decoration: BoxDecoration(
            gradient:     AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Positioned(
          left: (constraints.maxWidth * progress - 7).clamp(0, constraints.maxWidth - 14),
          top:  -4,
          child: Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(
                color:      AppColors.purple.withOpacity(0.8),
                blurRadius: 8,
              )],
            ),
          ),
        ),
      ]);
    });
  }
}

// ── Action Button ─────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color:        AppColors.surface,
              borderRadius: BorderRadius.circular(13),
              border:       Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.textSecond, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.textThird),
          ),
        ],
      ),
    );
  }
}

// ── Grid ──────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = AppColors.purple.withOpacity(0.04)
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
