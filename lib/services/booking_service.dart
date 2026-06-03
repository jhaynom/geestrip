import 'package:supabase_flutter/supabase_flutter.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _bookings = [];

  List<Map<String, dynamic>> get bookings => List.unmodifiable(_bookings);

  List<Map<String, dynamic>> getByStatus(String status) {
    if (status == 'all') return bookings;
    return bookings.where((b) => b['status'] == status).toList();
  }

  int get totalBookings => _bookings.length;
  double get averageRating => 0.0;

  Future<void> loadBookings() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print('[BookingService] No authenticated user found');
      _bookings = [];
      return;
    }

    try {
      print('[BookingService] Loading bookings for user: ${user.id}');
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _bookings = (response as List)
          .map((b) => {
                'id': b['reference'] ?? 'GEE-${b['id']}',
                'type': b['service_type'] ?? 'service',
                'name': b['service_name'] ?? 'Booking',
                'detail': b['detail'] ?? '',
                'price': b['price'] ?? '',
                'status': b['status'] ?? 'confirmed',
                'date': b['created_at']?.toString().substring(0, 16) ?? '',
              })
          .toList();

      print('[BookingService] Loaded ${_bookings.length} bookings');
    } catch (e) {
      print('[BookingService] Error loading bookings: $e');
      _bookings = [];
    }
  }

  Future<void> addBooking(Map<String, dynamic> booking) async {
    final user = _supabase.auth.currentUser;
    final status = booking['status'] as String? ?? 'confirmed';

    if (user == null) {
      // Fallback: add locally for guest users
      print('[BookingService] Guest user - adding booking locally');
      _bookings.insert(0, {
        ...booking,
        'id':
            'GEE-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        'status': status,
        'date': DateTime.now().toString().substring(0, 16),
      });
      print('[BookingService] Booking added locally for guest');
      return;
    }

    final reference =
        'GEE-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    try {
      print('[BookingService] Creating booking for user: ${user.id}');
      print(
          '[BookingService] Booking details: ${booking['name']} - ${booking['price']}');

      final result = await _supabase.from('bookings').insert({
        'user_id': user.id,
        'service_type': booking['type'] ?? 'service',
        'service_name': booking['name'] ?? '',
        'detail': booking['detail'] ?? '',
        'price': booking['price'] ?? '',
        'status': status,
        'reference': reference,
        'contact_method': booking['contact_method'] ?? null,
        'contact_value': booking['contact_value'] ?? null,
      }).select();

      print('[BookingService] Booking saved to Supabase: $result');

      // Add to local list
      _bookings.insert(0, {
        ...booking,
        'id': reference,
        'status': status,
        'date': DateTime.now().toString().substring(0, 16),
      });

      print(
          '[BookingService] Booking added to local list. Total bookings: ${_bookings.length}');
    } catch (e) {
      print('[BookingService] Error saving booking to Supabase: $e');
      // Fallback: add locally
      _bookings.insert(0, {
        ...booking,
        'id': reference,
        'status': status,
        'date': DateTime.now().toString().substring(0, 16),
      });
      print('[BookingService] Booking added locally (fallback)');
    }
  }

  Future<void> cancelBooking(String id) async {
    try {
      print('[BookingService] Canceling booking: $id');
      final index = _bookings.indexWhere((b) => b['id'] == id);
      if (index != -1) {
        _bookings[index]['status'] = 'cancelled';
      }

      await _supabase
          .from('bookings')
          .update({'status': 'cancelled'}).eq('reference', id);

      print('[BookingService] Booking cancelled successfully');
    } catch (e) {
      print('[BookingService] Error canceling booking: $e');
    }
  }
}
