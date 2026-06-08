import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/audio_player_service.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});
  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _opacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Consumer<AudioPlayerService>(
      builder: (context, service, _) {
        final queue = service.queue;
        final currentIndex = service.currentIndex;
        final upNext = currentIndex >= 0 && currentIndex < queue.length - 1
            ? queue.sublist(currentIndex + 1)
            : <FeevoTrack>[];

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),
            Positioned(
                top: -100,
                right: -60,
                child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          AppColors.purple.withOpacity(0.14),
                          AppColors.purple.withOpacity(0)
                        ])))),
            SafeArea(
              child: SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _opacity,
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
                                    border:
                                        Border.all(color: AppColors.border)),
                                child: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.textSecond,
                                    size: 22))),
                        const Spacer(),
                        Text(l.queue.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecond,
                                letterSpacing: 2)),
                        const Spacer(),
                        Image.asset(AppConstants.cat7,
                            width: 38, height: 38, fit: BoxFit.contain),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        children: [
                          Text(l.nowPlaying.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.cyan2,
                                  letterSpacing: 2)),
                          const SizedBox(height: 8),
                          if (currentIndex >= 0 && currentIndex < queue.length)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    AppColors.purple.withOpacity(0.2),
                                    AppColors.cyan.withOpacity(0.1)
                                  ]),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.border2)),
                              child: Row(children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child:
                                        queue[currentIndex].artworkUrl != null
                                            ? Image.network(
                                                queue[currentIndex].artworkUrl!,
                                                width: 46,
                                                height: 46,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _artFallback())
                                            : _artFallback()),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(queue[currentIndex].title,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary),
                                          overflow: TextOverflow.ellipsis),
                                      Text(queue[currentIndex].artist,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecond)),
                                    ])),
                                _WaveIndicator(),
                              ]),
                            )
                          else
                            Text(l.noLikedSongs,
                                style: const TextStyle(
                                    color: AppColors.textSecond)),
                          const SizedBox(height: 20),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('UP NEXT',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textThird,
                                        letterSpacing: 2)),
                                GestureDetector(
                                    onTap: () =>
                                        service.clearQueueAfterCurrent(),
                                    child: Text(l.delete,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.error,
                                            fontWeight: FontWeight.w500))),
                              ]),
                          const SizedBox(height: 8),
                          if (upNext.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Column(children: [
                                Image.asset(AppConstants.cat5,
                                    width: 80, height: 80, fit: BoxFit.contain),
                                const SizedBox(height: 12),
                                Text(l.queue,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                const Text('Add songs to keep the music going',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecond)),
                              ]),
                            )
                          else
                            ...upNext.asMap().entries.map((e) {
                              final i = e.key;
                              final track = e.value;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border:
                                        Border.all(color: AppColors.border)),
                                child: Row(children: [
                                  const Icon(Icons.drag_handle_rounded,
                                      color: AppColors.textThird, size: 18),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                      width: 18,
                                      child: Text('${i + 1}',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textThird,
                                              fontWeight: FontWeight.w500))),
                                  const SizedBox(width: 8),
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: track.artworkUrl != null
                                          ? Image.network(track.artworkUrl!,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _artFallback())
                                          : _artFallback()),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(track.title,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary),
                                            overflow: TextOverflow.ellipsis),
                                        Text(track.artist,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textSecond)),
                                      ])),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                      onTap: () => service.removeFromQueue(
                                          currentIndex + 1 + i),
                                      child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                              color: AppColors.errorBg,
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: const Icon(Icons.close_rounded,
                                              color: AppColors.error,
                                              size: 14))),
                                ]),
                              );
                            }),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _artFallback() => Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(colors: [
            AppColors.purple.withOpacity(0.5),
            AppColors.cyan.withOpacity(0.3)
          ])),
      child: const Center(child: Text('🎵', style: TextStyle(fontSize: 18))));
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
      width: 22,
      height: 18,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
              6,
              (i) => AnimatedBuilder(
                  animation: _animations[i],
                  builder: (_, __) => Container(
                      width: 2,
                      height: 18 * _animations[i].value,
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
