import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/bottom_nav_widget.dart';
import '../../core/providers/mood_provider.dart';
import '../../core/services/deezer_service.dart';
import '../../core/services/audio_player_service.dart';

class MoodFlowScreen extends StatefulWidget {
  const MoodFlowScreen({super.key});
  @override
  State<MoodFlowScreen> createState() => _MoodFlowScreenState();
}

class _MoodFlowScreenState extends State<MoodFlowScreen>
    with TickerProviderStateMixin {
  String? _selectedMood;
  bool _isGenerated = false;
  final _textCtrl = TextEditingController();
  bool _showTextInput = false;

  late AnimationController _catController,
      _floatController,
      _contentController,
      _pulseController;
  late Animation<double> _catScale,
      _catOpacity,
      _catFloat,
      _contentOpacity,
      _pulse;
  late Animation<Offset> _contentSlide;

  final List<Map<String, dynamic>> _moods = [
    {
      'id': 'energetic',
      'label': 'Energetic',
      'emoji': '⚡',
      'cat': AppConstants.cat4,
      'color': const Color(0xFF7C3AED)
    },
    {
      'id': 'chill',
      'label': 'Chill',
      'emoji': '🌙',
      'cat': AppConstants.cat3,
      'color': const Color(0xFF0891B2)
    },
    {
      'id': 'focused',
      'label': 'Focused',
      'emoji': '💭',
      'cat': AppConstants.cat7,
      'color': const Color(0xFF4C1D95)
    },
    {
      'id': 'melancholic',
      'label': 'Melancholic',
      'emoji': '🌧',
      'cat': AppConstants.cat5,
      'color': const Color(0xFF1E3A5F)
    },
    {
      'id': 'hype',
      'label': 'Hype',
      'emoji': '🔥',
      'cat': AppConstants.cat2,
      'color': const Color(0xFFBE185D)
    },
    {
      'id': 'happy',
      'label': 'Happy',
      'emoji': '💗',
      'cat': AppConstants.cat1,
      'color': const Color(0xFF065F46)
    },
  ];

  @override
  void initState() {
    super.initState();
    _catController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _catScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _catController, curve: Curves.elasticOut));
    _catOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _catController, curve: Curves.easeIn));
    _floatController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);
    _catFloat = Tween<double>(begin: 0, end: -10).animate(
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _contentController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _contentController, curve: Curves.easeOutCubic));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _catController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _catController.dispose();
    _floatController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String get _currentCatAsset {
    if (_selectedMood == null) return AppConstants.cat3;
    return _moods.firstWhere((m) => m['id'] == _selectedMood)['cat'] as String;
  }

  String _moodLabel(AppLocalizations l) {
    if (_selectedMood == null) return l.whatAreWeFeeling;
    final mood = _moods.firstWhere((m) => m['id'] == _selectedMood);
    return '${mood['emoji']} ${mood['label']}';
  }

  Color get _moodColor {
    if (_selectedMood == null) return AppColors.purple;
    return _moods.firstWhere((m) => m['id'] == _selectedMood)['color'] as Color;
  }

  void _selectMood(String id) {
    setState(() {
      _selectedMood = id;
      _isGenerated = false;
    });
    _catController.reset();
    _catController.forward();
    context.read<MoodProvider>().clear();
  }

  Future<void> _generate() async {
    final mood = context.read<MoodProvider>();
    if (_showTextInput && _textCtrl.text.trim().isNotEmpty) {
      await mood.analyzeMoodAndGenerate(_textCtrl.text.trim());
    } else if (_selectedMood != null) {
      await mood.generateFromMood(_selectedMood!);
    } else
      return;
    if (mounted) setState(() => _isGenerated = true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Positioned(
            top: -120,
            right: -60,
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      _moodColor.withOpacity(0.15),
                      _moodColor.withOpacity(0)
                    ])))),
        Positioned(
            bottom: -60,
            left: -60,
            child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.purple.withOpacity(0.1),
                      AppColors.purple.withOpacity(0)
                    ])))),
        SafeArea(
          child: Column(children: [
            Expanded(
              child: SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentOpacity,
                  child: Consumer<MoodProvider>(
                    builder: (context, moodProvider, _) {
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.primaryGradient.createShader(bounds),
                            child: Text('${l.moodFlow} 🌊',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3)),
                          ),
                          const SizedBox(height: 16),
                          AnimatedBuilder(
                            animation: Listenable.merge(
                                [_catController, _floatController]),
                            builder: (_, __) => Opacity(
                              opacity: _catOpacity.value,
                              child: Transform.scale(
                                  scale: _catScale.value,
                                  child: Transform.translate(
                                    offset: Offset(0, _catFloat.value),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                _moodColor.withOpacity(0.18),
                                                AppColors.cyan.withOpacity(0.08)
                                              ]),
                                          borderRadius:
                                              BorderRadius.circular(22),
                                          border: Border.all(
                                              color: _moodColor
                                                  .withOpacity(0.35))),
                                      child: Row(children: [
                                        Image.asset(_currentCatAsset,
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.contain),
                                        const SizedBox(width: 14),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              Text(
                                                  moodProvider.moodResult !=
                                                          null
                                                      ? 'AI detected:'
                                                      : (_selectedMood == null
                                                          ? l.mood
                                                          : 'Feeling...'),
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors.purple3,
                                                      letterSpacing: 1)),
                                              const SizedBox(height: 4),
                                              Text(
                                                  moodProvider.moodResult
                                                          ?.message ??
                                                      _moodLabel(l),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors
                                                          .textPrimary)),
                                              const SizedBox(height: 8),
                                              GestureDetector(
                                                onTap: () => setState(() =>
                                                    _showTextInput =
                                                        !_showTextInput),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                      gradient: AppColors
                                                          .primaryGradient,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              999)),
                                                  child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                            _showTextInput
                                                                ? Icons
                                                                    .keyboard_rounded
                                                                : Icons
                                                                    .edit_rounded,
                                                            color: Colors.white,
                                                            size: 14),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                            _showTextInput
                                                                ? 'Pick a mood'
                                                                : 'Describe your mood',
                                                            style: const TextStyle(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .white)),
                                                      ]),
                                                ),
                                              ),
                                            ])),
                                      ]),
                                    ),
                                  )),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_showTextInput) ...[
                            Container(
                              decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppColors.purple.withOpacity(0.4),
                                      width: 1.5)),
                              child: TextField(
                                controller: _textCtrl,
                                maxLines: 3,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                    fontSize: 13, color: AppColors.textPrimary),
                                decoration: const InputDecoration(
                                    hintText: 'Tell me how you feel...',
                                    hintStyle: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textThird),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(14)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                                'Claude AI will analyze your mood and find the perfect tracks 🤖',
                                style: TextStyle(
                                    fontSize: 10, color: AppColors.textThird)),
                            const SizedBox(height: 16),
                          ],
                          if (!_showTextInput) ...[
                            Text('Or pick a mood:',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _moods.map((mood) {
                                final active = _selectedMood == mood['id'];
                                return GestureDetector(
                                  onTap: () =>
                                      _selectMood(mood['id'] as String),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 9),
                                    decoration: BoxDecoration(
                                      gradient: active
                                          ? LinearGradient(colors: [
                                              (mood['color'] as Color)
                                                  .withOpacity(0.3),
                                              AppColors.cyan.withOpacity(0.1)
                                            ])
                                          : null,
                                      color: active ? null : AppColors.surface,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                          color: active
                                              ? (mood['color'] as Color)
                                                  .withOpacity(0.6)
                                              : AppColors.border,
                                          width: active ? 1.5 : 1),
                                      boxShadow: active
                                          ? [
                                              BoxShadow(
                                                  color:
                                                      (mood['color'] as Color)
                                                          .withOpacity(0.2),
                                                  blurRadius: 10)
                                            ]
                                          : [],
                                    ),
                                    child: Text(
                                        '${mood['emoji']} ${mood['label']}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: active
                                                ? AppColors.textPrimary
                                                : AppColors.textSecond)),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                          ],
                          if (moodProvider.error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.red.withOpacity(0.3))),
                                  child: Text(moodProvider.error!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.redAccent))),
                            ),
                          if (!_isGenerated &&
                              (_selectedMood != null ||
                                  (_showTextInput &&
                                      _textCtrl.text.isNotEmpty)))
                            GestureDetector(
                              onTap: moodProvider.isLoading ? null : _generate,
                              child: AnimatedBuilder(
                                animation: _pulse,
                                builder: (_, child) => Transform.scale(
                                    scale: moodProvider.isLoading
                                        ? _pulse.value
                                        : 1.0,
                                    child: child),
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        _moodColor,
                                        AppColors.purple
                                      ]),
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: [
                                        BoxShadow(
                                            color: _moodColor.withOpacity(0.4),
                                            blurRadius: 20,
                                            offset: const Offset(0, 6))
                                      ]),
                                  child: Center(
                                      child: moodProvider.isLoading
                                          ? const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                  SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child:
                                                          CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                              strokeWidth: 2)),
                                                  SizedBox(width: 10),
                                                  Text(
                                                      'AI is building your flow...',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.white))
                                                ])
                                          : const Text('✨ Generate My Flow',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white))),
                                ),
                              ),
                            ),
                          if (_isGenerated &&
                              moodProvider.tracks.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildPlaylist(moodProvider.tracks),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const FeevoBottomNav(currentIndex: 2),
          ]),
        ),
      ]),
    );
  }

  Widget _buildPlaylist(List<DeezerTrack> tracks) {
    final mood = _selectedMood != null
        ? _moods.firstWhere((m) => m['id'] == _selectedMood)
        : _moods[0];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Image.asset(mood['cat'] as String,
            width: 24, height: 24, fit: BoxFit.contain),
        const SizedBox(width: 8),
        Text('${mood['emoji']} Your ${mood['label']} Flow',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ]),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border)),
        child: Column(
            children: List.generate(tracks.length, (i) {
          final track = tracks[i];
          final isFirst = i == 0;
          return GestureDetector(
            onTap: () {
              final feevoTracks = tracks
                  .map((dt) => FeevoTrack(
                      id: dt.id,
                      title: dt.title,
                      artist: dt.artist,
                      album: dt.album,
                      emoji: '🎵',
                      url: dt.previewUrl ?? '',
                      artworkUrl: dt.albumArt))
                  .toList();
              context
                  .read<AudioPlayerService>()
                  .playQueue(feevoTracks, startIndex: i);
              context.push(AppRoutes.nowPlaying);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: isFirst
                    ? LinearGradient(colors: [
                        _moodColor.withOpacity(0.15),
                        AppColors.cyan.withOpacity(0.06)
                      ])
                    : null,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isFirst ? 18 : 0),
                    topRight: Radius.circular(isFirst ? 18 : 0),
                    bottomLeft:
                        Radius.circular(i == tracks.length - 1 ? 18 : 0),
                    bottomRight:
                        Radius.circular(i == tracks.length - 1 ? 18 : 0)),
                border: i < tracks.length - 1
                    ? const Border(bottom: BorderSide(color: AppColors.border))
                    : null,
              ),
              child: Row(children: [
                Text('${i + 1}',
                    style: TextStyle(
                        fontSize: 11,
                        color: isFirst ? AppColors.cyan2 : AppColors.textThird,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: track.albumArt != null
                        ? Image.network(track.albumArt!,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                  _moodColor.withOpacity(0.6),
                                  AppColors.purple.withOpacity(0.4)
                                ])),
                                child: const Center(
                                    child: Text('🎵',
                                        style: TextStyle(fontSize: 16)))))
                        : Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                              _moodColor.withOpacity(0.6),
                              AppColors.purple.withOpacity(0.4)
                            ])),
                            child: const Center(
                                child: Text('🎵', style: TextStyle(fontSize: 16))))),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(track.title,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis),
                      Text(track.artist,
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textSecond)),
                    ])),
                if (isFirst)
                  _WaveIndicator()
                else
                  Text(track.durationFormatted,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textThird)),
              ]),
            ),
          );
        })),
      ),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => setState(() {
          _isGenerated = false;
          context.read<MoodProvider>().clear();
        }),
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border2)),
            child: const Center(
                child: Text('↺ Regenerate Flow',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.purple3)))),
      ),
    ]);
  }
}

class _WaveIndicator extends StatefulWidget {
  @override
  State<_WaveIndicator> createState() => _WaveIndicatorState();
}

class _WaveIndicatorState extends State<_WaveIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
        6,
        (i) => AnimationController(
            vsync: this, duration: Duration(milliseconds: 500 + i * 80))
          ..repeat(reverse: true));
    _animations = _controllers
        .map((c) => Tween<double>(begin: 0.2, end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
      width: 24,
      height: 20,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
              6,
              (i) => AnimatedBuilder(
                  animation: _animations[i],
                  builder: (_, __) => Container(
                      width: 2,
                      height: 20 * _animations[i].value,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: AppColors.primaryGradient))))));
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
