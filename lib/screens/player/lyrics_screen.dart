import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen>
    with TickerProviderStateMixin {

  int _currentLine = 3;
  final ScrollController _scrollCtrl = ScrollController();

  late AnimationController _catController;
  late AnimationController _floatController;
  late AnimationController _contentController;

  late Animation<double> _catScale;
  late Animation<double> _catOpacity;
  late Animation<double> _catFloat;
  late Animation<double> _contentOpacity;

  final List<Map<String, dynamic>> _lyrics = [
    {'line': 'Waiting for the morning to come',          'time': 0},
    {'line': 'Waiting for the feeling to come back',     'time': 8},
    {'line': 'Waiting for the magic to come alive',      'time': 16},
    {'line': 'Midnight City shines so bright',           'time': 24},
    {'line': 'Oh, oh, oh, oh...',                        'time': 32},
    {'line': 'She\'s got a voice that\'s calling',       'time': 40},
    {'line': 'She\'s a diamond in the rain',             'time': 48},
    {'line': 'We\'re running through the midnight city', 'time': 56},
    {'line': 'We\'re dancing in the neon light',         'time': 64},
    {'line': 'Oh, the city never sleeps',                'time': 72},
    {'line': 'And we\'re alive tonight',                 'time': 80},
    {'line': 'Midnight City, hold me tight',             'time': 88},
    {'line': 'Oh, oh, oh, oh...',                        'time': 96},
    {'line': 'The streets are filled with wonder',       'time': 104},
    {'line': 'The night is full of light',               'time': 112},
    {'line': 'And we\'re running through the city',      'time': 120},
    {'line': 'Everything feels right tonight',           'time': 128},
    {'line': 'Oh, oh, oh, oh...',                        'time': 136},
    {'line': 'Midnight City...',                         'time': 144},
    {'line': '♪ ♪ ♪',                                   'time': 152},
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
      duration: const Duration(milliseconds: 600),
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
  }

  void _playEntrance() {
    _catController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _catController.dispose();
    _floatController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // gradient bg
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                  colors: [Color(0xFF0D0520), Color(0xFF06060F)],
                ),
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(
            top: -120, left: -80,
            child: Container(
              width: 380, height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.purple.withOpacity(0.18),
                  AppColors.purple.withOpacity(0),
                ]),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _contentOpacity,
              child: Column(
                children: [

                  // header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
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
                            child: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textSecond, size: 22),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'LYRICS',
                          style: TextStyle(
                            fontSize:      10,
                            fontWeight:    FontWeight.w600,
                            color:         AppColors.textSecond,
                            letterSpacing: 2,
                          ),
                        ),
                        const Spacer(),
                        // cat_3 chill listening
                        AnimatedBuilder(
                          animation: Listenable.merge([_catController, _floatController]),
                          builder: (_, __) => Opacity(
                            opacity: _catOpacity.value,
                            child: Transform.scale(
                              scale: _catScale.value,
                              child: Transform.translate(
                                offset: Offset(0, _catFloat.value),
                                child: Image.asset(
                                  AppConstants.cat3,
                                  width:  38,
                                  height: 38,
                                  fit:    BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // track info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color:      AppColors.purple.withOpacity(0.4),
                                blurRadius: 12,
                                offset:     const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🎵', style: TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Midnight City',
                                style: TextStyle(
                                  fontSize:   15,
                                  fontWeight: FontWeight.w700,
                                  color:      AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'M83 · Electronic',
                                style: TextStyle(
                                  fontSize: 11,
                                  color:    AppColors.textSecond,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // sync badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sync_rounded,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Synced',
                                style: TextStyle(
                                  fontSize:   10,
                                  fontWeight: FontWeight.w600,
                                  color:      Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // top fade
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end:   Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0D0520),
                          const Color(0xFF0D0520).withOpacity(0),
                        ],
                      ),
                    ),
                  ),

                  // lyrics list
                  Expanded(
                    child: ListView.builder(
                      controller:  _scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 0),
                      itemCount:   _lyrics.length,
                      itemBuilder: (context, i) {
                        final isCurrent = i == _currentLine;
                        final isPast    = i < _currentLine;

                        return GestureDetector(
                          onTap: () => setState(() => _currentLine = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.symmetric(
                              vertical: isCurrent ? 14 : 10,
                              horizontal: 12,
                            ),
                            margin: const EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              gradient: isCurrent
                                  ? LinearGradient(colors: [
                                      AppColors.purple.withOpacity(0.15),
                                      AppColors.cyan.withOpacity(0.06),
                                    ])
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                if (isCurrent) ...[
                                  Container(
                                    width:  3,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      gradient:     AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                Expanded(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    style: TextStyle(
                                      fontSize:   isCurrent ? 18 : 14,
                                      fontWeight: isCurrent
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isCurrent
                                          ? AppColors.textPrimary
                                          : isPast
                                              ? AppColors.textThird
                                              : AppColors.textSecond,
                                      height: 1.5,
                                    ),
                                    child: Text(_lyrics[i]['line'] as String),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // bottom fade
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end:   Alignment.topCenter,
                        colors: [
                          AppColors.bg,
                          AppColors.bg.withOpacity(0),
                        ],
                      ),
                    ),
                  ),

                  // prev / play / next
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() {
                            if (_currentLine > 0) _currentLine--;
                          }),
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(Icons.skip_previous_rounded,
                                color: AppColors.textSecond, size: 22),
                          ),
                        ),
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            shape:    BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color:      AppColors.purple.withOpacity(0.5),
                                blurRadius: 20,
                                offset:     const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.pause_rounded,
                              color: Colors.white, size: 28),
                        ),
                        GestureDetector(
                          onTap: () => setState(() {
                            if (_currentLine < _lyrics.length - 1) _currentLine++;
                          }),
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(Icons.skip_next_rounded,
                                color: AppColors.textSecond, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
