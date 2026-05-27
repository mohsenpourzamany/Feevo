import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';

class PlaylistDetailScreen extends StatefulWidget {
  const PlaylistDetailScreen({super.key});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen>
    with TickerProviderStateMixin {

  bool _isPlaying  = false;
  bool _isLiked    = false;

  late AnimationController _contentController;
  late AnimationController _headerController;
  late Animation<double>   _contentOpacity;
  late Animation<Offset>   _contentSlide;
  late Animation<double>   _headerScale;

  final List<Map<String, dynamic>> _tracks = [
    {'title': 'Midnight City',            'artist': 'M83',          'emoji': '🎵', 'duration': '4:03', 'liked': true},
    {'title': 'Let It Happen',            'artist': 'Tame Impala',  'emoji': '🌊', 'duration': '7:47', 'liked': false},
    {'title': 'Blinding Lights',          'artist': 'The Weeknd',   'emoji': '🌙', 'duration': '3:22', 'liked': true},
    {'title': 'Good Days',                'artist': 'SZA',          'emoji': '💗', 'duration': '4:39', 'liked': false},
    {'title': 'Holocene',                 'artist': 'Bon Iver',     'emoji': '❄️', 'duration': '5:37', 'liked': true},
    {'title': 'The Less I Know Better',   'artist': 'Tame Impala',  'emoji': '🎸', 'duration': '3:36', 'liked': false},
    {'title': 'Motion Picture Soundtrack','artist': 'Radiohead',    'emoji': '🎹', 'duration': '6:59', 'liked': false},
    {'title': 'Feels Like We Only Go',    'artist': 'Tame Impala',  'emoji': '⚡', 'duration': '4:01', 'liked': true},
    {'title': 'Digital Love',             'artist': 'Daft Punk',    'emoji': '🤖', 'duration': '4:58', 'liked': false},
    {'title': 'Nightcall',                'artist': 'Kavinsky',     'emoji': '🌃', 'duration': '4:15', 'liked': true},
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playEntrance();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end:   Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
  }

  void _playEntrance() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  String get _totalDuration {
    int total = 0;
    for (final t in _tracks) {
      final parts = (t['duration'] as String).split(':');
      total += int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          CustomScrollView(
            slivers: [

              // ── Header
              SliverToBoxAdapter(
                child: ScaleTransition(
                  scale: _headerScale,
                  child: _buildHeader(),
                ),
              ),

              // ── Track List
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentOpacity,
                    child: _buildTrackList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end:   Alignment.bottomCenter,
          colors: [Color(0xFF1a0535), Color(0xFF06060F)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80, right: -60,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.purple.withOpacity(0.25),
                  AppColors.purple.withOpacity(0),
                ]),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                children: [

                  // top bar
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.3),
                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.3),
                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                          ),
                          child: const Icon(Icons.more_horiz_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // playlist art + cat
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width:  160,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end:   Alignment.bottomRight,
                            colors: [
                              Color(0xFF4C1D95),
                              Color(0xFF7C3AED),
                              Color(0xFF0891B2),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:      AppColors.purple.withOpacity(0.5),
                              blurRadius: 30,
                              offset:     const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // grid of mini emojis
                            ...List.generate(4, (i) => Positioned(
                              top:  (i ~/ 2) * 80.0 + 20,
                              left: (i % 2)  * 80.0 + 20,
                              child: Text(
                                _tracks[i]['emoji'] as String,
                                style: const TextStyle(fontSize: 28),
                              ),
                            )),
                          ],
                        ),
                      ),
                      // cat_3 floating
                      Positioned(
                        bottom: -10, right: -10,
                        child: Image.asset(
                          AppConstants.cat3,
                          width:  55,
                          height: 55,
                          fit:    BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // playlist info
                  const Text(
                    'Late Night Chill 🌙',
                    style: TextStyle(
                      fontSize:      22,
                      fontWeight:    FontWeight.w800,
                      color:         Colors.white,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI Generated · ${_tracks.length} songs · $_totalDuration',
                    style: const TextStyle(fontSize: 12, color: Colors.white60),
                  ),

                  const SizedBox(height: 16),

                  // action buttons
                  Row(
                    children: [
                      // play all
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isPlaying = !_isPlaying);
                            context.push(AppRoutes.nowPlaying);
                          },
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              gradient:     AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color:      AppColors.purple.withOpacity(0.4),
                                  blurRadius: 14,
                                  offset:     const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size:  22,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isPlaying ? 'Pause' : 'Play All',
                                  style: const TextStyle(
                                    fontSize:   14,
                                    fontWeight: FontWeight.w700,
                                    color:      Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // like
                      GestureDetector(
                        onTap: () => setState(() => _isLiked = !_isLiked),
                        child: Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isLiked
                                ? AppColors.purple.withOpacity(0.3)
                                : Colors.black.withOpacity(0.3),
                            border: Border.all(
                              color: _isLiked
                                  ? AppColors.purple2
                                  : Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: Icon(
                            _isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isLiked
                                ? AppColors.purple3
                                : Colors.white60,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // shuffle
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: const Icon(Icons.shuffle_rounded,
                            color: Colors.white60, size: 20),
                      ),
                      const SizedBox(width: 8),
                      // download
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: const Icon(Icons.download_outlined,
                            color: Colors.white60, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRACKS',
            style: TextStyle(
              fontSize:      10,
              fontWeight:    FontWeight.w600,
              color:         AppColors.textThird,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(_tracks.length, (i) {
            final t = _tracks[i];
            return GestureDetector(
              onTap: () => context.push(AppRoutes.nowPlaying),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color:        AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border:       Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    // number
                    SizedBox(
                      width: 20,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          color:    AppColors.textThird,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // art
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(colors: [
                          AppColors.purple.withOpacity(0.4),
                          AppColors.cyan.withOpacity(0.2),
                        ]),
                      ),
                      child: Center(
                        child: Text(t['emoji'] as String,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t['title'] as String,
                            style: const TextStyle(
                              fontSize:   13,
                              fontWeight: FontWeight.w600,
                              color:      AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            t['artist'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color:    AppColors.textSecond,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // duration
                    Text(
                      t['duration'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        color:    AppColors.textThird,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // like
                    GestureDetector(
                      onTap: () => setState(() {
                        _tracks[i]['liked'] = !(_tracks[i]['liked'] as bool);
                      }),
                      child: Icon(
                        (t['liked'] as bool)
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: (t['liked'] as bool)
                            ? AppColors.purple3
                            : AppColors.textThird,
                        size: 18,
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
