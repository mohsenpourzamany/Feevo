import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _darkMode = true;
  bool _dataDownload = false;
  bool _autoPlay = true;
  bool _highQuality = true;

  late AnimationController _contentController;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

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
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
    _contentController.forward();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.purple.withOpacity(0.14),
                  AppColors.purple.withOpacity(0),
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SlideTransition(
              position: _contentSlide,
              child: FadeTransition(
                opacity: _contentOpacity,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  children: [
                    // header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: AppColors.textSecond, size: 16),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Settings ⚙️',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Appearance
                    const _SectionTitle(title: 'Appearance'),
                    _ToggleItem(
                      icon: Icons.dark_mode_outlined,
                      label: 'Dark Mode',
                      sub: 'Always on for best experience',
                      value: _darkMode,
                      onChanged: (v) => setState(() => _darkMode = v),
                    ),

                    const SizedBox(height: 16),

                    // ── Playback
                    const _SectionTitle(title: 'Playback'),
                    _ToggleItem(
                      icon: Icons.high_quality_outlined,
                      label: 'High Quality Audio',
                      sub: 'Uses more data',
                      value: _highQuality,
                      onChanged: (v) => setState(() => _highQuality = v),
                    ),
                    _ToggleItem(
                      icon: Icons.play_circle_outline_rounded,
                      label: 'Autoplay',
                      sub: 'Continue playing similar songs',
                      value: _autoPlay,
                      onChanged: (v) => setState(() => _autoPlay = v),
                    ),
                    _ToggleItem(
                      icon: Icons.download_outlined,
                      label: 'Download on Wi-Fi Only',
                      sub: 'Save mobile data',
                      value: _dataDownload,
                      onChanged: (v) => setState(() => _dataDownload = v),
                    ),

                    const SizedBox(height: 16),

                    // ── Notifications
                    const _SectionTitle(title: 'Notifications'),
                    _NavItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notification Settings',
                      sub: 'Manage all alerts',
                      onTap: () => context.push(AppRoutes.notifications),
                    ),

                    const SizedBox(height: 16),

                    // ── Language
                    const _SectionTitle(title: 'Language & Region'),
                    _NavItem(
                      icon: Icons.language_outlined,
                      label: 'App Language',
                      sub: 'English',
                      onTap: () => context.push(AppRoutes.language),
                    ),

                    const SizedBox(height: 16),

                    // ── Privacy
                    const _SectionTitle(title: 'Privacy & Security'),
                    _NavItem(
                      icon: Icons.lock_outline_rounded,
                      label: 'Privacy Settings',
                      sub: 'Control your data',
                      onTap: () {},
                    ),
                    _NavItem(
                      icon: Icons.history_rounded,
                      label: 'Listening History',
                      sub: 'View or clear history',
                      onTap: () {},
                    ),

                    const SizedBox(height: 16),

                    // ── About
                    const _SectionTitle(title: 'About'),
                    _NavItem(
                      icon: Icons.info_outline_rounded,
                      label: 'App Version',
                      sub: 'v1.0.0',
                      onTap: () {},
                      showArrow: false,
                    ),
                    _NavItem(
                      icon: Icons.description_outlined,
                      label: 'Terms of Service',
                      onTap: () {},
                    ),
                    _NavItem(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      onTap: () {},
                    ),

                    const SizedBox(height: 24),

                    // danger zone
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.errorBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Danger Zone',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {},
                            child: const Row(
                              children: [
                                Icon(Icons.delete_outline_rounded,
                                    color: AppColors.error, size: 18),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Delete Account',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.error,
                                        ),
                                      ),
                                      Text(
                                        'This action cannot be undone',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textThird,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded,
                                    color: AppColors.error, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notifications Screen ──────────────────────────────────────
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  bool _allNotifs = true;
  bool _newReleases = true;
  bool _playlists = false;
  bool _liveRooms = true;
  bool _chatMentions = true;
  bool _billing = true;

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
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          Positioned(
            top: -100,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.cyan.withOpacity(0.1),
                  AppColors.cyan.withOpacity(0),
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _opacity,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  children: [
                    // header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: AppColors.textSecond, size: 16),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Notifications 🔔',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // master toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppColors.purple.withOpacity(0.18),
                          AppColors.cyan.withOpacity(0.08),
                        ]),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border2),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('All Notifications',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary)),
                                SizedBox(height: 2),
                                Text('Master toggle for all alerts',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecond)),
                              ],
                            ),
                          ),
                          _Toggle(
                              value: _allNotifs,
                              onChanged: (v) => setState(() => _allNotifs = v)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const _SectionTitle(title: 'Music'),
                    _ToggleItem(
                      icon: Icons.new_releases_outlined,
                      label: 'New Releases',
                      sub: 'Artists you follow',
                      value: _newReleases,
                      onChanged: (v) => setState(() => _newReleases = v),
                    ),
                    _ToggleItem(
                      icon: Icons.playlist_add_check_rounded,
                      label: 'Playlist Updates',
                      sub: 'AI refreshed your lists',
                      value: _playlists,
                      onChanged: (v) => setState(() => _playlists = v),
                    ),

                    const SizedBox(height: 16),

                    const _SectionTitle(title: 'Live Rooms'),
                    _ToggleItem(
                      icon: Icons.mic_rounded,
                      label: 'Room Goes Live',
                      sub: 'Followed hosts',
                      value: _liveRooms,
                      onChanged: (v) => setState(() => _liveRooms = v),
                    ),
                    _ToggleItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Chat Mentions',
                      sub: 'When someone @you',
                      value: _chatMentions,
                      onChanged: (v) => setState(() => _chatMentions = v),
                    ),

                    const SizedBox(height: 16),

                    const _SectionTitle(title: 'Account'),
                    _ToggleItem(
                      icon: Icons.bolt_rounded,
                      label: 'Subscription & Billing',
                      sub: 'Renewal reminders',
                      value: _billing,
                      onChanged: (v) => setState(() => _billing = v),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Language Screen ───────────────────────────────────────────
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with SingleTickerProviderStateMixin {
  String _selected = 'en';

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
    // group by region
    final Map<String, List<Map<String, String>>> grouped = {};
    for (final lang in AppConstants.languages) {
      final region = lang['region']!;
      grouped.putIfAbsent(region, () => []).add(lang);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
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
                  AppColors.purple.withOpacity(0.12),
                  AppColors.purple.withOpacity(0),
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SlideTransition(
              position: _slide,
              child: FadeTransition(
                opacity: _opacity,
                child: Column(
                  children: [
                    // header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: AppColors.textSecond,
                                  size: 16),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'Language 🌍',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // cat_6 thinking
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppColors.purple.withOpacity(0.12),
                            AppColors.cyan.withOpacity(0.06),
                          ]),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border2),
                        ),
                        child: Row(
                          children: [
                            Image.asset(AppConstants.cat6,
                                width: 36, height: 36, fit: BoxFit.contain),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Choose your preferred language. RTL languages are fully supported.',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecond,
                                    height: 1.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // language list grouped
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        children: grouped.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8, top: 4),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textThird,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              ...entry.value.map((lang) {
                                final isSelected = _selected == lang['code'];
                                final isImage = lang['isImage'] == 'true';
                                final isRtl = lang['rtl'] == 'true';
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selected = lang['code']!),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 13),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(colors: [
                                              AppColors.purple.withOpacity(0.2),
                                              AppColors.cyan.withOpacity(0.1),
                                            ])
                                          : null,
                                      color:
                                          isSelected ? null : AppColors.surface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.purple2
                                            : AppColors.border,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // flag
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: isImage
                                              ? Image.asset(
                                                  lang['flag']!,
                                                  width: 28,
                                                  height: 18,
                                                  fit: BoxFit.cover,
                                                )
                                              : Text(
                                                  lang['flag']!,
                                                  style: const TextStyle(
                                                      fontSize: 24),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        // name
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                lang['name']!,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? AppColors.textPrimary
                                                      : AppColors.textPrimary,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    lang['native']!,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          AppColors.textSecond,
                                                    ),
                                                  ),
                                                  if (isRtl) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5,
                                                          vertical: 1),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.cyan
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        border: Border.all(
                                                          color: AppColors.cyan
                                                              .withOpacity(0.3),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'RTL',
                                                        style: TextStyle(
                                                          fontSize: 8,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              AppColors.cyan2,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // check
                                        if (isSelected)
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient:
                                                  AppColors.primaryGradient,
                                            ),
                                            child: const Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                                size: 14),
                                          )
                                        else
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.surface2,
                                              border: Border.all(
                                                  color: AppColors.border),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 4),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    // apply button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.purple.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Apply Language ✓',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textThird,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final bool value;
  final void Function(bool) onChanged;

  const _ToggleItem({
    required this.icon,
    required this.label,
    this.sub,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.purple.withOpacity(0.2),
                AppColors.cyan.withOpacity(0.1),
              ]),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: AppColors.purple3, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                if (sub != null)
                  Text(sub!,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textThird)),
              ],
            ),
          ),
          _Toggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final VoidCallback onTap;
  final bool showArrow;

  const _NavItem({
    required this.icon,
    required this.label,
    this.sub,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.purple.withOpacity(0.2),
                  AppColors.cyan.withOpacity(0.1),
                ]),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: AppColors.purple3, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  if (sub != null)
                    Text(sub!,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textThird)),
                ],
              ),
            ),
            if (showArrow)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textThird, size: 18),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: value ? AppColors.primaryGradient : null,
          color: value ? null : AppColors.surface2,
          boxShadow: value
              ? [
                  BoxShadow(
                    color: AppColors.purple.withOpacity(0.4),
                    blurRadius: 8,
                  )
                ]
              : [],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
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
