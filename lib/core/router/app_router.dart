import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/verify_email_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/onboarding/genre_pick_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/music/search_screen.dart';
import '../../screens/music/artist_profile_screen.dart';
import '../../screens/music/playlist_detail_screen.dart';
import '../../screens/mood_flow/mood_flow_screen.dart';
import '../../screens/player/now_playing_screen.dart';
import '../../screens/player/lyrics_screen.dart';
import '../../screens/player/queue_screen.dart';
import '../../screens/live_room/live_rooms_screen.dart';
import '../../screens/live_room/live_room_inside_screen.dart';
import '../../screens/live_room/create_room_screen.dart';
import '../../screens/memory_map/memory_map_screen.dart';
import '../../screens/memory_map/memory_detail_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/settings_screen.dart';
import '../../screens/profile/premium_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../providers/auth_provider.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPass = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String onboarding = '/onboarding';
  static const String genrePick = '/genre-pick';
  static const String home = '/home';
  static const String search = '/search';
  static const String moodFlow = '/mood-flow';
  static const String liveRooms = '/live-rooms';
  static const String liveRoomIn = '/live-room-inside';
  static const String createRoom = '/live-rooms/create';
  static const String memoryMap = '/memory-map';
  static const String memoryDetail = '/memory-detail';
  static const String nowPlaying = '/player';
  static const String lyrics = '/player/lyrics';
  static const String queue = '/player/queue';
  static const String artist = '/artist';
  static const String playlist = '/playlist';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String premium = '/premium';
  static const String settings = '/settings';
  static const String notifications = '/settings/notifications';
  static const String language = '/settings/language';
}

const _publicRoutes = [
  AppRoutes.splash,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPass,
  AppRoutes.verifyEmail,
  AppRoutes.onboarding,
  // genrePick عمداً اینجا نیست — بعد از login نشون داده میشه
];

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuth = authProvider.isAuthenticated;
      final isUnknown = authProvider.status == AuthStatus.unknown;

      if (isUnknown) return AppRoutes.splash;

      final isPublic = _publicRoutes.contains(location);

      if (!isAuth && !isPublic) return AppRoutes.login;

      if (isAuth && isPublic && location != AppRoutes.splash) {
        return AppRoutes.home;
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF06060F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Coming soon...',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(state.uri.toString(),
                style: const TextStyle(color: Colors.white30, fontSize: 11)),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (c, s) => const SplashScreen()),
      GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (c, s) => const LoginScreen()),
      GoRoute(
          path: AppRoutes.register,
          name: 'register',
          builder: (c, s) => const RegisterScreen()),
      GoRoute(
          path: AppRoutes.forgotPass,
          name: 'forgot-password',
          builder: (c, s) => const ForgotPasswordScreen()),
      GoRoute(
          path: AppRoutes.verifyEmail,
          name: 'verify-email',
          builder: (c, s) => const VerifyEmailScreen()),
      GoRoute(
          path: AppRoutes.onboarding,
          name: 'onboarding',
          builder: (c, s) => const OnboardingScreen()),
      GoRoute(
          path: AppRoutes.genrePick,
          name: 'genre-pick',
          builder: (c, s) => const GenrePickScreen()),
      GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (c, s) => const HomeScreen()),
      GoRoute(
          path: AppRoutes.search,
          name: 'search',
          builder: (c, s) => const SearchScreen()),
      GoRoute(
          path: AppRoutes.moodFlow,
          name: 'mood-flow',
          builder: (c, s) => const MoodFlowScreen()),
      GoRoute(
          path: AppRoutes.nowPlaying,
          name: 'now-playing',
          builder: (c, s) => const NowPlayingScreen()),
      GoRoute(
          path: AppRoutes.lyrics,
          name: 'lyrics',
          builder: (c, s) => const LyricsScreen()),
      GoRoute(
          path: AppRoutes.queue,
          name: 'queue',
          builder: (c, s) => const QueueScreen()),
      GoRoute(
          path: AppRoutes.artist,
          name: 'artist',
          builder: (c, s) => const ArtistProfileScreen()),
      GoRoute(
          path: AppRoutes.playlist,
          name: 'playlist',
          builder: (c, s) => const PlaylistDetailScreen()),
      GoRoute(
          path: AppRoutes.liveRooms,
          name: 'live-rooms',
          builder: (c, s) => const LiveRoomsScreen()),
      GoRoute(
          path: AppRoutes.liveRoomIn,
          name: 'live-room-inside',
          builder: (c, s) => const LiveRoomInsideScreen()),
      GoRoute(
          path: AppRoutes.createRoom,
          name: 'create-room',
          builder: (c, s) => const CreateRoomScreen()),
      GoRoute(
          path: AppRoutes.memoryMap,
          name: 'memory-map',
          builder: (c, s) => const MemoryMapScreen()),
      GoRoute(
          path: AppRoutes.memoryDetail,
          name: 'memory-detail',
          builder: (c, s) => const MemoryDetailScreen()),
      GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (c, s) => const ProfileScreen()),
      GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (c, s) => const SettingsScreen()),
      GoRoute(
          path: AppRoutes.notifications,
          name: 'notifications',
          builder: (c, s) => const NotificationsScreen()),
      GoRoute(
          path: AppRoutes.language,
          name: 'language',
          builder: (c, s) => const LanguageScreen()),
      GoRoute(
          path: AppRoutes.premium,
          name: 'premium',
          builder: (c, s) => const PremiumScreen()),
      GoRoute(
          path: AppRoutes.editProfile,
          name: 'edit-profile',
          builder: (c, s) => const EditProfileScreen()),
    ],
  );
}
