import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/feevo_button.dart';

class GenrePickScreen extends StatefulWidget {
  const GenrePickScreen({super.key});

  @override
  State<GenrePickScreen> createState() => _GenrePickScreenState();
}

class _GenrePickScreenState extends State<GenrePickScreen>
    with TickerProviderStateMixin {

  final Set<String> _selected = {};

  late AnimationController _catController;
  late AnimationController _floatController;
  late AnimationController _contentController;

  late Animation<double> _catScale;
  late Animation<double> _catOpacity;
  late Animation<double> _catFloat;
  late Animation<double> _contentOpacity;
  late Animation<Offset>  _contentSlide;

  static const List<_Genre> _genres = [
    _Genre(id: 'electronic', label: 'Electronic', emoji: '🎹'),
    _Genre(id: 'lofi',       label: 'Lo-Fi',      emoji: '🌙'),
    _Genre(id: 'rock',       label: 'Rock',        emoji: '🎸'),
    _Genre(id: 'pop',        label: 'Pop',         emoji: '🔥'),
    _Genre(id: 'hiphop',     label: 'Hip-Hop',     emoji: '🎤'),
    _Genre(id: 'classical',  label: 'Classical',   emoji: '🎻'),
    _Genre(id: 'jazz',       label: 'Jazz',        emoji: '🎷'),
    _Genre(id: 'rnb',        label: 'R&B',         emoji: '💗'),
    _Genre(id: 'metal',      label: 'Metal',       emoji: '⚡'),
    _Genre(id: 'ambient',    label: 'Ambient',     emoji: '🌊'),
  ];

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

    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3500))..repeat(reverse: true);
    _catFloat = Tween<double>(begin: 0, end: -10).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _contentController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    _contentSlide   = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));
  }

  void _playEntrance() {
    _catController.forward();
    Future.delayed(const Duration(milliseconds: 250), () { if (mounted) _contentController.forward(); });
  }

  @override
  void dispose() {
    _catController.dispose(); _floatController.dispose(); _contentController.dispose();
    super.dispose();
  }

  void _toggleGenre(String id) {
    setState(() {
      if (_selected.contains(id)) { _selected.remove(id); }
      else                        { _selected.add(id); }
    });
  }

  Future<void> _continue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('feevo_genres', _selected.toList());
    await prefs.setBool(AppConstants.keyGenreDone, true);
    if (!mounted) return;
    context.go(AppRoutes.home);
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
            child: Column(
              children: [
                // cat + title
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: Listenable.merge([_catController, _floatController]),
                        builder: (_, __) => Opacity(
                          opacity: _catOpacity.value,
                          child: Transform.scale(
                            scale: _catScale.value,
                            child: Transform.translate(
                              offset: Offset(0, _catFloat.value),
                              child: Container(
                                decoration: BoxDecoration(boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.35), blurRadius: 28, spreadRadius: 4, offset: const Offset(0, 8))]),
                                child: Image.asset(AppConstants.cat7, width: 100, height: 100, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SlideTransition(
                          position: _contentSlide,
                          child: FadeTransition(
                            opacity: _contentOpacity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(text: TextSpan(children: [
                                  const TextSpan(text: "What's your ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: ShaderMask(
                                      shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                                      child: const Text('vibe?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                                    ),
                                  ),
                                ])),
                                const SizedBox(height: 4),
                                const Text('Pick a few — you can change later', style: TextStyle(fontSize: 12, color: AppColors.textSecond)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // genre grid
                Expanded(
                  child: SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, mainAxisSpacing: 12,
                            crossAxisSpacing: 12, childAspectRatio: 2.4,
                          ),
                          itemCount: _genres.length,
                          itemBuilder: (context, i) {
                            final genre    = _genres[i];
                            final isActive = _selected.contains(genre.id);
                            return _GenreChip(genre: genre, isActive: isActive, onTap: () => _toggleGenre(genre.id));
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // count + button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  child: Column(children: [
                    AnimatedOpacity(
                      opacity: _selected.isNotEmpty ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(999)),
                            child: Text('${_selected.length} selected', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ]),
                      ),
                    ),
                    FeevoButton(
                      label: _selected.isEmpty ? 'Skip for now →' : 'Start My Journey 🚀',
                      onTap: _continue,
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final _Genre genre; final bool isActive; final VoidCallback onTap;
  const _GenreChip({required this.genre, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: isActive ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.purple.withOpacity(0.3), AppColors.cyan.withOpacity(0.15)]) : null,
          color:        isActive ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActive ? AppColors.purple2 : AppColors.border, width: isActive ? 1.5 : 1),
          boxShadow: isActive ? [BoxShadow(color: AppColors.purple.withOpacity(0.2), blurRadius: 12, spreadRadius: 1)] : [],
        ),
        child: Row(children: [
          Text(genre.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(genre.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? AppColors.purple3 : AppColors.textSecond)),
          if (isActive) ...[
            const Spacer(),
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            ),
          ],
        ]),
      ),
    );
  }
}

class _Genre {
  final String id, label, emoji;
  const _Genre({required this.id, required this.label, required this.emoji});
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
