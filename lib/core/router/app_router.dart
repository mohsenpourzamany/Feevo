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
  static const String liveRoomIn = '/live-rooms/:id';
  static const String createRoom = '/live-rooms/create';
  static const String memoryMap = '/memory-map';
  static const String memoryDetail = '/memory-map/:id';
  static const String nowPlaying = '/player';
  static const String lyrics = '/player/lyrics';
  static const String queue = '/player/queue';
  static const String album = '/album/:id';
  static const String artist = '/artist/:id';
  static const String playlist = '/playlist/:id';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String premium = '/premium';
  static const String settings = '/settings';
  static const String notifications = '/settings/notifications';
  static const String language = '/settings/language';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF06060F),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Coming soon...', style: TextStyle(color: Colors.white70)),
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
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPass,
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.verifyEmail,
      name: 'verify-email',
      builder: (context, state) => const VerifyEmailScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.genrePick,
      name: 'genre-pick',
      builder: (context, state) => const GenrePickScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
