import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with TickerProviderStateMixin {
  bool _isYearly = false;

  late AnimationController _catController;
  late AnimationController _floatController;
  late AnimationController _contentController;
  late AnimationController _shineController;

  late Animation<double> _catScale;
  late Animation<double> _catOpacity;
  late Animation<double> _catFloat;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;
  late Animation<double> _shine;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playEntrance();
  }

  void _setupAnimations() {
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

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _shine = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
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
    _catController.dispose();
    _floatController.dispose();
    _contentController.dispose();
    _shineController.dispose();
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
            top: -150,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
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
            bottom: -80,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.cyan.withOpacity(0.12),
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
                          // back button
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: AppColors.textSecond,
                                    size: 16),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // cat_2 hype + title
                          AnimatedBuilder(
                            animation: Listenable.merge(
                                [_catController, _floatController]),
                            builder: (_, __) => Opacity(
                              opacity: _catOpacity.value,
                              child: Transform.scale(
                                scale: _catScale.value,
                                child: Transform.translate(
                                  offset: Offset(0, _catFloat.value),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.purple
                                                  .withOpacity(0.5),
                                              blurRadius: 40,
                                              spreadRadius: 4,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Image.asset(
                                          AppConstants.cat2,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                          colors: [
                                            Color(0xFFFFD700),
                                            Color(0xFFFFA500),
                                            Color(0xFFFFD700),
                                          ],
                                        ).createShader(bounds),
                                        child: const Text(
                                          '⚡ Feevo Premium',
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Unlock the full Feevo experience',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecond,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // billing toggle
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _isYearly = false),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: !_isYearly
                                            ? AppColors.primaryGradient
                                            : null,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: !_isYearly
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.purple
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Monthly',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: !_isYearly
                                                ? Colors.white
                                                : AppColors.textSecond,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _isYearly = true),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: _isYearly
                                            ? AppColors.primaryGradient
                                            : null,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: _isYearly
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.purple
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Yearly',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: _isYearly
                                                    ? Colors.white
                                                    : AppColors.textSecond,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _isYearly
                                                    ? Colors.white
                                                        .withOpacity(0.2)
                                                    : AppColors.successBg,
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                '-40%',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color: _isYearly
                                                      ? Colors.white
                                                      : AppColors.success,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // price card
                          AnimatedBuilder(
                            animation: _shine,
                            builder: (_, child) => Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF4C1D95),
                                    Color(0xFF7C3AED),
                                    Color(0xFF0891B2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.purple.withOpacity(0.5),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: child,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _isYearly ? '\$71.99' : '\$9.99',
                                      style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 6, left: 4),
                                      child: Text(
                                        _isYearly ? '/year' : '/month',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_isYearly)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: const Text(
                                          '\$5.99/mo',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (_isYearly)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.success.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                          color: AppColors.success
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                      child: const Text(
                                        '🎉 Save \$47.88 per year',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // features
                          const Text(
                            'Everything in Premium:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          ...[
                            {
                              'emoji': '🎵',
                              'title': 'Unlimited Music',
                              'sub': 'No ads, no limits'
                            },
                            {
                              'emoji': '🤖',
                              'title': 'AI Mood Flow',
                              'sub': 'Unlimited AI playlists'
                            },
                            {
                              'emoji': '🏠',
                              'title': 'Host Live Rooms',
                              'sub': 'Up to 10,000 listeners'
                            },
                            {
                              'emoji': '📥',
                              'title': 'Offline Downloads',
                              'sub': 'Up to 10,000 songs'
                            },
                            {
                              'emoji': '🎧',
                              'title': 'HiFi Audio Quality',
                              'sub': 'Lossless 320kbps'
                            },
                            {
                              'emoji': '🗺️',
                              'title': 'Full Memory Map',
                              'sub': 'Unlimited memories'
                            },
                            {
                              'emoji': '🎤',
                              'title': 'Lyrics Sync',
                              'sub': 'Real-time lyrics'
                            },
                            {
                              'emoji': '📊',
                              'title': 'Listening Stats',
                              'sub': 'Deep insights'
                            },
                          ].map((f) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(f['emoji']!,
                                          style: const TextStyle(fontSize: 22)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(f['title']!,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                )),
                                            Text(f['sub']!,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.textSecond,
                                                )),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppColors.success, size: 18),
                                    ],
                                  ),
                                ),
                              )),

                          const SizedBox(height: 8),

                          // trial note
                          const Center(
                            child: Text(
                              '✨ 7-day free trial · Cancel anytime',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textSecond),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),

                // CTA button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '⚡ Start Free Trial',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1a0a00),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
