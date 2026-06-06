import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/deezer_provider.dart';
import 'core/providers/mood_provider.dart';
import 'core/providers/live_room_provider.dart';
import 'core/providers/playlist_provider.dart';
import 'core/providers/memory_provider.dart';
import 'core/services/audio_player_service.dart';
import 'main.dart';

class FeevoApp extends StatefulWidget {
  const FeevoApp({super.key});
  @override
  State<FeevoApp> createState() => _FeevoAppState();

  static _FeevoAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_FeevoAppState>();
}

class _FeevoAppState extends State<FeevoApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_language') ?? 'en';
    setState(() => _locale = Locale(code));
  }

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

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
        ChangeNotifierProvider(create: (_) => MemoryProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerService()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final router = createAppRouter(auth);
          deepLinkService.onNavigate = (route) => router.go(route);

          return MaterialApp.router(
            title: 'Feevo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            routerConfig: router,
            locale: _locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('fa'),
              Locale('ar'),
              Locale('tr'),
              Locale('es'),
              Locale('fr'),
              Locale('de'),
              Locale('ru'),
              Locale('zh'),
              Locale('hi'),
              Locale('ur'),
            ],
          );
        },
      ),
    );
  }
}
