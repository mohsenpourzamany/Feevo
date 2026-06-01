import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/bottom_nav_widget.dart';
import '../../core/providers/deezer_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;
  Timer? _debounce;

  late AnimationController _catController;
  late AnimationController _contentController;
  late Animation<double> _catScale;
  late Animation<double> _catOpacity;
  late Animation<double> _contentOpacity;
  late Animation<Offset>  _contentSlide;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Electronic', 'emoji': '⚡', 'colors': [const Color(0xFF7C3AED), const Color(0xFF9D5CF6)]},
    {'label': 'Lo-Fi',      'emoji': '🌊', 'colors': [const Color(0xFF0891B2), const Color(0xFF06B6D4)]},
    {'label': 'Rock',       'emoji': '🎸', 'colors': [const Color(0xFFB45309), const Color(0xFFD97706)]},
    {'label': 'Pop',        'emoji': '🎤', 'colors': [const Color(0xFFBE185D), const Color(0xFFEC4899)]},
    {'label': 'Jazz',       'emoji': '🎹', 'colors': [const Color(0xFF065F46), const Color(0xFF059669)]},
    {'label': 'Hip-Hop',    'emoji': '🎧', 'colors': [const Color(0xFF4C1D95), const Color(0xFF6D28D9)]},
    {'label': 'Classical',  'emoji': '🎻', 'colors': [const Color(0xFF1E3A5F), const Color(0xFF2563EB)]},
    {'label': 'R&B',        'emoji': '💗', 'colors': [const Color(0xFF831843), const Color(0xFFBE185D)]},
  ];

  @override
  void initState() {
    super.initState();
    _catController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _catScale   = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _catController, curve: Curves.elasticOut));
    _catOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _catController, curve: Curves.easeIn));

    _contentController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    _contentSlide   = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));

    _catController.forward();
    Future.delayed(const Duration(milliseconds: 150), () { if (mounted) _contentController.forward(); });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _catController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _isSearching = value.isNotEmpty);

    // debounce — صبر می‌کنه تا کاربر تایپ رو تموم کنه
    _debounce?.cancel();
    if (value.trim().length >= 2) {
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (mounted) context.read<DeezerProvider>().search(value.trim());
      });
    } else if (value.isEmpty) {
      context.read<DeezerProvider>().clearSearch();
    }
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchCtrl.clear();
    setState(() => _isSearching = false);
    context.read<DeezerProvider>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(top: -120, right: -60, child: Container(width: 350, height: 350, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.purple.withOpacity(0.12), AppColors.purple.withOpacity(0)])))),
          Positioned(bottom: -60, left: -60, child: Container(width: 280, height: 280, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.cyan.withOpacity(0.08), AppColors.cyan.withOpacity(0)])))),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentOpacity,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        children: [
                          const Text('Search 🔍', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3)),
                          const SizedBox(height: 14),

                          // search bar
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _isSearching ? AppColors.purple : AppColors.border, width: _isSearching ? 1.5 : 1),
                            ),
                            child: Row(children: [
                              const SizedBox(width: 14),
                              Icon(Icons.search_rounded, color: _isSearching ? AppColors.purple3 : AppColors.textThird, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  onChanged: _onSearchChanged,
                                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                                  decoration: const InputDecoration(
                                    hintText: 'Songs, artists, albums...',
                                    hintStyle: TextStyle(fontSize: 13, color: AppColors.textThird),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                              if (_isSearching)
                                GestureDetector(onTap: _clearSearch, child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.close_rounded, color: AppColors.textThird, size: 18)))
                              else
                                const SizedBox(width: 14),
                            ]),
                          ),

                          const SizedBox(height: 12),

                          // cat hint
                          AnimatedBuilder(
                            animation: _catController,
                            builder: (_, __) => Opacity(
                              opacity: _catOpacity.value,
                              child: Transform.scale(
                                scale: _catScale.value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [AppColors.purple.withOpacity(0.1), AppColors.cyan.withOpacity(0.06)]),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.purple.withOpacity(0.2)),
                                  ),
                                  child: Row(children: [
                                    Image.asset(AppConstants.cat6, width: 40, height: 40, fit: BoxFit.contain),
                                    const SizedBox(width: 10),
                                    const Expanded(child: Text('"Try searching your favorite artist..."', style: TextStyle(fontSize: 11, color: AppColors.purple3, fontStyle: FontStyle.italic))),
                                  ]),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (_isSearching)
                            _buildSearchResults()
                          else ...[
                            _buildCategories(),
                            const SizedBox(height: 20),
                            _buildTrending(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const FeevoBottomNav(currentIndex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Browse Categories', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2),
          itemCount: _categories.length,
          itemBuilder: (context, i) {
            final cat    = _categories[i];
            final colors = cat['colors'] as List<Color>;
            return GestureDetector(
              onTap: () {
                _searchCtrl.text = cat['label'] as String;
                _onSearchChanged(cat['label'] as String);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
                  boxShadow: [BoxShadow(color: colors.first.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Row(children: [
                  Text(cat['emoji'] as String, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(cat['label'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ]),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrending() {
    final mockTracks = [
      {'title': 'Blinding Lights',       'artist': 'The Weeknd',  'emoji': '🎵', 'duration': '3:22'},
      {'title': 'Let It Happen',          'artist': 'Tame Impala', 'emoji': '🎸', 'duration': '7:47'},
      {'title': 'Midnight City',          'artist': 'M83',         'emoji': '🌙', 'duration': '4:03'},
      {'title': 'Good Days',              'artist': 'SZA',         'emoji': '💗', 'duration': '4:39'},
      {'title': 'The Less I Know Better', 'artist': 'Tame Impala', 'emoji': '🌊', 'duration': '3:36'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🔥 Trending Now', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        ...List.generate(mockTracks.length, (i) {
          final track = mockTracks[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.nowPlaying),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  SizedBox(width: 20, child: Text('${i + 1}', style: const TextStyle(fontSize: 11, color: AppColors.textThird, fontWeight: FontWeight.w600))),
                  const SizedBox(width: 8),
                  Container(width: 42, height: 42, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: LinearGradient(colors: [AppColors.purple.withOpacity(0.6), AppColors.cyan.withOpacity(0.4)])), child: Center(child: Text(track['emoji']!, style: const TextStyle(fontSize: 20)))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(track['title']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                    Text(track['artist']!, style: const TextStyle(fontSize: 10, color: AppColors.textSecond)),
                  ])),
                  Text(track['duration']!, style: const TextStyle(fontSize: 10, color: AppColors.textThird)),
                ]),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Consumer<DeezerProvider>(
      builder: (context, spotify, _) {
        if (spotify.isSearching) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(color: AppColors.purple, strokeWidth: 2),
                SizedBox(height: 12),
                Text('Searching...', style: TextStyle(fontSize: 12, color: AppColors.textSecond)),
              ]),
            ),
          );
        }

        if (spotify.searchError != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Image.asset(AppConstants.cat5, width: 80, height: 80),
                const SizedBox(height: 12),
                Text(spotify.searchError!, style: const TextStyle(color: AppColors.textSecond)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => context.read<DeezerProvider>().search(_searchCtrl.text),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(999)),
                    child: const Text('Retry', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
          );
        }

        final tracks  = spotify.searchTracks;
        final artists = spotify.searchArtists;

        if (tracks.isEmpty && artists.isEmpty) {
          return Column(children: [
            const SizedBox(height: 40),
            Image.asset(AppConstants.cat5, width: 120, height: 120, fit: BoxFit.contain),
            const SizedBox(height: 16),
            Text('No results for "${_searchCtrl.text}"', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Try a different search term', style: TextStyle(fontSize: 12, color: AppColors.textSecond)),
          ]);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artists
            if (artists.isNotEmpty) ...[
              const Text('Artists', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: artists.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final artist = artists[i];
                    return GestureDetector(
                      onTap: () => context.push('${AppRoutes.artist}?id=${artist.id}'),
                      child: SizedBox(
                        width: 72,
                        child: Column(children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [AppColors.purple.withOpacity(0.5), AppColors.cyan.withOpacity(0.3)]),
                              image: artist.imageUrl != null ? DecorationImage(image: NetworkImage(artist.imageUrl!), fit: BoxFit.cover) : null,
                            ),
                            child: artist.imageUrl == null ? const Center(child: Text('🎤', style: TextStyle(fontSize: 24))) : null,
                          ),
                          const SizedBox(height: 6),
                          Text(artist.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Tracks
            if (tracks.isNotEmpty) ...[
              Text('${tracks.length} tracks', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              ...tracks.map((track) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.purple.withOpacity(0.1), AppColors.cyan.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border2),
                  ),
                  child: Row(children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(colors: [AppColors.purple.withOpacity(0.6), AppColors.cyan.withOpacity(0.4)]),
                        image: track.albumArt != null ? DecorationImage(image: NetworkImage(track.albumArt!), fit: BoxFit.cover) : null,
                      ),
                      child: track.albumArt == null ? const Center(child: Text('🎵', style: TextStyle(fontSize: 20))) : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(track.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                      Text('${track.artist} · ${track.album}', style: const TextStyle(fontSize: 10, color: AppColors.textSecond), overflow: TextOverflow.ellipsis),
                    ])),
                    Text(track.durationFormatted, style: const TextStyle(fontSize: 10, color: AppColors.textThird)),
                    const SizedBox(width: 8),
                    const Icon(Icons.play_circle_outline_rounded, color: AppColors.purple3, size: 26),
                  ]),
                ),
              )),
            ],
          ],
        );
      },
    );
  }
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
