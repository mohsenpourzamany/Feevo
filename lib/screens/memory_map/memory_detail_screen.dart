import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/providers/memory_provider.dart';
import '../../core/services/audio_player_service.dart';

class MemoryDetailScreen extends StatefulWidget {
  final String memoryId;
  const MemoryDetailScreen({super.key, required this.memoryId});

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> with TickerProviderStateMixin {
  late AnimationController _contentController, _catController, _floatController;
  late Animation<double> _contentOpacity, _catScale, _catFloat;
  late Animation<Offset>  _contentSlide;

  Memory? _memory;

  @override
  void initState() {
    super.initState();
    _catController     = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _catScale          = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _catController, curve: Curves.elasticOut));
    _floatController   = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat(reverse: true);
    _catFloat          = Tween<double>(begin: 0, end: -8).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _contentController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _contentOpacity    = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    _contentSlide      = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));
    _catController.forward();
    Future.delayed(const Duration(milliseconds: 150), () { if (mounted) _contentController.forward(); });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mp = context.read<MemoryProvider>();
      try {
        _memory = mp.memories.firstWhere((m) => m.id == widget.memoryId);
        setState(() {});
      } catch (_) {
        // not found
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _catController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Positioned(top: -100, right: -60, child: Container(width: 320, height: 320, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.purple.withOpacity(0.15), AppColors.purple.withOpacity(0)])))),

        SafeArea(
          child: SlideTransition(
            position: _contentSlide,
            child: FadeTransition(
              opacity: _contentOpacity,
              child: _memory == null
                  ? const Center(child: CircularProgressIndicator(color: AppColors.purple, strokeWidth: 2))
                  : _buildContent(),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildContent() {
    final m = _memory!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        // header
        Row(children: [
          GestureDetector(onTap: () => context.pop(), child: Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)), child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textSecond, size: 16))),
          const SizedBox(width: 14),
          const Expanded(child: Text('Memory Detail 🗺️', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3))),
        ]),

        const SizedBox(height: 20),

        // hero card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4C1D95), Color(0xFF0891B2)]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: m.albumArt != null
                  ? Image.network(m.albumArt!, width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _artFallback(m.moodEmoji))
                  : _artFallback(m.moodEmoji),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
              const SizedBox(height: 2),
              Text(m.artist, style: const TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 10),
              Row(children: [
                _Badge(label: '${m.plays} plays', emoji: '▶️'),
                const SizedBox(width: 6),
                _Badge(label: m.mood, emoji: m.moodEmoji),
              ]),
            ])),
            AnimatedBuilder(
              animation: Listenable.merge([_catController, _floatController]),
              builder: (_, __) => Transform.scale(scale: _catScale.value, child: Transform.translate(offset: Offset(0, _catFloat.value), child: Image.asset(AppConstants.cat6, width: 52, height: 52, fit: BoxFit.contain))),
            ),
          ]),
        ),

        const SizedBox(height: 16),

        // stats
        Row(children: [
          _StatCard(value: '${m.plays}',    label: 'Total Plays', emoji: '▶️'),
          const SizedBox(width: 10),
          _StatCard(value: m.moodEmoji,     label: 'Mood',        emoji: '🎭'),
          const SizedBox(width: 10),
          _StatCard(value: _formatDate(m.createdAt), label: 'First played', emoji: '📅'),
        ]),

        const SizedBox(height: 16),

        // note
        if (m.note != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.purple.withOpacity(0.12), AppColors.cyan.withOpacity(0.06)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border2)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('📝 Note', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.cyan2, letterSpacing: 1)),
              const SizedBox(height: 8),
              Text(m.note!, style: const TextStyle(fontSize: 12, color: AppColors.textSecond, height: 1.7)),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        // play button
        GestureDetector(
          onTap: () async {
            // دوباره از Deezer URL تازه بگیر
            try {
              final response = await http.get(
                Uri.parse('https://api.deezer.com/track/${m.trackId}'),
              );
              if (response.statusCode == 200) {
                final data       = jsonDecode(response.body);
                final previewUrl = data['preview'] as String? ?? '';
                final albumArt   = data['album']?['cover_medium'] as String?;
                final feevoTrack = FeevoTrack(
                  id:         m.trackId,
                  title:      m.title,
                  artist:     m.artist,
                  album:      data['album']?['title'] ?? '',
                  emoji:      '🎵',
                  url:        previewUrl,
                  artworkUrl: albumArt ?? m.albumArt,
                );
                context.read<AudioPlayerService>().playQueue([feevoTrack]);
                context.push(AppRoutes.nowPlaying);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Could not load track'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ));
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]),
            child: const Center(child: Text('▶ Play This Memory', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
        ),

        const SizedBox(height: 12),

        // delete button
        GestureDetector(
          onTap: () async {
            await context.read<MemoryProvider>().deleteMemory(m.id);
            if (mounted) context.pop();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.error.withOpacity(0.3))),
            child: const Center(child: Text('Delete Memory', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error))),
          ),
        ),
      ],
    );
  }

  Widget _artFallback(String emoji) => Container(width: 80, height: 80, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.black.withOpacity(0.2)), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 38))));

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}

class _Badge extends StatelessWidget {
  final String label, emoji;
  const _Badge({required this.label, required this.emoji});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
    child: Text('$emoji $label', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500)),
  );
}

class _StatCard extends StatelessWidget {
  final String value, label, emoji;
  const _StatCard({required this.value, required this.label, required this.emoji});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.purple.withOpacity(0.12), AppColors.cyan.withOpacity(0.06)]), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border2)),
    child: Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary), textAlign: TextAlign.center),
      Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textThird), textAlign: TextAlign.center),
    ]),
  ));
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.purple.withOpacity(0.04)..strokeWidth = 1;
    const step = 44.0;
    for (double x = 0; x < size.width; x += step) { canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint); }
    for (double y = 0; y < size.height; y += step) { canvas.drawLine(Offset(0, y), Offset(size.width, y), paint); }
  }
  @override bool shouldRepaint(_GridPainter old) => false;
}
