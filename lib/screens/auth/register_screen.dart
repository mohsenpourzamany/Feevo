import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/feevo_button.dart';
import '../../core/widgets/feevo_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {

  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool  _isLoading   = false;
  bool  _agreedTerms = false;

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

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    _catController.dispose(); _floatController.dispose(); _contentController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please agree to Terms & Privacy Policy'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() => _isLoading = true);
    // TODO: connect to Supabase auth
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    // after register → verify email
    context.go(AppRoutes.verifyEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(top: -120, right: -60, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.cyan.withOpacity(0.12), AppColors.cyan.withOpacity(0)])))),
          Positioned(bottom: -60, left: -60, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.purple.withOpacity(0.15), AppColors.purple.withOpacity(0)])))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // cat_2 hype
                    AnimatedBuilder(
                      animation: Listenable.merge([_catController, _floatController]),
                      builder: (_, __) => Opacity(
                        opacity: _catOpacity.value,
                        child: Transform.scale(
                          scale: _catScale.value,
                          child: Transform.translate(
                            offset: Offset(0, _catFloat.value),
                            child: Column(children: [
                              Container(
                                decoration: BoxDecoration(boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 40, spreadRadius: 4, offset: const Offset(0, 10))]),
                                child: Image.asset(AppConstants.cat2, width: 110, height: 110, fit: BoxFit.contain),
                              ),
                              const SizedBox(height: 12),
                              const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                              const SizedBox(height: 4),
                              const Text('Join Feevo 🎵', style: TextStyle(fontSize: 13, color: AppColors.textSecond)),
                            ]),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    SlideTransition(
                      position: _contentSlide,
                      child: FadeTransition(
                        opacity: _contentOpacity,
                        child: Column(children: [

                          FeevoInput(label: 'Full Name', placeholder: 'Your name', controller: _nameCtrl,
                            validator: (v) { if (v == null || v.isEmpty) return 'Name is required'; return null; }),
                          const SizedBox(height: 16),

                          FeevoInput(label: 'Email', placeholder: 'your@email.com', controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                            validator: (v) { if (v == null || v.isEmpty) return 'Email is required'; if (!v.contains('@')) return 'Enter a valid email'; return null; }),
                          const SizedBox(height: 16),

                          FeevoInput(label: 'Password', placeholder: 'Min. 8 characters', controller: _passCtrl, isPassword: true,
                            validator: (v) { if (v == null || v.isEmpty) return 'Password is required'; if (v.length < 8) return 'Min. 8 characters'; return null; }),
                          const SizedBox(height: 16),

                          FeevoInput(label: 'Confirm Password', placeholder: '••••••••', controller: _confirmCtrl, isPassword: true,
                            validator: (v) { if (v == null || v.isEmpty) return 'Please confirm your password'; if (v != _passCtrl.text) return 'Passwords do not match'; return null; }),
                          const SizedBox(height: 20),

                          // terms
                          GestureDetector(
                            onTap: () => setState(() => _agreedTerms = !_agreedTerms),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _agreedTerms ? AppColors.purple : AppColors.border),
                              ),
                              child: Row(children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22, height: 22,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    gradient: _agreedTerms ? AppColors.primaryGradient : null,
                                    color: _agreedTerms ? null : Colors.transparent,
                                    border: _agreedTerms ? null : Border.all(color: AppColors.border),
                                  ),
                                  child: _agreedTerms ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: const TextSpan(
                                      style: TextStyle(fontSize: 12, color: AppColors.textSecond, height: 1.5),
                                      children: [
                                        TextSpan(text: "I agree to Feevo's "),
                                        TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.purple3, fontWeight: FontWeight.w600)),
                                        TextSpan(text: ' and '),
                                        TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.purple3, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),

                          const SizedBox(height: 24),
                          FeevoButton(label: 'Create Account 🚀', onTap: _register, isLoading: _isLoading),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account? ', style: TextStyle(fontSize: 13, color: AppColors.textSecond)),
                              GestureDetector(
                                onTap: () => context.go(AppRoutes.login),
                                child: const Text('Sign In', style: TextStyle(fontSize: 13, color: AppColors.purple3, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ]),
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
