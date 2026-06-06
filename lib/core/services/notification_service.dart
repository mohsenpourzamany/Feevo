import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // درخواست permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint(
        'NotificationService: auth status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('NotificationService: permission granted');
      await _saveToken();
    } else {
      debugPrint('NotificationService: permission denied');
    }

    // foreground notifications
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint(
          'NotificationService: foreground message: ${message.notification?.title}');
    });

    // وقتی از notification باز میشه
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('NotificationService: opened from notification');
    });
  }

  Future<void> _saveToken() async {
    try {
      // روی iOS باید کمی صبر کنیم تا APNS token آماده بشه
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await Future.delayed(const Duration(seconds: 3));
      }

      final token = await _messaging.getToken();
      debugPrint('NotificationService: FCM token: $token');
      final userId = Supabase.instance.client.auth.currentUser?.id;
      debugPrint('NotificationService: userId: $userId');
      if (token == null || userId == null) return;

      await Supabase.instance.client.from('users').update({
        'fcm_token': token,
      }).eq('id', userId);

      debugPrint('NotificationService: token saved ✅');
    } catch (e) {
      debugPrint('NotificationService saveToken error: $e');
    }
  }
}
