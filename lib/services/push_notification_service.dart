import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _supabase = Supabase.instance.client;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    await Firebase.initializeApp();

    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      print('[FCM] Token: $_fcmToken');

      // Save token to Supabase
      await _saveTokenToSupabase();
    }

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap - navigate to relevant screen
        print('[FCM] Notification tapped: ${response.payload}');
      },
    );

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      _showNotification(
        message.notification?.title ?? 'GeesTrip',
        message.notification?.body ?? '',
      );
    });

    // Background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('[FCM] Background notification opened');
    });

    // Token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      _saveTokenToSupabase();
    });
  }

  Future<void> _saveTokenToSupabase() async {
    final user = _supabase.auth.currentUser;
    if (user == null || _fcmToken == null) return;

    try {
      await _supabase.from('profiles').update({
        'fcm_token': _fcmToken,
      }).eq('id', user.id);
    } catch (e) {
      print('[FCM] Error saving token: $e');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'geestrip_channel',
      'GeesTrip Notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      payload: null,
      notificationDetails: details,
    );
  }

  // Send push notification to specific user
  Future<void> sendToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('fcm_token')
          .eq('id', userId)
          .maybeSingle();
      if (response != null && response['fcm_token'] != null) {
        // In production, send via Firebase Admin SDK on server side
        print('[FCM] Would send to ${response['fcm_token']}: $title - $body');
      }
    } catch (e) {
      print('[FCM] Error sending notification: $e');
    }
  }
}
