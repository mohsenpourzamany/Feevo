import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();

  // callback برای handle کردن لینک‌ها
  Function(String route)? onNavigate;

  Future<void> init() async {
    // لینک اولیه — وقتی app از لینک باز میشه
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink.toString());
      }
    } catch (e) {
      debugPrint('DeepLinkService init error: $e');
    }

    // لینک‌های بعدی — وقتی app باز هست
    _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri.toString());
    }, onError: (e) {
      debugPrint('DeepLinkService stream error: $e');
    });
  }

  void _handleLink(String link) {
    debugPrint('DeepLinkService: received link: $link');

    // feevo://live-room?id=ROOM_ID
    if (link.contains('live-room')) {
      final uri = Uri.parse(link);
      final roomId = uri.queryParameters['id'];
      if (roomId != null && roomId.isNotEmpty) {
        onNavigate?.call('/live-room-inside?id=$roomId');
      }
    }

    // feevo://artist?id=ARTIST_ID
    else if (link.contains('artist')) {
      final uri = Uri.parse(link);
      final artistId = uri.queryParameters['id'];
      if (artistId != null && artistId.isNotEmpty) {
        onNavigate?.call('/artist?id=$artistId');
      }
    }

    // feevo://playlist?id=PLAYLIST_ID
    else if (link.contains('playlist')) {
      final uri = Uri.parse(link);
      final playlistId = uri.queryParameters['id'];
      if (playlistId != null && playlistId.isNotEmpty) {
        onNavigate?.call('/playlist?id=$playlistId');
      }
    }
  }
}
