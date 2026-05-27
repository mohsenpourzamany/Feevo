import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';

class MemoryDetailScreen extends StatefulWidget {
  const MemoryDetailScreen({super.key});

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen>
    with TickerProviderStateMixin {

  late AnimationController _contentController;
  late AnimationController _catController;
  late AnimationController _floatController;

  late Animation<double> _contentOpacity;
  late Animation<Offset>  _contentSlide;
  late Animation<double> _catScale;
  late Animation<double> _catFloat;

  final List<Map<String, dynamic>> _relatedTracks = [
    {'title': 'Blinding Lights',   'artist': 'The Weeknd',  'emoji': '🌙', 'plays': 23, 'duration': '3:22'},
    {'title': 'Save Your Tears',   'artist': 'The Weeknd',  'emoji': '💗', 'plays': 14, 'duration': '3:35'},
    {'title': 'Starboy',           'artist': 'The Weeknd',  'emoji': '⭐', 'plays': 8,  'duration': '3:50'},
    {'title': 'After Hours',       'artist': 'The Weeknd',  'emoji': '🌃', 'plays': 6,  'duration': '6:01'},
  ];

  final List<Map<String, String>> _moodHistory = [
    {'day': 'Mon', 'mood': '😴', 'time': '11:30 PM'},
    {'day': 'Tue', 'mood': '🌙', 'time': '10:45 PM'},
    {'day': 'Wed', 'mood': '🌙', 'time': '11:15 PM'},
    {'day': 'Thu', 'mood': '😔', 'time': '12:00 AM'},
    {'day': 'Fri', 'mood': '🌙', 'time': '11:00 PM'},
    {'day': 'Sat', 'mood': '😴', 'time': '1:00 AM'},
    {'day': 'Sun', 'mood': '🌙', 'time': '10:30 PM'},
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
      begin: const Offset(0, 0.05),
      end:   Offset.zero,
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
    _contentController.dispose();
    _catController.dispose();
    _floatController.dispose();
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
            top: -100, right: -60,
            child: Container(
              width: 320, height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.purple.withOpacity(0.15),
                  AppColors.purple.withOpacity(0),
                ]),
              ),
            ),
          ),

          SafeArea(
            child: SlideTransition(
              position: _contentSlide,
              child: FadeTransition(
                opacity: _contentOpacity,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  children: [

                    // header
                    Row(
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
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: AppColors.textSecond, size: 16),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Memory Detail 🗺️',
                            style: TextStyle(
                              fontSize:      22,
                              fontWeight:    FontWeight.w800,
                              color:         AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // hero card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end:   Alignment.bottomRight,
                          colors: [Color(0xFF4C1D95), Color(0xFF0891B2)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color:      AppColors.purple.withOpacity(0.4),
                            blurRadius: 24,
                            offset:     const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // album art
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.black.withOpacity(0.2),
                            ),
                            child: const Center(
                              child: Text('🌙', style: TextStyle(fontSize: 38)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Blinding Lights',
                                  style: TextStyle(
                                    fontSize:   18,
                                    fontWeight: FontWeight.w800,
                                    color:      Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'The Weeknd',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:    Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _MemoryBadge(label: '47 plays', emoji: '▶️'),
                                    const SizedBox(width: 6),
                                    _MemoryBadge(label: 'Melancholic', emoji: '🌧'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // cat_6
                          AnimatedBuilder(
                            animation: Listenable.merge([_catController, _floatController]),
                            builder: (_, __) => Transform.scale(
                              scale: _catScale.value,
                              child: Transform.translate(
                                offset: Offset(0, _catFloat.value),
                                child: Image.asset(
                                  AppConstants.cat6,
                                  width:  52,
                                  height: 52,
                                  fit:    BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // AI insight
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppColors.purple.withOpacity(0.12),
                          AppColors.cyan.withOpacity(0.06),
                        ]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '🤖 AI Insight',
                            style: TextStyle(
                              fontSize:      10,
                              fontWeight:    FontWeight.w600,
                              color:         AppColors.cyan2,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'You always play this song on Tuesday nights after 10pm. It\'s become a ritual — your brain associates it with unwinding after a long day. You\'ve played it 47 times in the past 3 months.',
                            style: TextStyle(
                              fontSize: 12,
                              color:    AppColors.textSecond,
                              height:   1.7,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // stats row
                    Row(
                      children: [
                        _StatCard(value: '47',       label: 'Total Plays',   emoji: '▶️'),
                        const SizedBox(width: 10),
                        _StatCard(value: '3 months', label: 'Listening For', emoji: '📅'),
                        const SizedBox(width: 10),
                        _StatCard(value: '11 PM',    label: 'Peak Time',     emoji: '🕙'),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // mood history
                    const Text(
                      'THIS WEEK',
                      style: TextStyle(
                        fontSize:      10,
                        fontWeight:    FontWeight.w600,
                        color:         AppColors.textThird,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color:        AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border:       Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _moodHistory.map((d) => Column(
                          children: [
                            Text(d['mood']!,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(d['day']!,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color:    AppColors.textThird,
                                )),
                            Text(d['time']!.split(' ')[0],
                                style: const TextStyle(
                                  fontSize: 8,
                                  color:    AppColors.textThird,
                                )),
                          ],
                        )).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // related tracks
                    const Text(
                      'SONGS IN THIS MEMORY',
                      style: TextStyle(
                        fontSize:      10,
                        fontWeight:    FontWeight.w600,
                        color:         AppColors.textThird,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...List.generate(_relatedTracks.length, (i) {
                      final t = _relatedTracks[i];
                      return GestureDetector(
                        onTap: () => context.push(AppRoutes.nowPlaying),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: i == 0
                                ? LinearGradient(colors: [
                                    AppColors.purple.withOpacity(0.15),
                                    AppColors.cyan.withOpacity(0.07),
                                  ])
                                : null,
                            color: i == 0 ? null : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: i == 0
                                  ? AppColors.border2
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${t['plays']}x',
                                    style: TextStyle(
                                      fontSize:   13,
                                      fontWeight: FontWeight.w700,
                                      color:      AppColors.purple3,
                                    ),
                                  ),
                                  Text(
                                    t['duration'] as String,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color:    AppColors.textThird,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // play this memory button
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.nowPlaying),
                      child: Container(
                        width:   double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient:     AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color:      AppColors.purple.withOpacity(0.4),
                              blurRadius: 16,
                              offset:     const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '▶ Play This Memory',
                            style: TextStyle(
                              fontSize:   14,
                              fontWeight: FontWeight.w700,
                              color:      Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
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

class _MemoryBadge extends StatelessWidget {
  final String label, emoji;
  const _MemoryBadge({required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$emoji $label',
        style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label, emoji;
  const _StatCard({required this.value, required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppColors.purple.withOpacity(0.12),
            AppColors.cyan.withOpacity(0.06),
          ]),
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
                fontSize:   13,
                fontWeight: FontWeight.w800,
                color:      AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppColors.textThird),
              textAlign: TextAlign.center,
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
