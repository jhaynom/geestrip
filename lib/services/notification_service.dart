import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _supabase = Supabase.instance.client;
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _notifications.clear();
      return;
    }

    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(20);

      _notifications.clear();
      for (final n in (response as List)) {
        _notifications.add(NotificationItem(
          title: n['title'] as String? ?? '',
          message: n['message'] as String? ?? '',
          time: _formatTime(n['created_at'] as String?),
          icon: _getIcon(n['title'] as String? ?? ''),
          color: _getColor(n['title'] as String? ?? ''),
          isRead: n['is_read'] as bool? ?? false,
        ));
      }
    } catch (e) {}
  }

  void addNotification(NotificationItem item) {
    _notifications.insert(0, item);
  }

  Future<void> markAllRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      _notifications[i] = NotificationItem(
        title: n.title,
        message: n.message,
        time: n.time,
        icon: n.icon,
        color: n.color,
        isRead: true,
      );
    }

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true}).eq('user_id', user.id);
    } catch (e) {
      // Silent fail
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hours ago';
      return '${diff.inDays} days ago';
    } catch (e) {
      return '';
    }
  }

  IconData _getIcon(String title) {
    if (title.contains('Book')) return LucideIcons.building2;
    if (title.contains('Guardian') || title.contains('Protect'))
      return LucideIcons.shield;
    if (title.contains('Shuttle') || title.contains('Ride'))
      return LucideIcons.car;
    if (title.contains('Check-in') || title.contains('Reminder'))
      return LucideIcons.calendarCheck;
    if (title.contains('Offer') || title.contains('Discount'))
      return LucideIcons.tag;
    return LucideIcons.bell;
  }

  Color _getColor(String title) {
    if (title.contains('Book')) return AppColors.primary;
    if (title.contains('Guardian') || title.contains('Protect'))
      return AppColors.success;
    if (title.contains('Shuttle') || title.contains('Ride'))
      return AppColors.accentGold;
    if (title.contains('Check-in') || title.contains('Reminder'))
      return AppColors.primaryLight;
    if (title.contains('Offer') || title.contains('Discount'))
      return AppColors.error;
    return AppColors.primary;
  }
}
