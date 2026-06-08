import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/feevo_button.dart';
import '../../core/widgets/feevo_input.dart';
import '../../core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  late AnimationController _catController, _floatController, _contentController;
  late Animation<double> _catScale, _catOpacity, _catFloat, _contentOpacity;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _catController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _catScale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _catController, curve: Curves.elasticOut));
    _catOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _catController, curve: Curves.easeIn));
    _floatController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3500))
      ..repeat(reverse: true);
    _catFloat = Tween<double>(begin: 0, end: -10).animate(
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _contentController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _contentController, curve: Curves.easeOutCubic));
    _catController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _catController.dispose();
    _floatController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok =
        await auth.signIn(email: _emailCtrl.text, password: _passCtrl.text);
    if (!mounted) return;
    if (ok) context.go(AppRoutes.home);
  }

  Future<void> _loginWithGoogle() async =>
      context.read<AuthProvider>().signInWithGoogle();
  Future<void> _loginWithApple() async =>
      context.read<AuthProvider>().signInWithApple();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Positioned(
            top: -150,
            left: -100,
            child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.purple.withOpacity(0.18),
                      AppColors.purple.withOpacity(0)
                    ])))),
        Positioned(
            bottom: -80,
            right: -80,
            child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.cyan.withOpacity(0.08),
                      AppColors.cyan.withOpacity(0)
                    ])))),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(children: [
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation:
                      Listenable.merge([_catController, _floatController]),
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
                                          color:
                                              AppColors.purple.withOpacity(0.4),
                                          blurRadius: 40,
                                          spreadRadius: 4,
                                          offset: const Offset(0, 10))
                                    ]),
                                    child: Image.asset(AppConstants.cat7,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.contain)),
                                const SizedBox(height: 12),
                                ShaderMask(
                                    shaderCallback: (bounds) => AppColors
                                        .textGradient
                                        .createShader(bounds),
                                    child: const Text('feevo',
                                        style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: -1))),
                                const SizedBox(height: 6),
                                const Text('Welcome back 👋',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecond)),
                              ])))),
                ),
                const SizedBox(height: 32),
                SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentOpacity,
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) => Column(children: [
                        _SocialButton(
                            label: 'Continue with Google',
                            isGoogle: true,
                            onTap: _loginWithGoogle),
                        const SizedBox(height: 12),
                        _SocialButton(
                            label: 'Continue with Apple',
                            isGoogle: false,
                            onTap: _loginWithApple),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(
                              child: Container(
                                  height: 1, color: AppColors.border)),
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('or',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textThird))),
                          Expanded(
                              child: Container(
                                  height: 1, color: AppColors.border)),
                        ]),
                        const SizedBox(height: 20),
                        FeevoInput(
                            label: 'Email',
                            placeholder: 'your@email.com',
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Email is required';
                              if (!v.contains('@'))
                                return 'Enter a valid email';
                              return null;
                            }),
                        const SizedBox(height: 16),
                        FeevoInput(
                            label: 'Password',
                            placeholder: '••••••••',
                            controller: _passCtrl,
                            isPassword: true,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Password is required';
                              if (v.length < 6) return 'Min. 6 characters';
                              return null;
                            }),
                        const SizedBox(height: 10),
                        Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                                onTap: () => context.push(AppRoutes.forgotPass),
                                child: const Text('Forgot password?',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.purple3,
                                        fontWeight: FontWeight.w600)))),
                        if (auth.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.red.withOpacity(0.3))),
                              child: Text(auth.errorMessage!,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.redAccent))),
                        ],
                        const SizedBox(height: 24),
                        FeevoButton(
                            label: 'Sign In',
                            onTap: auth.isLoading ? null : _login,
                            isLoading: auth.isLoading),
                        const SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? ",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecond)),
                              GestureDetector(
                                  onTap: () => context.go(AppRoutes.register),
                                  child: const Text('Sign Up',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.purple3,
                                          fontWeight: FontWeight.w700))),
                            ]),
                        const SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final bool isGoogle;
  final VoidCallback onTap;
  const _SocialButton(
      {required this.label, required this.isGoogle, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            isGoogle
                ? const Text('G',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFEA4335)))
                : const Text('🍎', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ]),
        ),
      );
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
