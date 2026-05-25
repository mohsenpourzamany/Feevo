import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

enum CatMood {
  superHype, // cat_1 — Splash, Live Room
  hype, // cat_2 — Welcome, Register, Premium
  chill, // cat_3 — Mood Flow OB, Lyrics, Profile
  energetic, // cat_4 — Home, Edit Profile
  sad, // cat_5 — Mood Flow sad, Queue
  thinking, // cat_6 — Memory Map, Search, Create Room
  focused, // cat_7 — Genre Pick, Login, Settings
}

class CatMascot extends StatefulWidget {
  final CatMood mood;
  final double size;
  final bool animate;
  final double shadowOpacity;

  const CatMascot({
    super.key,
    required this.mood,
    this.size = 120,
    this.animate = true,
    this.shadowOpacity = 0.5,
  });

  @override
  State<CatMascot> createState() => _CatMascotState();
}

class _CatMascotState extends State<CatMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _getDuration(),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Duration _getDuration() {
    switch (widget.mood) {
      case CatMood.superHype:
      case CatMood.energetic:
        return const Duration(milliseconds: 1800);
      case CatMood.hype:
        return const Duration(milliseconds: 2000);
      case CatMood.chill:
      case CatMood.sad:
        return const Duration(milliseconds: 4000);
      case CatMood.thinking:
      case CatMood.focused:
        return const Duration(milliseconds: 3500);
    }
  }

  String get _assetPath {
    switch (widget.mood) {
      case CatMood.superHype:
        return AppConstants.cat1;
      case CatMood.hype:
        return AppConstants.cat2;
      case CatMood.chill:
        return AppConstants.cat3;
      case CatMood.energetic:
        return AppConstants.cat4;
      case CatMood.sad:
        return AppConstants.cat5;
      case CatMood.thinking:
        return AppConstants.cat6;
      case CatMood.focused:
        return AppConstants.cat7;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      _assetPath,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
    );

    if (!widget.animate) return image;

    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(0xFF7C3AED).withOpacity(widget.shadowOpacity),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: image,
    );
  }
}
