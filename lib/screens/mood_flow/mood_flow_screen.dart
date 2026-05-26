import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/bottom_nav_widget.dart';

class MoodFlowScreen extends StatefulWidget {
  const MoodFlowScreen({super.key});

  @override
  State<MoodFlowScreen> createState() => _MoodFlowScreenState();
}

class _MoodFlowScreenState extends State<MoodFlowScreen>
    with TickerProviderStateMixin {
  String? _selectedMood;
  bool _isGenerating = false;
  bool _isGenerated = false;

  late AnimationController _catController;
  late AnimationController _floatController;
  late AnimationController _contentController;
  late AnimationController _pulseController;

  late Animation<double> _catScale;
  late Animation<double> _catOpacity;
  late Animation<double> _catFloat;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;
  late Animation<double> _pulse;

  final List<Map<String, dynamic>> _moods = [
    {
      'id': 'energetic',
      'label': 'Energetic',
      'emoji': '⚡',
      'cat': AppConstants.cat4,
      'color': const Color(0xFF7C3AED)
    },
    {
      'id': 'chill',
      'label': 'Chill',
      'emoji': '🌙',
      'cat': AppConstants.cat3,
      'color': const Color(0xFF0891B2)
    },
    {
      'id': 'focused',
      'label': 'Focused',
      'emoji': '💭',
      'cat': AppConstants.cat7,
      'color': const Color(0xFF4C1D95)
    },
    {
      'id': 'melancholic',
      'label': 'Melancholic',
      'emoji': '🌧',
      'cat': AppConstants.cat5,
      'color': const Color(0xFF1E3A5F)
    },
    {
      'id': 'hype',
      'label': 'Hype',
      'emoji': '🔥',
      'cat': AppConstants.cat2,
      'color': const Color(0xFFBE185D)
    },
    {
      'id': 'happy',
      'label': 'Happy',
      'emoji': '💗',
      'cat': AppConstants.cat1,
      'color': const Color(0xFF065F46)
    },
  ];

  final List<Map<String, String>> _playlist = [
    {
      'title': 'The Night We Met',
      'artist': 'Lord Huron',
      'emoji': '🌙',
      'duration': '3:28'
    },
    {
      'title': 'Skinny Love',
      'artist': 'Bon Iver',
      'emoji': '🌧',
      'duration': '3:58'
    },
    {
      'title': 'Motion Picture...',
      'artist': 'Radiohead',
      'emoji': '💭',
      'duration': '6:59'
    },
    {
      'title': 'Holocene',
      'artist': 'Bon Iver',
      'emoji': '❄️',
      'duration': '5:37'
    },
    {
      'title': 'Exile',
      'artist': 'Taylor Swift',
      'emoji': '💔',
      'duration': '4:45'
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playEntrance();
  }

  void _setupAnimations() {
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
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _catFloat = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
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
    _catController.dispose();
    _floatController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String get _currentCatAsset {
    if (_selectedMood == null) return AppConstants.cat3;
    final mood = _moods.firstWhere((m) => m['id'] == _selectedMood);
    return mood['cat'] as String;
  }

  String get _moodLabel {
    if (_selectedMood == null) return 'How are you feeling?';
    final mood = _moods.firstWhere((m) => m['id'] == _selectedMood);
    return '${mood['emoji']} ${mood['label']}';
  }

  Color get _moodColor {
    if (_selectedMood == null) return AppColors.purple;
    final mood = _moods.firstWhere((m) => m['id'] == _selectedMood);
    return mood['color'] as Color;
  }

  void _selectMood(String id) {
    setState(() {
      _selectedMood = id;
      _isGenerated = false;
    });
    // replay cat animation
    _catController.reset();
    _catController.forward();
  }

  Future<void> _generate() async {
    if (_selectedMood == null) return;
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    setState(() {
      _isGenerating = false;
      _isGenerated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          // dynamic orb based on mood color
          Positioned(
            top: -120,
            right: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _moodColor.withOpacity(0.15),
                  _moodColor.withOpacity(0),
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.purple.withOpacity(0.1),
                  AppColors.purple.withOpacity(0),
                ]),
              ),
            ),
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
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        children: [
                          // title
                          Row(
                            children: [
                              Expanded(
                                child: RichText(
                                  text: WidgetSpan(
                                    child: ShaderMask(
                                      shaderCallback: (bounds) => AppColors
                                          .primaryGradient
                                          .createShader(bounds),
                                      child: const Text(
                                        'Mood Flow 🌊',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // cat zone — reacts to mood
                          AnimatedBuilder(
                            animation: Listenable.merge(
                                [_catController, _floatController]),
                            builder: (_, __) => Opacity(
                              opacity: _catOpacity.value,
                              child: Transform.scale(
                                scale: _catScale.value,
                                child: Transform.translate(
                                  offset: Offset(0, _catFloat.value),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          _moodColor.withOpacity(0.18),
                                          AppColors.cyan.withOpacity(0.08),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: _moodColor.withOpacity(0.35),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          _currentCatAsset,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.contain,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _selectedMood == null
                                                    ? 'Mood detected'
                                                    : 'Feeling...',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.purple3,
                                                  letterSpacing: 1,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _moodLabel,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              // mic button
                                              GestureDetector(
                                                onTap: () {},
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    gradient: AppColors
                                                        .primaryGradient,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            999),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.mic_rounded,
                                                          color: Colors.white,
                                                          size: 14),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        'Speak your mood',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // mood chips
                          const Text(
                            'Or pick a mood:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _moods.map((mood) {
                              final active = _selectedMood == mood['id'];
                              return GestureDetector(
                                onTap: () => _selectMood(mood['id'] as String),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 9),
                                  decoration: BoxDecoration(
                                    gradient: active
                                        ? LinearGradient(
                                            colors: [
                                              (mood['color'] as Color)
                                                  .withOpacity(0.3),
                                              AppColors.cyan.withOpacity(0.1),
                                            ],
                                          )
                                        : null,
                                    color: active ? null : AppColors.surface,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: active
                                          ? (mood['color'] as Color)
                                              .withOpacity(0.6)
                                          : AppColors.border,
                                      width: active ? 1.5 : 1,
                                    ),
                                    boxShadow: active
                                        ? [
                                            BoxShadow(
                                              color: (mood['color'] as Color)
                                                  .withOpacity(0.2),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Text(
                                    '${mood['emoji']} ${mood['label']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: active
                                          ? AppColors.textPrimary
                                          : AppColors.textSecond,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // generate button
                          if (_selectedMood != null && !_isGenerated)
                            GestureDetector(
                              onTap: _generate,
                              child: AnimatedBuilder(
                                animation: _pulse,
                                builder: (_, child) => Transform.scale(
                                  scale: _isGenerating ? _pulse.value : 1.0,
                                  child: child,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [_moodColor, AppColors.purple],
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _moodColor.withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _isGenerating
                                        ? const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Building your flow...',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Text(
                                            '✨ Generate My Flow',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),

                          // generated playlist
                          if (_isGenerated) ...[
                            const SizedBox(height: 4),
                            _buildPlaylist(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const FeevoBottomNav(currentIndex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Playlist ──────────────────────────────────────────────
  Widget _buildPlaylist() {
    final mood = _moods.firstWhere((m) => m['id'] == _selectedMood);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              mood['cat'] as String,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              '${mood['emoji']} Your ${mood['label']} Flow',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(_playlist.length, (i) {
              final track = _playlist[i];
              final isFirst = i == 0;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isFirst
                      ? LinearGradient(
                          colors: [
                            _moodColor.withOpacity(0.15),
                            AppColors.cyan.withOpacity(0.06),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isFirst ? 18 : 0),
                    topRight: Radius.circular(isFirst ? 18 : 0),
                    bottomLeft:
                        Radius.circular(i == _playlist.length - 1 ? 18 : 0),
                    bottomRight:
                        Radius.circular(i == _playlist.length - 1 ? 18 : 0),
                  ),
                  border: i < _playlist.length - 1
                      ? const Border(
                          bottom: BorderSide(color: AppColors.border))
                      : null,
                ),
                child: Row(
                  children: [
                    Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isFirst ? AppColors.cyan2 : AppColors.textThird,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        gradient: LinearGradient(
                          colors: [
                            _moodColor.withOpacity(0.6),
                            AppColors.purple.withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(track['emoji']!,
                            style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track['title']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isFirst
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            track['artist']!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecond,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isFirst)
                      _WaveIndicator()
                    else
                      Text(
                        track['duration']!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textThird,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 12),

        // regenerate button
        GestureDetector(
          onTap: () => setState(() => _isGenerated = false),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border2),
            ),
            child: const Center(
              child: Text(
                '↺ Regenerate Flow',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.purple3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home', 'route': AppRoutes.home},
      {
        'icon': Icons.search_rounded,
        'label': 'Search',
        'route': AppRoutes.search
      },
      {
        'icon': Icons.mic_rounded,
        'label': 'Live',
        'route': AppRoutes.liveRooms
      },
      {
        'icon': Icons.map_outlined,
        'label': 'Memory',
        'route': AppRoutes.memoryMap
      },
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Profile',
        'route': AppRoutes.profile
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = i == 1;
              return GestureDetector(
                onTap: () => context.go(items[i]['route'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: active
                        ? LinearGradient(colors: [
                            AppColors.purple.withOpacity(0.15),
                            AppColors.cyan.withOpacity(0.08),
                          ])
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        size: 22,
                        color: active ? AppColors.purple3 : AppColors.textThird,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color:
                              active ? AppColors.purple3 : AppColors.textThird,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Wave Indicator ─────────────────────────────────────────
class _WaveIndicator extends StatefulWidget {
  @override
  State<_WaveIndicator> createState() => _WaveIndicatorState();
}

class _WaveIndicatorState extends State<_WaveIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
        6,
        (i) => AnimationController(
              vsync: this,
              duration: Duration(milliseconds: 500 + i * 80),
            )..repeat(reverse: true));
    _animations = _controllers
        .map((c) => Tween<double>(begin: 0.2, end: 1.0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
            6,
            (i) => AnimatedBuilder(
                  animation: _animations[i],
                  builder: (_, __) => Container(
                    width: 2,
                    height: 20 * _animations[i].value,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                )),
      ),
    );
  }
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
