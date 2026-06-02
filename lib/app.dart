import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/deezer_provider.dart';
import 'core/providers/mood_provider.dart';
import 'core/providers/live_room_provider.dart';
import 'core/providers/playlist_provider.dart';
import 'core/services/audio_player_service.dart';

class FeevoApp extends StatelessWidget {
  const FeevoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DeezerProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => LiveRoomProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerService()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp.router(
            title: 'Feevo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            routerConfig: createAppRouter(auth),
          );
        },
      ),
    );
  }
}
