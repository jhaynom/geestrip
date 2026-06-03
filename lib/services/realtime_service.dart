import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  final _supabase = Supabase.instance.client;

  Function(Map<String, dynamic>)? onNewMessage;
  Function(Map<String, dynamic>)? onAgentJoined;
  Function(Map<String, dynamic>)? onNewNotification;
  Function(Map<String, dynamic>)? onNewBooking;
  Function()? onConnected;
  Function()? onDisconnected;

  StreamSubscription<dynamic>? _messageSubscription;
  StreamSubscription<dynamic>? _requestSubscription;
  StreamSubscription<dynamic>? _notificationSubscription;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void connect() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    if (_isConnected) return;

    _isConnected = true;
    onConnected?.call();

    // Listen for new messages
    _messageSubscription = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .listen((data) {
          for (final message in data) {
            if (message['receiver_id'] == user.id ||
                message['sender_id'] == user.id) {
              onNewMessage?.call(message);
            }
          }
        }, onError: _handleStreamError);

    // Listen for live chat requests
    _requestSubscription = _supabase
        .from('live_chat_requests')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .listen((data) {
          for (final request in data) {
            if (request['agent_id'] == user.id ||
                request['status'] == 'waiting') {
              onAgentJoined?.call(request);
            }
          }
        }, onError: _handleStreamError);

    // Listen for notifications
    _notificationSubscription = _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .listen((data) {
          for (final notification in data) {
            onNewNotification?.call(notification);
          }
        }, onError: _handleStreamError);
  }

  void _handleStreamError(Object error, [StackTrace? stackTrace]) {
    // Avoid uncaught realtime errors from terminating the app.
    // In web, channel retries are handled by the Supabase client.
    debugPrint('RealtimeService stream error: $error');
  }

  void disconnect() {
    _isConnected = false;
    _messageSubscription?.cancel();
    _requestSubscription?.cancel();
    _notificationSubscription?.cancel();
    _messageSubscription = null;
    _requestSubscription = null;
    _notificationSubscription = null;
    onDisconnected?.call();
  }
}
