import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/feevo_button.dart';
import '../../core/widgets/feevo_input.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen>
    with TickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  String _selectedVibe = 'chill';
  String _selectedPrivacy = 'public';
  bool _aiDjEnabled = true;
  bool _isLoading = false;

  late AnimationController _catController;
  late AnimationController _floatController;
  late AnimationController _contentController;

  late Animation<double> _catScale;
  late Animation<double> _catOpacity;
  late Animation<double> _catFloat;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  final List<Map<String, String>> _vibes = [
    {'id': 'chill', 'label': 'Chill', 'emoji': '🌙'},
    {'id': 'energetic', 'label': 'Energy', 'emoji': '⚡'},
    {'id': 'hype', 'label': 'Hype', 'emoji': '🔥'},
    {'id': 'focused', 'label': 'Focus', 'emoji': '💭'},
    {'id': 'happy', 'label': 'Happy', 'emoji': '💗'},
    {'id': 'jazz', 'label': 'Jazz', 'emoji': '🎷'},
  ];

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
    _catFloat = Tween<double>(begin: 0, end: -8).animate(
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
  }

  void _playEntrance() {
    _catController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _catController.dispose();
    _floatController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _goLive() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a room name'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go(AppRoutes.liveRoomIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(
            top: -120,
            right: -60,
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
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
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
              position: _contentSlide,
              child: FadeTransition(
                opacity: _contentOpacity,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  children: [
                    // header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: AppColors.textSecond, size: 18),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Create Room 🎙️',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // cat_6 thinking
                    Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge(
                            [_catController, _floatController]),
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
                                      blurRadius: 30,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  AppConstants.cat6,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // room name
                    FeevoInput(
                      label: 'Room Name',
                      placeholder: 'e.g. Late Night Chill 🌙',
                      controller: _nameCtrl,
                      validator: (_) => null,
                    ),

                    const SizedBox(height: 18),

                    // vibe picker
                    const Text(
                      'Vibe',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecond,
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _vibes.map((v) {
                        final active = _selectedVibe == v['id'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedVibe = v['id']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              gradient: active
                                  ? LinearGradient(colors: [
                                      AppColors.purple.withOpacity(0.3),
                                      AppColors.cyan.withOpacity(0.15),
                                    ])
                                  : null,
                              color: active ? null : AppColors.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: active
                                    ? AppColors.purple2
                                    : AppColors.border,
                                width: active ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              '${v['emoji']} ${v['label']}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: active
                                    ? AppColors.purple3
                                    : AppColors.textSecond,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // AI DJ toggle
                    GestureDetector(
                      onTap: () => setState(() => _aiDjEnabled = !_aiDjEnabled),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: _aiDjEnabled
                              ? LinearGradient(colors: [
                                  AppColors.purple.withOpacity(0.18),
                                  AppColors.cyan.withOpacity(0.08),
                                ])
                              : null,
                          color: _aiDjEnabled ? null : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _aiDjEnabled
                                ? AppColors.border2
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              AppConstants.cat1,
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'AI DJ 🤖',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Auto-curates music for your room',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecond,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // toggle
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 46,
                              height: 26,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: _aiDjEnabled
                                    ? AppColors.primaryGradient
                                    : null,
                                color: _aiDjEnabled ? null : AppColors.surface2,
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 200),
                                alignment: _aiDjEnabled
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.all(3),
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // privacy
                    const Text(
                      'Privacy',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecond,
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _PrivacyCard(
                          emoji: '🌍',
                          label: 'Public',
                          sub: 'Anyone can join',
                          isActive: _selectedPrivacy == 'public',
                          onTap: () =>
                              setState(() => _selectedPrivacy = 'public'),
                        ),
                        const SizedBox(width: 10),
                        _PrivacyCard(
                          emoji: '🔒',
                          label: 'Private',
                          sub: 'Invite only',
                          isActive: _selectedPrivacy == 'private',
                          onTap: () =>
                              setState(() => _selectedPrivacy = 'private'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // go live button
                    FeevoButton(
                      label: '🎙️ Go Live Now',
                      onTap: _goLive,
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 12),

                    const Center(
                      child: Text(
                        'Your room will be visible to others immediately',
                        style:
                            TextStyle(fontSize: 11, color: AppColors.textThird),
                        textAlign: TextAlign.center,
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

// ── Privacy Card ─────────────────────────────────────────────
class _PrivacyCard extends StatelessWidget {
  final String emoji, label, sub;
  final bool isActive;
  final VoidCallback onTap;

  const _PrivacyCard({
    required this.emoji,
    required this.label,
    required this.sub,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(colors: [
                    AppColors.purple.withOpacity(0.2),
                    AppColors.cyan.withOpacity(0.1),
                  ])
                : null,
            color: isActive ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppColors.purple2 : AppColors.border,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color:
                      isActive ? AppColors.textPrimary : AppColors.textSecond,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textThird,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Grid ─────────────────────────────────────────────────────
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
