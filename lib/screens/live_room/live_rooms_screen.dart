import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/bottom_nav_widget.dart';

class LiveRoomsScreen extends StatefulWidget {
  const LiveRoomsScreen({super.key});

  @override
  State<LiveRoomsScreen> createState() => _LiveRoomsScreenState();
}

class _LiveRoomsScreenState extends State<LiveRoomsScreen>
    with TickerProviderStateMixin {
  String _selectedFilter = 'all';

  late AnimationController _catController;
  late AnimationController _floatController;
  late AnimationController _contentController;

  late Animation<double> _catScale;
  late Animation<double> _catOpacity;
  late Animation<double> _catFloat;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  final List<Map<String, dynamic>> _rooms = [
    {
      'name': 'Late Night Chill',
      'host': 'DJ Cosmos',
      'track': 'Tame Impala — Let It Happen',
      'listeners': 241,
      'emoji': '🌙',
      'color': const Color(0xFF4C1D95),
      'tag': 'chill',
      'isLive': true,
    },
    {
      'name': 'Friday Hype Train',
      'host': 'BeatMaster',
      'track': 'Travis Scott — SICKO MODE',
      'listeners': 1284,
      'emoji': '🔥',
      'color': const Color(0xFFC2410C),
      'tag': 'hype',
      'isLive': true,
    },
    {
      'name': 'Study With Me',
      'host': 'LoFiGirl',
      'track': 'Lo-Fi Beats — Rainy Day',
      'listeners': 892,
      'emoji': '🎹',
      'color': const Color(0xFF1D4ED8),
      'tag': 'focused',
      'isLive': true,
    },
    {
      'name': 'Electronic Vibes',
      'host': 'SynthWave',
      'track': 'Daft Punk — Get Lucky',
      'listeners': 567,
      'emoji': '⚡',
      'color': const Color(0xFF7C3AED),
      'tag': 'energetic',
      'isLive': true,
    },
    {
      'name': 'Jazz Corner',
      'host': 'MilesAhead',
      'track': 'Miles Davis — So What',
      'listeners': 134,
      'emoji': '🎷',
      'color': const Color(0xFF065F46),
      'tag': 'chill',
      'isLive': false,
    },
    {
      'name': 'Pop Hits 2025',
      'host': 'TopChartsTV',
      'track': 'Starting in 10 min...',
      'listeners': 0,
      'emoji': '💗',
      'color': const Color(0xFFBE185D),
      'tag': 'hype',
      'isLive': false,
    },
  ];

  final List<Map<String, String>> _filters = [
    {'id': 'all', 'label': 'All Rooms'},
    {'id': 'chill', 'label': '🌙 Chill'},
    {'id': 'hype', 'label': '🔥 Hype'},
    {'id': 'focused', 'label': '💭 Focused'},
    {'id': 'energetic', 'label': '⚡ Energy'},
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
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredRooms {
    if (_selectedFilter == 'all') return _rooms;
    return _rooms.where((r) => r['tag'] == _selectedFilter).toList();
  }

  String _formatListeners(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
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
            left: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.purple.withOpacity(0.15),
                  AppColors.purple.withOpacity(0),
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.cyan.withOpacity(0.08),
                  AppColors.cyan.withOpacity(0),
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
                                            'Live Rooms 🏠',
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
                                      'Listen together, feel together',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecond,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // cat_1 super hype
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
                                          AppConstants.cat1,
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

                          // create room button
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.createRoom),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.purple.withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_circle_outline_rounded,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Create a Room',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

                          // live count
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_filteredRooms.where((r) => r['isLive'] == true).length} rooms live now',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecond,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // rooms list
                          ..._filteredRooms.map((room) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GestureDetector(
                                  onTap: () =>
                                      context.push(AppRoutes.liveRoomIn),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: room['isLive'] == true
                                          ? LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                (room['color'] as Color)
                                                    .withOpacity(0.15),
                                                AppColors.purple
                                                    .withOpacity(0.08),
                                              ],
                                            )
                                          : null,
                                      color: room['isLive'] == false
                                          ? AppColors.surface
                                          : null,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: room['isLive'] == true
                                            ? (room['color'] as Color)
                                                .withOpacity(0.35)
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // room icon
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                room['color'] as Color,
                                                AppColors.purple,
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (room['color'] as Color)
                                                    .withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              room['emoji'] as String,
                                              style:
                                                  const TextStyle(fontSize: 24),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        // info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                room['name'] as String,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'by ${room['host']}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.purple3,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                room['track'] as String,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.textSecond,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        // right side
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            if (room['isLive'] == true)
                                              _LiveBadge()
                                            else
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: AppColors.surface2,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          999),
                                                  border: Border.all(
                                                      color: AppColors.border),
                                                ),
                                                child: const Text(
                                                  'Soon',
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textThird,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 6),
                                            if (room['listeners'] as int > 0)
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.headphones_rounded,
                                                    color: AppColors.textThird,
                                                    size: 12,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    _formatListeners(
                                                        room['listeners']
                                                            as int),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          AppColors.textThird,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
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
                const FeevoBottomNav(currentIndex: -1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Live Badge ────────────────────────────────────────────────
class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withOpacity(_anim.value),
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'LIVE',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
              letterSpacing: 1,
            ),
          ),
        ],
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
