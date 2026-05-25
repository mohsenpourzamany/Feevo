import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late AnimationController _catController;
  late AnimationController _textController;
  late AnimationController _floatController;
  late AnimationController _orbController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _catSlide;
  late Animation<double> _catOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _catFloat;
  late Animation<double> _orbScale;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _orbScale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _orbController, curve: Curves.easeInOut),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _catController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _catSlide = Tween<double>(begin: 80, end: 0).animate(
      CurvedAnimation(parent: _catController, curve: Curves.easeOutCubic),
    );
    _catOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _catController, curve: Curves.easeIn),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _catFloat = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _catController.forward();

    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    _navigate();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken);

    if (!mounted) return;

    // فقط token چک می‌کنیم
    // اگه لاگین بود → home
    // اگه نبود → login
    if (token != null) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _catController.dispose();
    _textController.dispose();
    _floatController.dispose();
    _orbController.dispose();
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
            top: -150, left: -100,
            child: AnimatedBuilder(
              animation: _orbScale,
              builder: (_, __) => Transform.scale(
                scale: _orbScale.value,
                child: Container(
                  width: 500, height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.purple.withOpacity(0.18),
                      AppColors.purple.withOpacity(0),
                    ]),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80, right: -80,
            child: Container(
              width: 350, height: 350,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 16),
                      _buildTagline(),
                    ],
                  ),
                ),
                _buildCat(),
                const SizedBox(height: 24),
                _buildDots(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (_, __) => Opacity(
        opacity: _logoOpacity.value,
        child: Transform.scale(
          scale: _logoScale.value,
          child: Column(
            children: [
              Container(
                width: 72, height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft:     Radius.circular(36),
                    topRight:    Radius.circular(36),
                    bottomLeft:  Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:        AppColors.purple.withOpacity(0.6),
                      blurRadius:   40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.92),
                      boxShadow: [
                        BoxShadow(
                          color:      Colors.white.withOpacity(0.8),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.textGradient.createShader(bounds),
                child: const Text(
                  'feevo',
                  style: TextStyle(
                    fontSize:      44,
                    fontWeight:    FontWeight.w800,
                    color:         Colors.white,
                    letterSpacing: -2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (_, __) => Opacity(
        opacity: _textOpacity.value,
        child: const Text(
          'Feel the music. Live the vibe.',
          style: TextStyle(
            fontSize:      12,
            color:         AppColors.textSecond,
            letterSpacing: 1.5,
            fontWeight:    FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildCat() {
    return AnimatedBuilder(
      animation: Listenable.merge([_catController, _floatController]),
      builder: (_, __) => Opacity(
        opacity: _catOpacity.value,
        child: Transform.translate(
          offset: Offset(0, _catSlide.value + _catFloat.value),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color:      AppColors.purple.withOpacity(0.5),
                  blurRadius: 40,
                  offset:     const Offset(0, 12),
                ),
              ],
            ),
            child: Image.asset(
              AppConstants.cat1,
              width: 220, height: 220,
              fit:   BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i * 0.3;
            final t     = (_floatController.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + (0.5 * (1 - (2 * t - 1).abs()));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.purple2.withOpacity(0.8),
                  ),
                ),
              ),
            );
          }),
        );
      },
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
