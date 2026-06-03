import 'package:supabase_flutter/supabase_flutter.dart';

class PartnerService {
  static final PartnerService _instance = PartnerService._internal();
  factory PartnerService() => _instance;
  PartnerService._internal();

  final _supabase = Supabase.instance.client;

  bool _isPartner = false;
  String _partnerName = '';
  String _partnerEmail = '';
  String _partnerPhone = '';

  bool get isPartner => _isPartner;
  String get partnerName => _partnerName;
  String get partnerEmail => _partnerEmail;
  String get partnerPhone => _partnerPhone;

  final List<Map<String, dynamic>> _myProperties = [];

  List<Map<String, dynamic>> get myProperties =>
      List.unmodifiable(_myProperties);

  List<Map<String, dynamic>> get activeProperties =>
      _myProperties.where((p) => p['status'] == 'active').toList();

  List<Map<String, dynamic>> get pendingProperties =>
      _myProperties.where((p) => p['status'] == 'pending').toList();

  int get totalViews =>
      _myProperties.fold(0, (sum, p) => sum + (p['views'] as int? ?? 0));
  int get totalBookings =>
      _myProperties.fold(0, (sum, p) => sum + (p['bookings'] as int? ?? 0));

  Future<void> loadProperties() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _myProperties.clear();
      return;
    }

    try {
      final response = await _supabase
          .from('properties')
          .select()
          .eq('owner_id', user.id)
          .order('created_at', ascending: false);

      _myProperties.clear();
      for (final p in (response as List)) {
        _myProperties.add({
          'name': p['name'] ?? '',
          'type': p['type'] ?? 'hotel',
          'location': p['location'] ?? '',
          'description': p['description'] ?? '',
          'price': p['price'] ?? 0,
          'rooms': p['rooms'] ?? 1,
          'amenities': p['amenities'] ?? [],
          'photos': p['photos'] ?? [],
          'status': p['status'] ?? 'pending',
          'views': p['views'] ?? 0,
          'bookings': p['bookings'] ?? 0,
          'rating': p['rating'] ?? 0.0,
          'reviews': p['reviews_count'] ?? 0,
          'submittedAt': p['created_at']?.toString().substring(0, 16) ?? '',
        });
        _isPartner = true;
        _partnerName =
            user.userMetadata?['full_name'] as String? ?? user.email ?? '';
        _partnerEmail = user.email ?? '';
      }
    } catch (e) {}
  }

  void registerPartner({
    required String name,
    required String email,
    required String phone,
  }) {
    _isPartner = true;
    _partnerName = name;
    _partnerEmail = email;
    _partnerPhone = phone;
  }

  Future<void> addProperty(Map<String, dynamic> property) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Add locally immediately
    _myProperties.insert(0, {
      'name': property['name'] ?? '',
      'type': property['type'] ?? 'hotel',
      'location': property['location'] ?? '',
      'description': property['description'] ?? '',
      'price': property['price'] ?? 0,
      'rooms': property['rooms'] ?? 1,
      'amenities': property['amenities'] ?? [],
      'photos': property['photos'] ?? [],
      'status': 'pending',
      'views': 0,
      'bookings': 0,
      'rating': 0.0,
      'reviews': 0,
      'submittedAt': DateTime.now().toString().substring(0, 16),
    });

    // Save to Supabase
    try {
      await _supabase.from('properties').insert({
        'owner_id': user.id,
        'name': property['name'] ?? '',
        'type': property['type'] ?? 'hotel',
        'location': property['location'] ?? '',
        'description': property['description'] ?? '',
        'price': property['price'] ?? 0,
        'weekend_price': property['weekendPrice'] ?? 0,
        'rooms': property['rooms'] ?? 1,
        'currency': property['currency'] ?? 'USD',
        'amenities': property['amenities'] ?? [],
        'photos': property['photos'] ?? [],
        'ota_links': property['otaLinks'] ?? {},
        'status': 'pending',
      });
    } catch (e) {
      // Already saved locally
    }
  }
}
