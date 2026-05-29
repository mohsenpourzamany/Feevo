import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';

class ArtistProfileScreen extends StatefulWidget {
  const ArtistProfileScreen({super.key});

  @override
  State<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen>
    with TickerProviderStateMixin {
  bool _isFollowing = false;
  int _selectedTab = 0;

  late AnimationController _contentController;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  final List<String> _tabs = ['Popular', 'Albums', 'Similar'];

  final List<Map<String, dynamic>> _popularTracks = [
    {
      'title': 'Let It Happen',
      'album': 'Currents',
      'plays': '847M',
      'emoji': '🌊',
      'duration': '7:47'
    },
    {
      'title': 'The Less I Know Better',
      'album': 'Currents',
      'plays': '721M',
      'emoji': '🎸',
      'duration': '3:36'
    },
    {
      'title': 'Borderline',
      'album': 'The Slow Rush',
      'plays': '512M',
      'emoji': '⚡',
      'duration': '3:49'
    },
    {
      'title': 'Feels Like We Only Go',
      'album': 'Lonerism',
      'plays': '489M',
      'emoji': '🌙',
      'duration': '4:01'
    },
    {
      'title': 'Eventually',
      'album': 'Currents',
      'plays': '402M',
      'emoji': '💗',
      'duration': '5:19'
    },
    {
      'title': 'One More Year',
      'album': 'The Slow Rush',
      'plays': '334M',
      'emoji': '🎵',
      'duration': '4:50'
    },
  ];

  final List<Map<String, String>> _albums = [
    {'title': 'The Slow Rush', 'year': '2020', 'emoji': '🌊', 'tracks': '12'},
    {'title': 'Currents', 'year': '2015', 'emoji': '🌀', 'tracks': '13'},
    {'title': 'Lonerism', 'year': '2012', 'emoji': '🎭', 'tracks': '13'},
    {'title': 'InnerSpeaker', 'year': '2010', 'emoji': '🔮', 'tracks': '10'},
  ];

  final List<Map<String, String>> _similar = [
    {'name': 'Caribou', 'genre': 'Psychedelic', 'emoji': '🎵'},
    {'name': 'Beach House', 'genre': 'Dream Pop', 'emoji': '🌊'},
    {'name': 'Air', 'genre': 'Electronic', 'emoji': '🎹'},
    {'name': 'MGMT', 'genre': 'Indie', 'emoji': '⚡'},
    {'name': 'Pond', 'genre': 'Psychedelic', 'emoji': '🌀'},
  ];

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar as header
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: const Color(0xFF0D0520),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildHeaderBg(topPadding),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.4),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.4),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: const Icon(Icons.more_horiz_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),

          // ── Body content
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _contentSlide,
              child: FadeTransition(
                opacity: _contentOpacity,
                child: Column(
                  children: [
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                    _buildStats(),
                    const SizedBox(height: 16),
                    _buildTabs(),
                    const SizedBox(height: 12),
                    _buildTabContent(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header Background ─────────────────────────────────────
  Widget _buildHeaderBg(double topPadding) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a0a40),
            Color(0xFF0891B2),
            Color(0xFF4C1D95),
          ],
        ),
      ),
      child: Stack(
        children: [
          // orb
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.cyan.withOpacity(0.25),
                  AppColors.cyan.withOpacity(0),
                ]),
              ),
            ),
          ),

          // cat — bottom right, safe zone
          Positioned(
            bottom: 80,
            right: 16,
            child: Image.asset(
              AppConstants.cat3,
              width: 110,
              height: 110,
              fit: BoxFit.contain,
            ),
          ),

          // artist info — bottom left
          Positioned(
            bottom: 16,
            left: 20,
            right: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.cyan.withOpacity(0.4)),
                  ),
                  child: const Text(
                    '✓ VERIFIED ARTIST',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cyan2,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tame Impala',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                  ),
                ),
                const Text(
                  'Psychedelic · Electronic · Indie',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ────────────────────────────────────────
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isFollowing = !_isFollowing),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 44,
                decoration: BoxDecoration(
                  gradient: _isFollowing ? null : AppColors.primaryGradient,
                  color: _isFollowing ? AppColors.surface : null,
                  borderRadius: BorderRadius.circular(999),
                  border:
                      _isFollowing ? Border.all(color: AppColors.border) : null,
                  boxShadow: _isFollowing
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.purple.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    _isFollowing ? 'Following ✓' : 'Follow',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _isFollowing ? AppColors.textSecond : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const _IconBtn(icon: Icons.shuffle_rounded),
          const SizedBox(width: 8),
          const _IconBtn(icon: Icons.share_outlined),
        ],
      ),
    );
  }

  // ── Stats ─────────────────────────────────────────────────
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const _StatItem(value: '12.4M', label: 'Followers'),
          _Divider(),
          const _StatItem(value: '4', label: 'Albums'),
          _Divider(),
          const _StatItem(value: '847M', label: 'Monthly Plays'),
        ],
      ),
    );
  }

  // ── Tabs ──────────────────────────────────────────────────
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final active = _selectedTab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    gradient: active ? AppColors.primaryGradient : null,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: AppColors.purple.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      _tabs[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : AppColors.textSecond,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Tab Content ───────────────────────────────────────────
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildPopular();
      case 1:
        return _buildAlbums();
      case 2:
        return _buildSimilar();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPopular() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(_popularTracks.length, (i) {
          final t = _popularTracks[i];
          return GestureDetector(
            onTap: () => context.push(AppRoutes.nowPlaying),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                gradient: i == 0
                    ? LinearGradient(colors: [
                        AppColors.purple.withOpacity(0.12),
                        AppColors.cyan.withOpacity(0.06),
                      ])
                    : null,
                color: i == 0 ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: i == 0 ? AppColors.border2 : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: i == 0
                        ? const Icon(Icons.equalizer_rounded,
                            color: AppColors.purple3, size: 18)
                        : Text('${i + 1}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textThird),
                            textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      gradient: LinearGradient(colors: [
                        AppColors.purple.withOpacity(0.5),
                        AppColors.cyan.withOpacity(0.3),
                      ]),
                    ),
                    child: Center(
                      child: Text(t['emoji'] as String,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['title'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis),
                        Text(t['album'] as String,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textSecond)),
                      ],
                    ),
                  ),
                  Text(t['plays'] as String,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textThird)),
                  const SizedBox(width: 8),
                  Text(t['duration'] as String,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textThird)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAlbums() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _albums.length,
        itemBuilder: (context, i) {
          final a = _albums[i];
          return GestureDetector(
            onTap: () => context.push(AppRoutes.playlist),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15)),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.purple.withOpacity(0.5),
                            AppColors.cyan.withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(a['emoji']!,
                            style: const TextStyle(fontSize: 44)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a['title']!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis),
                        Text('${a['year']} · ${a['tracks']} tracks',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textSecond)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimilar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _similar
            .map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(colors: [
                            AppColors.purple.withOpacity(0.4),
                            AppColors.cyan.withOpacity(0.2),
                          ]),
                        ),
                        child: Center(
                          child: Text(a['emoji']!,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a['name']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                )),
                            Text(a['genre']!,
                                style: const TextStyle(
                                    fontSize: 10, color: AppColors.textSecond)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text('Follow',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecond,
                            )),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  const _IconBtn({required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textSecond, size: 18),
      );
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
              child: Text(value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  )),
            ),
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textThird)),
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: AppColors.border);
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
