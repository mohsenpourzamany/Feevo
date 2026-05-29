import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/feevo_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  late AnimationController _entranceController;
  late Animation<double> _entranceScale;
  late Animation<double> _entranceOpacity;

  static const List<_PageData> _pages = [
    _PageData(
      catAsset: AppConstants.cat2,
      title: 'Music that ',
      titleAccent: 'feels you',
      titleEnd: ' 🎵',
      desc:
          'Feevo transforms your music experience — based on your mood, memories, and moments.',
      cta: "Let's Go ✨",
    ),
    _PageData(
      catAsset: AppConstants.cat3,
      title: '',
      titleAccent: 'Mood Flow',
      titleEnd: ' 🌊',
      desc:
          'Tell us how you feel — AI builds your perfect musical journey, just for this moment.',
      cta: 'Sounds Amazing →',
    ),
    _PageData(
      catAsset: AppConstants.cat1,
      title: '',
      titleAccent: 'Live Rooms',
      titleEnd: ' 🏠',
      desc:
          'Listen with thousands simultaneously — AI DJ curates tracks based on crowd reactions.',
      cta: 'Join the Vibe →',
    ),
    _PageData(
      catAsset: AppConstants.cat6,
      title: '',
      titleAccent: 'Memory Map',
      titleEnd: ' 🗺️',
      desc:
          'AI builds your musical memory map — when, where, and how you felt.',
      cta: "That's Beautiful ✨",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entranceScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );
    _entranceOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeIn),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _entranceController.reset();
    _entranceController.forward();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboarded, true);
    if (!mounted) return;
    context.go(AppRoutes.login); // onboarding تموم → login
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
                  AppColors.purple.withOpacity(0.15),
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
                  AppColors.cyan.withOpacity(0.08),
                  AppColors.cyan.withOpacity(0),
                ]),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_currentPage + 1} / ${_pages.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textThird,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_currentPage < _pages.length - 1)
                        GestureDetector(
                          onTap: _finish,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecond,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 60),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) => _buildPage(_pages[index]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) {
                          final active = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 28 : 8,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient:
                                  active ? AppColors.primaryGradient : null,
                              color: active
                                  ? null
                                  : AppColors.textThird.withOpacity(0.4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      FeevoButton(
                        label: _pages[_currentPage].cta,
                        onTap: _next,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_PageData page) {
    return Column(
      children: [
        Expanded(
          flex: 55,
          child: Center(
            child: AnimatedBuilder(
              animation:
                  Listenable.merge([_entranceController, _floatController]),
              builder: (context, _) {
                return Opacity(
                  opacity: _entranceOpacity.value,
                  child: Transform.scale(
                    scale: _entranceScale.value,
                    child: Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purple.withOpacity(0.4),
                              blurRadius: 60,
                              spreadRadius: 8,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          page.catAsset,
                          width: 260,
                          height: 260,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 45,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      if (page.title.isNotEmpty)
                        TextSpan(
                          text: page.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                          child: Text(
                            page.titleAccent,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      if (page.titleEnd.isNotEmpty)
                        TextSpan(
                          text: page.titleEnd,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  page.desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecond,
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PageData {
  final String catAsset, title, titleAccent, titleEnd, desc, cta;
  const _PageData({
    required this.catAsset,
    required this.title,
    required this.titleAccent,
    required this.titleEnd,
    required this.desc,
    required this.cta,
  });
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
