import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// ignore: unused_import
import 'package:provider/provider.dart';

// screens رو بعداً import می‌کنیم
// import '../../screens/...';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String genrePick = '/onboarding/genre';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPass = '/forgot-password';
  static const String verifyEmail = '/verify-email';
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
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const Scaffold(
        backgroundColor: Color(0xFF06060F),
        body: Center(
          child: Text(
            'feevo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    ),
    // بقیه routes رو وقتی screens ساختیم اضافه می‌کنیم
  ],
);
