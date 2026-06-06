import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  late AnimationController _logoController,
      _textController,
      _orbController,
      _dotsController;
  late Animation<double> _logoScale,
      _logoOpacity,
      _textOpacity,
      _orbScale,
      _dotsOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _orbController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);
    _orbScale = Tween<double>(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _orbController, curve: Curves.easeInOut));

    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _textController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _dotsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _dotsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _dotsController, curve: Curves.easeIn));
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
    _dotsController.forward();

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    _navigate();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    final prefs = await SharedPreferences.getInstance();
    final isOnboarded = prefs.getBool(AppConstants.keyOnboarded) ?? false;
    if (!mounted) return;

    if (session != null) {
      context.go(AppRoutes.home);
    } else if (!isOnboarded) {
      context.go(AppRoutes.onboarding);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _orbController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),

        // orbs
        Positioned(
            top: -150,
            left: -100,
            child: AnimatedBuilder(
              animation: _orbScale,
              builder: (_, __) => Transform.scale(
                  scale: _orbScale.value,
                  child: Container(
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            AppColors.purple.withOpacity(0.18),
                            AppColors.purple.withOpacity(0)
                          ])))),
            )),
        Positioned(
            bottom: -80,
            right: -80,
            child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.cyan.withOpacity(0.1),
                      AppColors.cyan.withOpacity(0)
                    ])))),

        // center content
        Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // logo mark
            AnimatedBuilder(
              animation: _logoController,
              builder: (_, __) => Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Column(children: [
                    // icon
                    Container(
                      width: 80,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                          bottomLeft: Radius.circular(44),
                          bottomRight: Radius.circular(44),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.purple.withOpacity(0.6),
                              blurRadius: 40,
                              spreadRadius: 4)
                        ],
                      ),
                      child: Center(
                          child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.92),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 16)
                            ]),
                      )),
                    ),

                    const SizedBox(height: 20),

                    // wordmark
                    ShaderMask(
                      shaderCallback: (b) =>
                          AppColors.textGradient.createShader(b),
                      child: const Text('feevo',
                          style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -2.5)),
                    ),
                  ]),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // tagline
            AnimatedBuilder(
              animation: _textController,
              builder: (_, __) => Opacity(
                opacity: _textOpacity.value,
                child: const Text('Feel the music. Live the vibe.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecond,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w400)),
              ),
            ),

            const SizedBox(height: 60),

            // loading dots
            AnimatedBuilder(
              animation: Listenable.merge([_dotsController, _orbController]),
              builder: (_, __) => Opacity(
                opacity: _dotsOpacity.value,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final delay = i * 0.33;
                      final t = (_orbController.value - delay).clamp(0.0, 1.0);
                      final scale = 0.4 + (0.6 * (1 - (2 * t - 1).abs()));
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Transform.scale(
                            scale: scale,
                            child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.primaryGradient))),
                      );
                    })),
              ),
            ),
          ]),
        ),

        // version
        Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (_, __) => Opacity(
                  opacity: _textOpacity.value,
                  child: const Center(
                      child: Text('v1.0.0',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textThird,
                              letterSpacing: 1)))),
            )),
      ]),
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
