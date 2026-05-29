import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/bottom_nav_widget.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _catController;
  late AnimationController _floatController;
  late AnimationController _contentController;
  late Animation<double> _catScale, _catOpacity, _catFloat, _contentOpacity;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _catController     = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _catScale          = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _catController, curve: Curves.elasticOut));
    _catOpacity        = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _catController, curve: Curves.easeIn));
    _floatController   = AnimationController(vsync: this, duration: const Duration(milliseconds: 3500))..repeat(reverse: true);
    _catFloat          = Tween<double>(begin: 0, end: -8).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _contentController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _contentOpacity    = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    _contentSlide      = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));
    _catController.forward();
    Future.delayed(const Duration(milliseconds: 150), () { if (mounted) _contentController.forward(); });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchProfile();
    });
  }

  @override
  void dispose() {
    _catController.dispose();
    _floatController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().signOut();
    context.read<UserProvider>().clear();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(top: -120, left: -80, child: Container(width: 380, height: 380, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.purple.withOpacity(0.15), AppColors.purple.withOpacity(0)])))),
          Positioned(bottom: -60, right: -60, child: Container(width: 280, height: 280, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.cyan.withOpacity(0.08), AppColors.cyan.withOpacity(0)])))),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: Consumer<UserProvider>(
                        builder: (context, up, _) {
                          final user    = up.user;
                          final initial = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?';
                          return ListView(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            children: [
                              // header
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                const Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3)),
                                GestureDetector(
                                  onTap: () => context.push(AppRoutes.settings),
                                  child: Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)), child: const Icon(Icons.settings_outlined, color: AppColors.textSecond, size: 18)),
                                ),
                              ]),
                              const SizedBox(height: 20),

                              // profile card
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.purple.withOpacity(0.2), AppColors.cyan.withOpacity(0.08)]),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: AppColors.border2),
                                ),
                                child: Column(children: [
                                  Row(children: [
                                    Stack(children: [
                                      Container(
                                        width: 72, height: 72,
                                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient, boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]),
                                        child: up.isLoading
                                            ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                                            : Center(child: Text(initial, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white))),
                                      ),
                                      Positioned(
                                        bottom: -2, right: -2,
                                        child: AnimatedBuilder(
                                          animation: Listenable.merge([_catController, _floatController]),
                                          builder: (_, __) => Opacity(
                                            opacity: _catOpacity.value,
                                            child: Transform.scale(scale: _catScale.value, child: Transform.translate(offset: Offset(0, _catFloat.value * 0.5), child: Image.asset(AppConstants.cat4, width: 36, height: 36, fit: BoxFit.contain))),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(width: 14),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(user?.name ?? '...', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3)),
                                      const SizedBox(height: 2),
                                      Text(user?.email ?? '...', style: const TextStyle(fontSize: 11, color: AppColors.textSecond)),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.border)),
                                        child: Text(user?.isPremium == true ? '⚡ Premium' : '🎵 Free Plan', style: const TextStyle(fontSize: 10, color: AppColors.textSecond, fontWeight: FontWeight.w500)),
                                      ),
                                    ])),
                                    GestureDetector(
                                      onTap: () => context.push(AppRoutes.editProfile),
                                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(999)), child: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white))),
                                    ),
                                  ]),
                                  const SizedBox(height: 16),
                                  Row(children: [
                                    _Stat('230', 'Tracks'), _Sep(), _Stat('47', 'Memories'), _Sep(), _Stat('12', 'Playlists'), _Sep(), _Stat('8', 'Live Rooms'),
                                  ]),
                                ]),
                              ),

                              const SizedBox(height: 16),

                              // premium banner
                              if (user?.isPremium != true)
                                GestureDetector(
                                  onTap: () => context.push(AppRoutes.premium),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)]), borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]),
                                    child: Row(children: [
                                      const Text('⚡', style: TextStyle(fontSize: 28)),
                                      const SizedBox(width: 12),
                                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text('Upgrade to Premium', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                                        SizedBox(height: 2),
                                        Text('Unlimited music, AI features & more', style: TextStyle(fontSize: 11, color: Colors.white70)),
                                      ])),
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(999)), child: const Text('Try Free', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
                                    ]),
                                  ),
                                ),

                              const SizedBox(height: 16),
                              const Text('Your Top Genres', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const SizedBox(height: 10),
                              Row(children: [
                                _Genre('🎹', 'Electronic', 42), const SizedBox(width: 8),
                                _Genre('🌙', 'Lo-Fi', 28),      const SizedBox(width: 8),
                                _Genre('🔥', 'Pop', 18),
                              ]),

                              const SizedBox(height: 20),
                              const Text('Account', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textThird, letterSpacing: 1.5)),
                              const SizedBox(height: 8),
                              _Item(Icons.person_outline_rounded,   'Edit Profile',       () => context.push(AppRoutes.editProfile)),
                              _Item(Icons.notifications_outlined,   'Notifications',      () => context.push(AppRoutes.notifications)),
                              _Item(Icons.language_outlined,        'Language',           () => context.push(AppRoutes.language), value: 'English'),

                              const SizedBox(height: 16),
                              const Text('More', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textThird, letterSpacing: 1.5)),
                              const SizedBox(height: 8),
                              _Item(Icons.star_outline_rounded,  'Rate Feevo',         () {}),
                              _Item(Icons.share_outlined,        'Share with Friends', () {}),
                              _Item(Icons.help_outline_rounded,  'Help & Support',     () {}),

                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: _logout,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.error.withOpacity(0.3))),
                                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                                    SizedBox(width: 8),
                                    Text('Log Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error)),
                                  ]),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Center(child: Text('Feevo v1.0.0 · feevo.music', style: TextStyle(fontSize: 10, color: AppColors.textThird))),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const FeevoBottomNav(currentIndex: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _Stat(String v, String l) => Expanded(child: Column(children: [Text(v, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)), Text(l, style: const TextStyle(fontSize: 9, color: AppColors.textThird))]));
Widget _Sep() => Container(width: 1, height: 30, color: AppColors.border);
Widget _Genre(String e, String l, int p) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.purple.withOpacity(0.15), AppColors.cyan.withOpacity(0.07)]), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border2)), child: Column(children: [Text(e, style: const TextStyle(fontSize: 20)), const SizedBox(height: 4), Text(l, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary)), Text('$p%', style: const TextStyle(fontSize: 9, color: AppColors.purple3))])));
Widget _Item(IconData icon, String label, VoidCallback onTap, {String? value}) => GestureDetector(onTap: onTap, child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)), child: Row(children: [Container(width: 32, height: 32, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.purple.withOpacity(0.2), AppColors.cyan.withOpacity(0.1)]), borderRadius: BorderRadius.circular(9)), child: Icon(icon, color: AppColors.purple3, size: 16)), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))), if (value != null) ...[Text(value, style: const TextStyle(fontSize: 11, color: AppColors.textSecond)), const SizedBox(width: 6)], const Icon(Icons.chevron_right_rounded, color: AppColors.textThird, size: 18)])));

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
