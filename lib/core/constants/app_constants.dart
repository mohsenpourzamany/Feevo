class AppConstants {
  AppConstants._();

  // ─── App Info ─────────────────────────────────────────────────────────────────
  static const String appName = 'Feevo';
  static const String appVersion = '1.0.0';
  static const String packageName = 'music.feevo.app';
  static const String website = 'https://feevo.music';

  // ─── Supabase ─────────────────────────────────────────────────────────────────
  static const String supabaseUrl = 'https://mizjjblcitgpkogfobbn.supabase.co';
  static const String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pempqYmxjaXRncGtvZ2ZvYmJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNDM0MTgsImV4cCI6MjA5NTYxOTQxOH0.Bpni6PsYYBf-VggL92DjDVEl9UjERMs1asylVgyfCf0';

  // ─── API ──────────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://api.feevo.music';
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // ─── Spotify ──────────────────────────────────────────────────────────────────
  static const String spotifyClientId = 'YOUR_SPOTIFY_CLIENT_ID';
  static const String spotifyClientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET';
  static const String spotifyBaseUrl = 'https://api.spotify.com/v1';
  static const String spotifyTokenUrl =
      'https://accounts.spotify.com/api/token';

  // ─── Deep Links ───────────────────────────────────────────────────────────────
  static const String appScheme = 'music.feevo.app';
  static const String loginCallbackPath = '://login-callback';
  static const String resetPasswordPath = '://reset-password';

  // ─── Storage Keys ─────────────────────────────────────────────────────────────
  static const String keyOnboarded = 'feevo_onboarded';
  static const String keyToken = 'feevo_token';
  static const String keyUserId = 'feevo_user_id';
  static const String keyTheme = 'feevo_theme';
  static const String keyLanguage = 'feevo_language';
  static const String keyGenreDone = 'feevo_genre_done';

  // ─── Cat Mascot Paths ─────────────────────────────────────────────────────────
  static const String cat1 = 'assets/images/cats/cat_1.png'; // Super Hype
  static const String cat2 = 'assets/images/cats/cat_2.png'; // Hype
  static const String cat3 = 'assets/images/cats/cat_3.png'; // Chill
  static const String cat4 = 'assets/images/cats/cat_4.png'; // Energetic
  static const String cat5 = 'assets/images/cats/cat_5.png'; // Sad
  static const String cat6 = 'assets/images/cats/cat_6.png'; // Thinking
  static const String cat7 = 'assets/images/cats/cat_7.png'; // Focused

  // ─── Mood Types ───────────────────────────────────────────────────────────────
  static const List<Map<String, String>> moods = [
    {'id': 'energetic', 'label': 'Energetic', 'emoji': '⚡'},
    {'id': 'chill', 'label': 'Chill', 'emoji': '🌙'},
    {'id': 'focused', 'label': 'Focused', 'emoji': '💭'},
    {'id': 'melancholic', 'label': 'Melancholic', 'emoji': '🌧'},
    {'id': 'hype', 'label': 'Hype', 'emoji': '🔥'},
    {'id': 'happy', 'label': 'Happy', 'emoji': '💗'},
  ];

  // ─── Supported Languages ──────────────────────────────────────────────────────
  static const List<Map<String, String>> languages = [
    {
      'code': 'en',
      'name': 'English',
      'native': 'English',
      'flag': '🇺🇸',
      'rtl': 'false',
      'region': 'Global',
    },
    {
      'code': 'fa',
      'name': 'Persian',
      'native': 'فارسی',
      'flag': 'assets/images/flags/iran_flag.png',
      'isImage': 'true',
      'rtl': 'true',
      'region': 'Middle East',
    },
    {
      'code': 'ar',
      'name': 'Arabic',
      'native': 'العربية',
      'flag': '🇸🇦',
      'rtl': 'true',
      'region': 'Middle East',
    },
    {
      'code': 'tr',
      'name': 'Turkish',
      'native': 'Türkçe',
      'flag': '🇹🇷',
      'rtl': 'false',
      'region': 'Europe / Asia',
    },
    {
      'code': 'es',
      'name': 'Spanish',
      'native': 'Español',
      'flag': '🇪🇸',
      'rtl': 'false',
      'region': 'Global',
    },
    {
      'code': 'fr',
      'name': 'French',
      'native': 'Français',
      'flag': '🇫🇷',
      'rtl': 'false',
      'region': 'Global',
    },
    {
      'code': 'de',
      'name': 'German',
      'native': 'Deutsch',
      'flag': '🇩🇪',
      'rtl': 'false',
      'region': 'Europe',
    },
    {
      'code': 'ru',
      'name': 'Russian',
      'native': 'Русский',
      'flag': '🇷🇺',
      'rtl': 'false',
      'region': 'Europe / Asia',
    },
    {
      'code': 'zh',
      'name': 'Chinese',
      'native': '中文',
      'flag': '🇨🇳',
      'rtl': 'false',
      'region': 'Asia',
    },
    {
      'code': 'hi',
      'name': 'Hindi',
      'native': 'हिन्दी',
      'flag': '🇮🇳',
      'rtl': 'false',
      'region': 'Asia',
    },
    {
      'code': 'ur',
      'name': 'Urdu',
      'native': 'اردو',
      'flag': '🇵🇰',
      'rtl': 'true',
      'region': 'Asia',
    },
  ];
}
