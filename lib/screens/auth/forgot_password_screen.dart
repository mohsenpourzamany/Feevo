import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/feevo_button.dart';
import '../../core/widgets/feevo_input.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {

  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool  _isLoading = false;
  bool  _sent      = false;

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
  }

  void _setupAnimations() {
    _catController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _catScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _catController, curve: Curves.elasticOut),
    );
    _catOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _catController, curve: Curves.easeIn),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
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
      begin: const Offset(0, 0.08),
      end:   Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
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
    _emailCtrl.dispose();
    _catController.dispose();
    _floatController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: connect to Supabase auth
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _sent      = true;
    });
    // reset cat animation for success state
    _catController.reset();
    _catController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // grid
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),

          // orb
          Positioned(
            top: -150, left: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.purple.withOpacity(0.15),
                    AppColors.purple.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -80, right: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyan.withOpacity(0.08),
                    AppColors.cyan.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // back button
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width:  40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:        AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border:       Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textSecond,
                          size:  16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // cat + title
                    Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _catController,
                          _floatController,
                        ]),
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
                                      color: AppColors.purple.withOpacity(0.4),
                                      blurRadius:   40,
                                      spreadRadius: 4,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                // cat_7 if not sent, cat_2 if sent
                                child: Image.asset(
                                  _sent
                                      ? AppConstants.cat2
                                      : AppConstants.cat7,
                                  width:  120,
                                  height: 120,
                                  fit:    BoxFit.contain,
                                ),
                              ),
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
                        child: _sent
                            ? _buildSuccessState()
                            : _buildFormState(),
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

  // ── Form state ───────────────────────────────────────────
  Widget _buildFormState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize:      26,
            fontWeight:    FontWeight.w800,
            color:         AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'No worries! Enter your email and we\'ll send you a reset link.',
          style: TextStyle(
            fontSize: 13,
            color:    AppColors.textSecond,
            height:   1.7,
          ),
        ),
        const SizedBox(height: 28),

        FeevoInput(
          label:        'Email Address',
          placeholder:  'your@email.com',
          controller:   _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          suffixIcon:   const Icon(
            Icons.email_outlined,
            color: AppColors.textThird,
            size:  20,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Email is required';
            if (!v.contains('@'))       return 'Enter a valid email';
            return null;
          },
        ),

        const SizedBox(height: 24),

        FeevoButton(
          label:     'Send Reset Link 📨',
          onTap:     _sendReset,
          isLoading: _isLoading,
        ),

        const SizedBox(height: 16),

        // info note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:        AppColors.cyan.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border:       Border.all(
              color: AppColors.cyan.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.cyan2,
                size:  18,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Check your spam folder if you don\'t see the email.',
                  style: TextStyle(
                    fontSize: 11,
                    color:    AppColors.textSecond,
                    height:   1.6,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Center(
          child: GestureDetector(
            onTap: () => context.pop(),
            child: const Text(
              'Remember it? Sign In',
              style: TextStyle(
                fontSize:   13,
                color:      AppColors.purple3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  // ── Success state ────────────────────────────────────────
  Widget _buildSuccessState() {
    return Column(
      children: [
        // success badge
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color:        AppColors.successBg,
            borderRadius: BorderRadius.circular(999),
            border:       Border.all(
              color: AppColors.success.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.success,
                size:  18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Email Sent!',
                style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w700,
                  color:      AppColors.success,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Check Your Inbox 📬',
          style: TextStyle(
            fontSize:      26,
            fontWeight:    FontWeight.w800,
            color:         AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 10),

        Text(
          'We sent a reset link to\n${_emailCtrl.text}',
          style: const TextStyle(
            fontSize: 13,
            color:    AppColors.textSecond,
            height:   1.7,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        FeevoButton(
          label: 'Back to Sign In',
          onTap: () => context.go(AppRoutes.login),
        ),

        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => setState(() => _sent = false),
          child: const Text(
            'Resend Email',
            style: TextStyle(
              fontSize:   13,
              color:      AppColors.purple3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 40),
      ],
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
