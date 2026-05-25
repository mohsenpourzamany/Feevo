class AppConstants {
  AppConstants._();

  // App Info
  static const String appName     = 'Feevo';
  static const String appVersion  = '1.0.0';
  static const String packageName = 'music.feevo.app';
  static const String website     = 'https://feevo.music';

  // Supabase
  static const String supabaseUrl  = 'YOUR_SUPABASE_URL';
  static const String supabaseKey  = 'YOUR_SUPABASE_ANON_KEY';

  // API
  static const String baseUrl        = 'https://api.feevo.music';
  static const int    connectTimeout = 15000;
  static const int    receiveTimeout = 15000;

  // Storage keys
  static const String keyOnboarded = 'feevo_onboarded';
  static const String keyToken     = 'feevo_token';
  static const String keyUserId    = 'feevo_user_id';
  static const String keyTheme     = 'feevo_theme';
  static const String keyLanguage  = 'feevo_language';
  static const String keyGenreDone = 'feevo_genre_done'; // ← جدید

  // Cat mascot paths
  static const String cat1 = 'assets/images/cats/cat_1.png'; // Super Hype
  static const String cat2 = 'assets/images/cats/cat_2.png'; // Hype
  static const String cat3 = 'assets/images/cats/cat_3.png'; // Chill
  static const String cat4 = 'assets/images/cats/cat_4.png'; // Energetic
  static const String cat5 = 'assets/images/cats/cat_5.png'; // Sad
  static const String cat6 = 'assets/images/cats/cat_6.png'; // Thinking
  static const String cat7 = 'assets/images/cats/cat_7.png'; // Focused

  // Supported Languages
  static const List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English',  'flag': '🇺🇸', 'rtl': 'false'},
    {'code': 'fa', 'name': 'فارسی',   'flag': '🇮🇷', 'rtl': 'true'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦', 'rtl': 'true'},
    {'code': 'tr', 'name': 'Türkçe',  'flag': '🇹🇷', 'rtl': 'false'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸', 'rtl': 'false'},
    {'code': 'fr', 'name': 'Français','flag': '🇫🇷', 'rtl': 'false'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪', 'rtl': 'false'},
  ];

  // Mood types
  static const List<Map<String, String>> moods = [
    {'id': 'energetic',   'label': 'Energetic',   'emoji': '⚡'},
    {'id': 'chill',       'label': 'Chill',       'emoji': '🌙'},
    {'id': 'focused',     'label': 'Focused',     'emoji': '💭'},
    {'id': 'melancholic', 'label': 'Melancholic', 'emoji': '🌧'},
    {'id': 'hype',        'label': 'Hype',        'emoji': '🔥'},
    {'id': 'happy',       'label': 'Happy',       'emoji': '💗'},
  ];
}
