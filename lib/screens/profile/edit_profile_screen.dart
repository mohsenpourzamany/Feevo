import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/feevo_button.dart';
import '../../core/widgets/feevo_input.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {

  final _nameCtrl     = TextEditingController(text: 'Barad');
  final _usernameCtrl = TextEditingController(text: 'barad');
  final _bioCtrl      = TextEditingController(text: 'Music lover 🎵');
  final _emailCtrl    = TextEditingController(text: 'barad@feevo.music');
  bool  _isLoading    = false;
  int   _selectedAvatar = 3; // cat index 1-7

  late AnimationController _ctrl;
  late Animation<double>   _opacity;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _slide   = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _emailCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.pop();
  }

  String _catAsset(int i) {
    switch (i) {
      case 1: return AppConstants.cat1;
      case 2: return AppConstants.cat2;
      case 3: return AppConstants.cat3;
      case 4: return AppConstants.cat4;
      case 5: return AppConstants.cat5;
      case 6: return AppConstants.cat6;
      case 7: return AppConstants.cat7;
      default: return AppConstants.cat1;
    }
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
                  AppColors.purple.withOpacity(0.14),
                  AppColors.purple.withOpacity(0),
                ]),
              ),
            ),
          ),

          SafeArea(
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _opacity,
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
                        const Text(
                          'Edit Profile ✏️',
                          style: TextStyle(
                            fontSize:      22,
                            fontWeight:    FontWeight.w800,
                            color:         AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // avatar picker
                    Center(
                      child: Column(
                        children: [
                          // current avatar
                          Stack(
                            children: [
                              Container(
                                width: 88, height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.primaryGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color:      AppColors.purple.withOpacity(0.45),
                                      blurRadius: 20,
                                      offset:     const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Image.asset(
                                    _catAsset(_selectedAvatar),
                                    width:  60,
                                    height: 60,
                                    fit:    BoxFit.contain,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  width: 26, height: 26,
                                  decoration: BoxDecoration(
                                    shape:    BoxShape.circle,
                                    gradient: AppColors.primaryGradient,
                                    border: Border.all(color: AppColors.bg, width: 2),
                                  ),
                                  child: const Icon(Icons.edit_rounded,
                                      color: Colors.white, size: 12),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // cat picker
                          const Text(
                            'Choose your mascot',
                            style: TextStyle(
                              fontSize:   11,
                              color:      AppColors.textSecond,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 52,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap:      true,
                              itemCount:       7,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final idx    = i + 1;
                                final active = _selectedAvatar == idx;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedAvatar = idx),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: active ? AppColors.primaryGradient : null,
                                      color:    active ? null : AppColors.surface,
                                      border: Border.all(
                                        color: active ? AppColors.purple2 : AppColors.border,
                                        width: active ? 2 : 1,
                                      ),
                                      boxShadow: active ? [
                                        BoxShadow(
                                          color:      AppColors.purple.withOpacity(0.4),
                                          blurRadius: 10,
                                        ),
                                      ] : [],
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        _catAsset(idx),
                                        width:  30,
                                        height: 30,
                                        fit:    BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // form fields
                    FeevoInput(
                      label:       'Full Name',
                      placeholder: 'Your name',
                      controller:  _nameCtrl,
                    ),
                    const SizedBox(height: 14),

                    FeevoInput(
                      label:       'Username',
                      placeholder: '@username',
                      controller:  _usernameCtrl,
                    ),
                    const SizedBox(height: 14),

                    // bio
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bio',
                          style: TextStyle(
                            fontSize:   11,
                            fontWeight: FontWeight.w600,
                            color:      AppColors.textSecond,
                            letterSpacing: .5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color:        AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border:       Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller:  _bioCtrl,
                            maxLines:    3,
                            maxLength:   120,
                            style: const TextStyle(
                              fontSize: 13,
                              color:    AppColors.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText:       'Tell us about yourself...',
                              hintStyle:      TextStyle(color: AppColors.textThird, fontSize: 13),
                              border:         InputBorder.none,
                              contentPadding: EdgeInsets.all(14),
                              counterStyle:   TextStyle(color: AppColors.textThird, fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    FeevoInput(
                      label:        'Email',
                      placeholder:  'your@email.com',
                      controller:   _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      enabled:      false,
                    ),

                    const SizedBox(height: 6),
                    const Text(
                      '* Email cannot be changed here. Contact support.',
                      style: TextStyle(fontSize: 10, color: AppColors.textThird),
                    ),

                    const SizedBox(height: 28),

                    FeevoButton(
                      label:     'Save Changes ✓',
                      onTap:     _save,
                      isLoading: _isLoading,
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
