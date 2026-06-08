import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/audio_player_service.dart';

class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});
  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen>
    with TickerProviderStateMixin {
  List<String> _lines = [];
  bool _isLoading = true;
  String? _error;
  int _currentLine = 0;
  final ScrollController _scrollCtrl = ScrollController();

  late AnimationController _catController, _floatController, _contentController;
  late Animation<double> _catScale, _catOpacity, _catFloat, _contentOpacity;

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
    _catFloat = Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _contentController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    _catController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _contentController.forward();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLyrics());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _catController.dispose();
    _floatController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadLyrics() async {
    final track = context.read<AudioPlayerService>().currentTrack;
    if (track == null) {
      setState(() {
        _isLoading = false;
        _error = 'No track playing';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final artist = Uri.encodeComponent(track.artist);
      final title = Uri.encodeComponent(track.title);
      final response = await http
          .get(Uri.parse('https://api.lyrics.ovh/v1/$artist/$title'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final raw = data['lyrics'] as String? ?? '';
        final lines =
            raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
        setState(() {
          _lines = lines;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Lyrics not found for this track';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Could not load lyrics';
      });
    }
  }

  void _scrollToLine(int index) {
    if (!_scrollCtrl.hasClients) return;
    const itemHeight = 52.0;
    final offset =
        (index * itemHeight) - (MediaQuery.of(context).size.height * 0.3);
    _scrollCtrl.animateTo(
        offset.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final track = context.watch<AudioPlayerService>().currentTrack;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        Positioned.fill(
            child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF0D0520), Color(0xFF06060F)])))),
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Positioned(
            top: -120,
            left: -80,
            child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.purple.withOpacity(0.18),
                      AppColors.purple.withOpacity(0)
                    ])))),
        SafeArea(
          child: FadeTransition(
            opacity: _contentOpacity,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(children: [
                  GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border)),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textSecond, size: 22))),
                  const Spacer(),
                  Text(l.lyrics.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecond,
                          letterSpacing: 2)),
                  const Spacer(),
                  AnimatedBuilder(
                    animation:
                        Listenable.merge([_catController, _floatController]),
                    builder: (_, __) => Opacity(
                        opacity: _catOpacity.value,
                        child: Transform.scale(
                            scale: _catScale.value,
                            child: Transform.translate(
                                offset: Offset(0, _catFloat.value),
                                child: Image.asset(AppConstants.cat3,
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.contain)))),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: track?.artworkUrl != null
                          ? Image.network(track!.artworkUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _artFallback())
                          : _artFallback()),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(track?.title ?? 'No track',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary),
                            overflow: TextOverflow.ellipsis),
                        Text(track?.artist ?? '',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecond)),
                      ])),
                  if (!_isLoading && _error == null)
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(999)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.lyrics_outlined,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          const Text('Found',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white))
                        ])),
                ]),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildContent(l)),
              Consumer<AudioPlayerService>(
                builder: (context, service, _) => Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CtrlBtn(
                            icon: Icons.skip_previous_rounded,
                            onTap: () => service.playPrevious()),
                        GestureDetector(
                            onTap: () => service.togglePlay(),
                            child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.primaryGradient,
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              AppColors.purple.withOpacity(0.5),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6))
                                    ]),
                                child: Icon(
                                    service.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 28))),
                        _CtrlBtn(
                            icon: Icons.skip_next_rounded,
                            onTap: () => service.playNext()),
                      ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildContent(AppLocalizations l) {
    if (_isLoading)
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(
            color: AppColors.purple, strokeWidth: 2),
        const SizedBox(height: 16),
        Text(l.searching,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecond))
      ]));
    if (_error != null)
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Image.asset(AppConstants.cat5, width: 80, height: 80),
        const SizedBox(height: 12),
        Text(l.lyricsNotFound,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('Try searching for another track',
            style: TextStyle(fontSize: 11, color: AppColors.textSecond)),
        const SizedBox(height: 16),
        GestureDetector(
            onTap: _loadLyrics,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(999)),
                child: Text(l.retry,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)))),
      ]));

    return Column(children: [
      Container(
          height: 20,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                const Color(0xFF0D0520),
                const Color(0xFF0D0520).withOpacity(0)
              ]))),
      Expanded(
          child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _lines.length,
        itemBuilder: (context, i) {
          final isCurrent = i == _currentLine;
          final isPast = i < _currentLine;
          return GestureDetector(
            onTap: () {
              setState(() => _currentLine = i);
              _scrollToLine(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                  vertical: isCurrent ? 14 : 10, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                  gradient: isCurrent
                      ? LinearGradient(colors: [
                          AppColors.purple.withOpacity(0.15),
                          AppColors.cyan.withOpacity(0.06)
                        ])
                      : null,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                if (isCurrent) ...[
                  Container(
                      width: 3,
                      height: 28,
                      decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(999))),
                  const SizedBox(width: 10)
                ],
                Expanded(
                    child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                      fontSize: isCurrent ? 18 : 14,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                      color: isCurrent
                          ? AppColors.textPrimary
                          : isPast
                              ? AppColors.textThird
                              : AppColors.textSecond,
                      height: 1.5),
                  child: Text(_lines[i]),
                )),
              ]),
            ),
          );
        },
      )),
      Container(
          height: 20,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.bg, AppColors.bg.withOpacity(0)]))),
    ]);
  }

  Widget _artFallback() => Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: AppColors.primaryGradient),
      child: const Center(child: Text('🎵', style: TextStyle(fontSize: 22))));
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CtrlBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.border)),
          child: Icon(icon, color: AppColors.textSecond, size: 22)));
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
