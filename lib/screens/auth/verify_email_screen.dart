import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/feevo_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with TickerProviderStateMixin {

  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(4, (_) => FocusNode());

  bool _isLoading  = false;
  bool _isVerified = false;
  int  _resendTimer = 42;

  late AnimationController _catController;
  late AnimationController _floatController;
  late AnimationController _contentController;

  late Animation<double> _catScale;
  late Animation<double> _catOpacity;
  late Animation<double> _catFloat;
  late Animation<double> _contentOpacity;
  late Animation<Offset>  _contentSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playEntrance();
    _startTimer();
  }

  void _setupAnimations() {
    _catController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _catScale   = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _catController,   curve: Curves.elasticOut));
    _catOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _catController,   curve: Curves.easeIn));

    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat(reverse: true);
    _catFloat = Tween<double>(begin: 0, end: -10).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _contentController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    _contentSlide   = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));
  }

  void _playEntrance() {
    _catController.forward();
    Future.delayed(const Duration(milliseconds: 200), () { if (mounted) _contentController.forward(); });
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_resendTimer > 0) { setState(() => _resendTimer--); _startTimer(); }
    });
  }

  @override
  void dispose() {
    for (final c in _otpControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _catController.dispose(); _floatController.dispose(); _contentController.dispose();
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) _focusNodes[index + 1].requestFocus();
    if (value.isEmpty   && index > 0) _focusNodes[index - 1].requestFocus();
    setState(() {});
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length == 4) _verify();
  }

  Future<void> _verify() async {
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length < 4) return;
    setState(() => _isLoading = true);
    // TODO: verify with Supabase
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() { _isLoading = false; _isVerified = true; });
    _catController.reset();
    _catController.forward();

    // after verify → genre pick (first time setup)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    context.go(AppRoutes.genrePick);
  }

  void _resendCode() {
    if (_resendTimer > 0) return;
    setState(() => _resendTimer = 42);
    _startTimer();
    // TODO: resend via Supabase
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(top: -120, right: -60, child: Container(width: 380, height: 380, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.cyan.withOpacity(0.12), AppColors.cyan.withOpacity(0)])))),
          Positioned(bottom: -60, left: -60, child: Container(width: 280, height: 280, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.purple.withOpacity(0.12), AppColors.purple.withOpacity(0)])))),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textSecond, size: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // cat
                  AnimatedBuilder(
                    animation: Listenable.merge([_catController, _floatController]),
                    builder: (_, __) => Opacity(
                      opacity: _catOpacity.value,
                      child: Transform.scale(
                        scale: _catScale.value,
                        child: Transform.translate(
                          offset: Offset(0, _catFloat.value),
                          child: Container(
                            decoration: BoxDecoration(boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 40, spreadRadius: 4, offset: const Offset(0, 10))]),
                            child: Image.asset(_isVerified ? AppConstants.cat1 : AppConstants.cat2, width: 130, height: 130, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: _isVerified ? _buildSuccessState() : _buildOtpState(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppColors.bg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                    child: const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.purple)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOtpState() {
    return Column(children: [
      const Text('Check Your Email! 📬', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5), textAlign: TextAlign.center),
      const SizedBox(height: 10),
      const Text('We sent a verification code to your email address.', style: TextStyle(fontSize: 13, color: AppColors.textSecond, height: 1.7), textAlign: TextAlign.center),
      const SizedBox(height: 32),

      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, _buildOtpBox)),

      const SizedBox(height: 32),
      FeevoButton(label: 'Verify Account ✓', onTap: _verify),
      const SizedBox(height: 20),

      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text("Didn't receive it? ", style: TextStyle(fontSize: 13, color: AppColors.textSecond)),
        GestureDetector(
          onTap: _resendTimer == 0 ? _resendCode : null,
          child: Text(
            _resendTimer > 0 ? 'Resend in 0:${_resendTimer.toString().padLeft(2, '0')}' : 'Resend Code',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _resendTimer > 0 ? AppColors.textThird : AppColors.purple3),
          ),
        ),
      ]),
      const SizedBox(height: 40),
    ]);
  }

  Widget _buildOtpBox(int index) {
    final filled = _otpControllers[index].text.isNotEmpty;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 58, height: 64,
      decoration: BoxDecoration(
        gradient: filled ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.purple.withOpacity(0.25), AppColors.cyan.withOpacity(0.12)]) : null,
        color:        filled ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: filled ? AppColors.purple2 : AppColors.border, width: filled ? 1.5 : 1),
      ),
      child: TextField(
        controller: _otpControllers[index], focusNode: _focusNodes[index],
        textAlign: TextAlign.center, maxLength: 1, keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        decoration: const InputDecoration(counterText: '', border: InputBorder.none, filled: false),
        onChanged: (v) => _onOtpChanged(v, index),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.success.withOpacity(0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.verified_rounded, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          const Text('Account Verified!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success)),
        ]),
      ),
      const SizedBox(height: 20),
      const Text("You're all set! 🎉", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5), textAlign: TextAlign.center),
      const SizedBox(height: 10),
      const Text('Setting up your preferences...', style: TextStyle(fontSize: 13, color: AppColors.textSecond, height: 1.7), textAlign: TextAlign.center),
      const SizedBox(height: 32),
      const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.purple)),
      const SizedBox(height: 40),
    ]);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.purple.withOpacity(0.04)..strokeWidth = 1;
    const step = 44.0;
    for (double x = 0; x < size.width; x += step) { canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint); }
    for (double y = 0; y < size.height; y += step) { canvas.drawLine(Offset(0, y), Offset(size.width, y), paint); }
  }
  @override
  bool shouldRepaint(_GridPainter old) => false;
}
