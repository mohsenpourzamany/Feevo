import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/user_provider.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});
  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with TickerProviderStateMixin {
  bool _isYearly = false;
  bool _isLoading = false;

  late AnimationController _catController,
      _floatController,
      _contentController,
      _shineController;
  late Animation<double> _catScale,
      _catOpacity,
      _catFloat,
      _contentOpacity,
      _shine;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _catController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _catScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _catController, curve: Curves.elasticOut));
    _catOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _catController, curve: Curves.easeIn));
    _floatController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);
    _catFloat = Tween<double>(begin: 0, end: -10).animate(
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _contentController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _contentController, curve: Curves.easeOutCubic));
    _shineController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _shine = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(parent: _shineController, curve: Curves.easeInOut));
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

  Future<void> _startTrial(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
            color: Color(0xFF0F0F22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999))),
          const SizedBox(height: 20),
          const Text('⚡', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('Start 7-Day Free Trial',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            _isYearly
                ? 'After trial: \$71.99/year · Cancel anytime'
                : 'After trial: \$9.99/month · Cancel anytime',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecond),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              await _activatePremium();
              setState(() => _isLoading = false);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6))
                ],
              ),
              child: const Center(
                  child: Text('Confirm Free Trial',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1a0a00)))),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text('Maybe later',
                  style: TextStyle(fontSize: 12, color: AppColors.textThird))),
        ]),
      ),
    );
  }

  Future<void> _activatePremium() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final until = DateTime.now().add(const Duration(days: 7));
      await Supabase.instance.client.from('users').update({
        'is_premium': true,
        'premium_until': until.toIso8601String(),
      }).eq('id', userId);

      if (mounted) {
        context.read<UserProvider>().fetchProfile();
        _showSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Something went wrong. Try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  void _showSuccess() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => Container(
        decoration: const BoxDecoration(
            color: Color(0xFF0F0F22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999))),
          const SizedBox(height: 24),
          Image.asset(AppConstants.cat2, width: 100, height: 100),
          const SizedBox(height: 16),
          const Text('🎉 Welcome to Premium!',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Your 7-day free trial has started.\nEnjoy all features!',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecond, height: 1.6),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(999)),
              child: const Center(
                  child: Text('Start Exploring ✨',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white))),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
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
                      AppColors.purple.withOpacity(0)
                    ])))),
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
                      AppColors.cyan.withOpacity(0)
                    ])))),
        SafeArea(
          child: Column(children: [
            Expanded(
              child: SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentOpacity,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    children: [
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
                                      border:
                                          Border.all(color: AppColors.border)),
                                  child: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: AppColors.textSecond,
                                      size: 16)))),

                      const SizedBox(height: 16),

                      AnimatedBuilder(
                        animation: Listenable.merge(
                            [_catController, _floatController]),
                        builder: (_, __) => Opacity(
                            opacity: _catOpacity.value,
                            child: Transform.scale(
                                scale: _catScale.value,
                                child: Transform.translate(
                                    offset: Offset(0, _catFloat.value),
                                    child: Column(children: [
                                      Container(
                                          decoration: BoxDecoration(boxShadow: [
                                            BoxShadow(
                                                color: AppColors.purple
                                                    .withOpacity(0.5),
                                                blurRadius: 40,
                                                spreadRadius: 4,
                                                offset: const Offset(0, 10))
                                          ]),
                                          child: Image.asset(AppConstants.cat2,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.contain)),
                                      const SizedBox(height: 12),
                                      ShaderMask(
                                          shaderCallback: (b) =>
                                              const LinearGradient(colors: [
                                                Color(0xFFFFD700),
                                                Color(0xFFFFA500),
                                                Color(0xFFFFD700)
                                              ]).createShader(b),
                                          child: const Text('⚡ Feevo Premium',
                                              style: TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                  letterSpacing: -0.5))),
                                      const SizedBox(height: 6),
                                      const Text(
                                          'Unlock the full Feevo experience',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textSecond)),
                                    ])))),
                      ),

                      const SizedBox(height: 24),

                      // billing toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border)),
                        child: Row(children: [
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: !_isYearly
                                              ? [
                                                  BoxShadow(
                                                      color: AppColors.purple
                                                          .withOpacity(0.3),
                                                      blurRadius: 8)
                                                ]
                                              : []),
                                      child: Center(
                                          child: Text('Monthly',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: !_isYearly
                                                      ? Colors.white
                                                      : AppColors
                                                          .textSecond)))))),
                          Expanded(
                              child: GestureDetector(
                                  onTap: () => setState(() => _isYearly = true),
                                  child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                          gradient: _isYearly
                                              ? AppColors.primaryGradient
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: _isYearly
                                              ? [
                                                  BoxShadow(
                                                      color: AppColors.purple
                                                          .withOpacity(0.3),
                                                      blurRadius: 8)
                                                ]
                                              : []),
                                      child: Center(
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                            Text('Yearly',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: _isYearly
                                                        ? Colors.white
                                                        : AppColors
                                                            .textSecond)),
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
                                                        BorderRadius.circular(
                                                            999)),
                                                child: Text('-40%',
                                                    style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: _isYearly
                                                            ? Colors.white
                                                            : AppColors
                                                                .success))),
                                          ]))))),
                        ]),
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
                                    Color(0xFF0891B2)
                                  ]),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.purple.withOpacity(0.5),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8))
                              ]),
                          child: child,
                        ),
                        child: Column(children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(_isYearly ? '\$71.99' : '\$9.99',
                                    style: const TextStyle(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -1)),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 6, left: 4),
                                    child: Text(_isYearly ? '/year' : '/month',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white
                                                .withOpacity(0.7)))),
                                const Spacer(),
                                if (_isYearly)
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(999)),
                                      child: const Text('\$5.99/mo',
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white))),
                              ]),
                          if (_isYearly) ...[
                            const SizedBox(height: 4),
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
                                                .withOpacity(0.4))),
                                    child: const Text(
                                        '🎉 Save \$47.88 per year',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.success)))),
                          ],
                        ]),
                      ),

                      const SizedBox(height: 20),

                      const Text('Everything in Premium:',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
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
                                  border: Border.all(color: AppColors.border)),
                              child: Row(children: [
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
                                              color: AppColors.textPrimary)),
                                      Text(f['sub']!,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecond)),
                                    ])),
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.success, size: 18),
                              ]),
                            ),
                          )),

                      const SizedBox(height: 8),
                      const Center(
                          child: Text('✨ 7-day free trial · Cancel anytime',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textSecond))),
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
                onTap: _isLoading ? null : () => _startTrial(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Color(0xFF1a0a00), strokeWidth: 2))
                          : const Text('⚡ Start Free Trial',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1a0a00)))),
                ),
              ),
            ),
          ]),
        ),
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
