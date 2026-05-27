import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/bottom_nav_widget.dart';

class MemoryMapScreen extends StatefulWidget {
  const MemoryMapScreen({super.key});

  @override
  State<MemoryMapScreen> createState() => _MemoryMapScreenState();
}

class _MemoryMapScreenState extends State<MemoryMapScreen>
    with TickerProviderStateMixin {
  String _selectedFilter = 'all';

  late AnimationController _catController;
  late AnimationController _floatController;
  late AnimationController _contentController;
  late AnimationController _pulseController;

  late Animation<double> _catScale;
  late Animation<double> _catOpacity;
  late Animation<double> _catFloat;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;
  // ignore: unused_field
  late Animation<double> _pulse;

  final List<Map<String, dynamic>> _memories = [
    {
      'title': 'Blinding Lights',
      'artist': 'The Weeknd',
      'emoji': '🌙',
      'mood': 'Melancholic',
      'plays': 47,
      'time': 'Late nights',
      'day': 'Tuesday',
      'color': const Color(0xFF4C1D95),
      'insight': 'You always play this on late Tuesday nights after 10pm',
      'tag': 'melancholic',
    },
    {
      'title': 'Let It Happen',
      'artist': 'Tame Impala',
      'emoji': '🌊',
      'mood': 'Energetic',
      'plays': 38,
      'time': 'Morning runs',
      'day': 'Saturday',
      'color': const Color(0xFF0891B2),
      'insight': 'Your go-to track for Saturday morning workouts',
      'tag': 'energetic',
    },
    {
      'title': 'Midnight City',
      'artist': 'M83',
      'emoji': '🎵',
      'mood': 'Chill',
      'plays': 62,
      'time': 'Evening drives',
      'day': 'Friday',
      'color': const Color(0xFF7C3AED),
      'insight': 'Most played during Friday evening commutes',
      'tag': 'chill',
    },
    {
      'title': 'Good Days',
      'artist': 'SZA',
      'emoji': '💗',
      'mood': 'Happy',
      'plays': 29,
      'time': 'Afternoons',
      'day': 'Sunday',
      'color': const Color(0xFFBE185D),
      'insight': 'You play this on lazy Sunday afternoons',
      'tag': 'happy',
    },
    {
      'title': 'Holocene',
      'artist': 'Bon Iver',
      'emoji': '❄️',
      'mood': 'Melancholic',
      'plays': 21,
      'time': 'Rainy days',
      'day': 'Any day',
      'color': const Color(0xFF1E3A5F),
      'insight': 'Weather-triggered — you play this when it rains',
      'tag': 'melancholic',
    },
    {
      'title': 'Borderline',
      'artist': 'Tame Impala',
      'emoji': '🎸',
      'mood': 'Focused',
      'plays': 33,
      'time': 'Deep work',
      'day': 'Weekdays',
      'color': const Color(0xFF065F46),
      'insight': 'Your focus music during deep work sessions',
      'tag': 'focused',
    },
  ];

  final List<Map<String, String>> _filters = [
    {'id': 'all', 'label': 'All'},
    {'id': 'melancholic', 'label': '🌧 Sad'},
    {'id': 'energetic', 'label': '⚡ Energy'},
    {'id': 'chill', 'label': '🌙 Chill'},
    {'id': 'happy', 'label': '💗 Happy'},
    {'id': 'focused', 'label': '💭 Focus'},
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
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);
    _catFloat = Tween<double>(begin: 0, end: -8).animate(
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
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
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

  List<Map<String, dynamic>> get _filteredMemories {
    if (_selectedFilter == 'all') return _memories;
    return _memories.where((m) => m['tag'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.cyan.withOpacity(0.12),
                  AppColors.cyan.withOpacity(0),
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
                  AppColors.purple.withOpacity(0.12),
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
                          // header
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: WidgetSpan(
                                        child: ShaderMask(
                                          shaderCallback: (bounds) => AppColors
                                              .primaryGradient
                                              .createShader(bounds),
                                          child: const Text(
                                            'Memory Map 🗺️',
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
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Your musical memories',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecond,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // cat_6 thinking
                              AnimatedBuilder(
                                animation: Listenable.merge(
                                    [_catController, _floatController]),
                                builder: (_, __) => Opacity(
                                  opacity: _catOpacity.value,
                                  child: Transform.scale(
                                    scale: _catScale.value,
                                    child: Transform.translate(
                                      offset: Offset(0, _catFloat.value),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.purple
                                                  .withOpacity(0.35),
                                              blurRadius: 20,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Image.asset(
                                          AppConstants.cat6,
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // AI insight card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.purple.withOpacity(0.18),
                                  AppColors.cyan.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border2),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  AppConstants.cat6,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '🤖 AI Insight',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.cyan2,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'You listen to melancholic music 3x more on rainy days. Your peak listening time is 11pm on Tuesdays.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecond,
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // stats row
                          Row(
                            children: [
                              _StatCard(
                                value: '${_memories.length}',
                                label: 'Memories',
                                emoji: '💾',
                              ),
                              const SizedBox(width: 10),
                              _StatCard(
                                value:
                                    '${_memories.fold(0, (sum, m) => sum + (m['plays'] as int))}',
                                label: 'Total Plays',
                                emoji: '▶️',
                              ),
                              const SizedBox(width: 10),
                              const _StatCard(
                                value: '4',
                                label: 'Moods',
                                emoji: '🎭',
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // filter chips
                          SizedBox(
                            height: 34,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _filters.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final filter = _filters[i];
                                final active = _selectedFilter == filter['id'];
                                return GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedFilter = filter['id']!),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    decoration: BoxDecoration(
                                      gradient: active
                                          ? LinearGradient(colors: [
                                              AppColors.purple.withOpacity(0.3),
                                              AppColors.cyan.withOpacity(0.15),
                                            ])
                                          : null,
                                      color: active ? null : AppColors.surface,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: active
                                            ? AppColors.purple2
                                            : AppColors.border,
                                        width: active ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        filter['label']!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: active
                                              ? AppColors.purple3
                                              : AppColors.textSecond,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          // memories list
                          ..._filteredMemories.map((memory) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GestureDetector(
                                  onTap: () =>
                                      context.push(AppRoutes.memoryDetail),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          (memory['color'] as Color)
                                              .withOpacity(0.12),
                                          AppColors.purple.withOpacity(0.06),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: (memory['color'] as Color)
                                            .withOpacity(0.25),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            // album art
                                            Container(
                                              width: 52,
                                              height: 52,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    memory['color'] as Color,
                                                    AppColors.purple,
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (memory['color']
                                                            as Color)
                                                        .withOpacity(0.3),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  memory['emoji'] as String,
                                                  style: const TextStyle(
                                                      fontSize: 24),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 12),

                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    memory['title'] as String,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    memory['artist'] as String,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          AppColors.textSecond,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // plays count
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${memory['plays']}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                    color: (memory['color']
                                                        as Color),
                                                  ),
                                                ),
                                                const Text(
                                                  'plays',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: AppColors.textThird,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        // mood bar
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color:
                                                    (memory['color'] as Color)
                                                        .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                border: Border.all(
                                                  color:
                                                      (memory['color'] as Color)
                                                          .withOpacity(0.3),
                                                ),
                                              ),
                                              child: Text(
                                                memory['mood'] as String,
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      memory['color'] as Color,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                                Icons.access_time_rounded,
                                                color: AppColors.textThird,
                                                size: 11),
                                            const SizedBox(width: 3),
                                            Text(
                                              memory['time'] as String,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textThird,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                                Icons.calendar_today_outlined,
                                                color: AppColors.textThird,
                                                size: 11),
                                            const SizedBox(width: 3),
                                            Text(
                                              memory['day'] as String,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textThird,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // AI insight
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 7),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              const Text('🤖',
                                                  style:
                                                      TextStyle(fontSize: 12)),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  memory['insight'] as String,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.textSecond,
                                                    height: 1.5,
                                                    fontStyle: FontStyle.italic,
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
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                const FeevoBottomNav(currentIndex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value, label, emoji;
  const _StatCard(
      {required this.value, required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.purple.withOpacity(0.15),
              AppColors.cyan.withOpacity(0.07),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textThird,
              ),
            ),
          ],
        ),
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
