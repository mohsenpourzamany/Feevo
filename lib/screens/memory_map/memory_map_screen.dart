import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/bottom_nav_widget.dart';
import '../../core/providers/memory_provider.dart';
import '../../core/services/audio_player_service.dart';

class MemoryMapScreen extends StatefulWidget {
  const MemoryMapScreen({super.key});
  @override
  State<MemoryMapScreen> createState() => _MemoryMapScreenState();
}

class _MemoryMapScreenState extends State<MemoryMapScreen>
    with TickerProviderStateMixin {
  String _selectedFilter = 'all';

  late AnimationController _catController, _floatController, _contentController;
  late Animation<double> _catScale, _catOpacity, _catFloat, _contentOpacity;
  late Animation<Offset> _contentSlide;

  final List<Map<String, String>> _filters = [
    {'id': 'all', 'label': 'All'},
    {'id': 'melancholic', 'label': '🌧 Sad'},
    {'id': 'energetic', 'label': '⚡ Energy'},
    {'id': 'chill', 'label': '🌙 Chill'},
    {'id': 'happy', 'label': '💗 Happy'},
    {'id': 'focused', 'label': '💭 Focus'},
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
        vsync: this, duration: const Duration(milliseconds: 3500))
      ..repeat(reverse: true);
    _catFloat = Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _contentController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _contentController, curve: Curves.easeOutCubic));
    _catController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _contentController.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemoryProvider>().fetchMemories();
    });
  }

  @override
  void dispose() {
    _catController.dispose();
    _floatController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(
              top: -120,
              right: -80,
              child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        AppColors.cyan.withOpacity(0.12),
                        AppColors.cyan.withOpacity(0)
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
                        AppColors.purple.withOpacity(0.12),
                        AppColors.purple.withOpacity(0)
                      ])))),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: Consumer<MemoryProvider>(
                        builder: (context, mp, _) {
                          final filtered = _selectedFilter == 'all'
                              ? mp.memories
                              : mp.memories
                                  .where((m) => m.mood == _selectedFilter)
                                  .toList();

                          return ListView(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            children: [
                              // header
                              Row(children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      ShaderMask(
                                          shaderCallback: (b) => AppColors
                                              .primaryGradient
                                              .createShader(b),
                                          child: Text('${l.memoryMap} 🗺️',
                                              style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                  letterSpacing: -0.3))),
                                      const SizedBox(height: 3),
                                      Text(l.memory,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecond)),
                                    ])),
                                AnimatedBuilder(
                                  animation: Listenable.merge(
                                      [_catController, _floatController]),
                                  builder: (_, __) => Opacity(
                                      opacity: _catOpacity.value,
                                      child: Transform.scale(
                                          scale: _catScale.value,
                                          child: Transform.translate(
                                              offset:
                                                  Offset(0, _catFloat.value),
                                              child: Image.asset(
                                                  AppConstants.cat6,
                                                  width: 70,
                                                  height: 70,
                                                  fit: BoxFit.contain)))),
                                ),
                              ]),

                              const SizedBox(height: 16),

                              // AI insight card
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.purple.withOpacity(0.18),
                                          AppColors.cyan.withOpacity(0.08)
                                        ]),
                                    borderRadius: BorderRadius.circular(18),
                                    border:
                                        Border.all(color: AppColors.border2)),
                                child: Row(children: [
                                  Image.asset(AppConstants.cat6,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.contain),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        const Text('🤖 AI Insight',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.cyan2,
                                                letterSpacing: 1)),
                                        const SizedBox(height: 4),
                                        mp.isLoadingInsight
                                            ? const Text(
                                                'Analyzing your music habits...',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        AppColors.textSecond))
                                            : Text(
                                                mp.aiInsight ??
                                                    (mp.memories.isEmpty
                                                        ? 'Start listening to build your memory map!'
                                                        : 'Analyzing your music habits...'),
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.textSecond,
                                                    height: 1.6)),
                                      ])),
                                ]),
                              ),

                              const SizedBox(height: 16),

                              // stats
                              Row(children: [
                                _StatCard(
                                    value: '${mp.memories.length}',
                                    label: l.memories,
                                    emoji: '💾'),
                                const SizedBox(width: 10),
                                _StatCard(
                                    value: '${mp.totalPlays}',
                                    label: l.totalPlays,
                                    emoji: '▶️'),
                                const SizedBox(width: 10),
                                _StatCard(
                                    value: '${mp.moods.length}',
                                    label: l.moods,
                                    emoji: '🎭'),
                              ]),

                              const SizedBox(height: 16),

                              // filters
                              SizedBox(
                                height: 34,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _filters.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, i) {
                                    final filter = _filters[i];
                                    final active =
                                        _selectedFilter == filter['id'];
                                    return GestureDetector(
                                      onTap: () => setState(() =>
                                          _selectedFilter = filter['id']!),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14),
                                        decoration: BoxDecoration(
                                            gradient: active
                                                ? LinearGradient(colors: [
                                                    AppColors.purple
                                                        .withOpacity(0.3),
                                                    AppColors.cyan
                                                        .withOpacity(0.15)
                                                  ])
                                                : null,
                                            color: active
                                                ? null
                                                : AppColors.surface,
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            border: Border.all(
                                                color: active
                                                    ? AppColors.purple2
                                                    : AppColors.border,
                                                width: active ? 1.5 : 1)),
                                        child: Center(
                                            child: Text(filter['label']!,
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: active
                                                        ? AppColors.purple3
                                                        : AppColors
                                                            .textSecond))),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 14),

                              // loading / empty / list
                              if (mp.isLoading)
                                const Center(
                                    child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 40),
                                        child: CircularProgressIndicator(
                                            color: AppColors.purple,
                                            strokeWidth: 2)))
                              else if (mp.memories.isEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                      child: Column(children: [
                                    Image.asset(AppConstants.cat6,
                                        width: 80, height: 80),
                                    const SizedBox(height: 12),
                                    Text(l.noMemories,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary)),
                                    const SizedBox(height: 4),
                                    const Text(
                                        'Play songs to build your memory map!',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecond),
                                        textAlign: TextAlign.center),
                                  ])),
                                )
                              else if (filtered.isEmpty)
                                const Center(
                                    child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 40),
                                        child: Text(
                                            'No memories with this mood',
                                            style: TextStyle(
                                                color: AppColors.textSecond))))
                              else
                                ...filtered.map((memory) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: GestureDetector(
                                        onTap: () => context.push(
                                            '${AppRoutes.memoryDetail}?id=${memory.id}'),
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  AppColors.purple
                                                      .withOpacity(0.12),
                                                  AppColors.purple
                                                      .withOpacity(0.06)
                                                ]),
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            border: Border.all(
                                                color: AppColors.border2),
                                          ),
                                          child: Column(children: [
                                            Row(children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                child: memory.albumArt != null
                                                    ? Image.network(
                                                        memory.albumArt!,
                                                        width: 52,
                                                        height: 52,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __,
                                                                ___) =>
                                                            _artFallback(memory
                                                                .moodEmoji))
                                                    : _artFallback(
                                                        memory.moodEmoji),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                    Text(memory.title,
                                                        style: const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: AppColors
                                                                .textPrimary),
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                    const SizedBox(height: 2),
                                                    Text(memory.artist,
                                                        style: const TextStyle(
                                                            fontSize: 11,
                                                            color: AppColors
                                                                .textSecond)),
                                                  ])),
                                              Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text('${memory.plays}',
                                                        style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            color: AppColors
                                                                .purple3)),
                                                    Text(l.plays,
                                                        style: const TextStyle(
                                                            fontSize: 9,
                                                            color: AppColors
                                                                .textThird)),
                                                  ]),
                                            ]),
                                            const SizedBox(height: 10),
                                            Row(children: [
                                              Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3),
                                                  decoration: BoxDecoration(
                                                      color: AppColors.purple
                                                          .withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              999),
                                                      border: Border.all(
                                                          color: AppColors
                                                              .purple
                                                              .withOpacity(
                                                                  0.3))),
                                                  child: Text(
                                                      '${memory.moodEmoji} ${memory.mood}',
                                                      style: const TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppColors.purple3))),
                                              const SizedBox(width: 8),
                                              const Icon(
                                                  Icons.calendar_today_outlined,
                                                  color: AppColors.textThird,
                                                  size: 11),
                                              const SizedBox(width: 3),
                                              Text(
                                                  _formatDate(memory.createdAt),
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          AppColors.textThird)),
                                              const Spacer(),
                                              GestureDetector(
                                                onTap: () => _confirmDelete(
                                                    context,
                                                    mp,
                                                    memory.id,
                                                    memory.title),
                                                child: const Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    color: AppColors.textThird,
                                                    size: 16),
                                              ),
                                            ]),
                                            if (memory.note != null) ...[
                                              const SizedBox(height: 8),
                                              Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 7),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Row(children: [
                                                    const Text('📝',
                                                        style: TextStyle(
                                                            fontSize: 12)),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                        child: Text(
                                                            memory.note!,
                                                            style: const TextStyle(
                                                                fontSize: 10,
                                                                color: AppColors
                                                                    .textSecond,
                                                                height: 1.5))),
                                                  ])),
                                            ],
                                          ]),
                                        ),
                                      ),
                                    )),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const FeevoBottomNav(currentIndex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _artFallback(String emoji) => Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: AppColors.primaryGradient),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))));

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${dt.day}/${dt.month}';
  }

  void _confirmDelete(
      BuildContext context, MemoryProvider mp, String id, String title) {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
            color: Color(0xFF0F0F22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999))),
          const SizedBox(height: 16),
          Text('"$title"',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Delete this memory?',
              style: TextStyle(fontSize: 13, color: AppColors.textSecond)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border)),
                        child: Center(
                            child: Text(l.cancel,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecond)))))),
            const SizedBox(width: 10),
            Expanded(
                child: GestureDetector(
                    onTap: () async {
                      await mp.deleteMemory(id);
                      if (mounted) Navigator.pop(context);
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.3))),
                        child: Center(
                            child: Text(l.delete,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.error)))))),
          ]),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label, emoji;
  const _StatCard(
      {required this.value, required this.label, required this.emoji});
  @override
  Widget build(BuildContext context) => Expanded(
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.purple.withOpacity(0.15),
                    AppColors.cyan.withOpacity(0.07)
                  ]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border2)),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            Text(label,
                style: const TextStyle(fontSize: 9, color: AppColors.textThird))
          ])));
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
