import 'package:supabase_flutter/supabase_flutter.dart';

class PropertyService {
  static final PropertyService _instance = PropertyService._internal();
  factory PropertyService() => _instance;
  PropertyService._internal();

  final _supabase = Supabase.instance.client;

  static const Map<String, String> _typeMap = {
    'hotels': 'hotel',
    'apartments': 'apartment',
    'resorts': 'resort',
  };

  Future<List<Map<String, dynamic>>> getPropertiesByType(
      String propertyType) async {
    try {
      final type = _typeMap[propertyType] ?? propertyType;
      final response = await _supabase
          .from('properties')
          .select()
          .eq('status', 'active')
          .eq('type', type)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>().map((item) {
        final photos = item['photos'];
        String imageUrl = '';
        if (photos is List && photos.isNotEmpty) {
          imageUrl = photos.first?.toString() ?? '';
        }
        if (imageUrl.isEmpty && item['image'] is String) {
          imageUrl = item['image'] as String;
        }

        return {
          'id': item['id'],
          'name': item['name'] ?? 'Property',
          'location': item['location'] ?? '',
          'rating': item['rating'] ?? 4.5,
          'price': item['price'] ?? item['weekend_price'] ?? 0,
          'image': imageUrl.isNotEmpty
              ? imageUrl
              : 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800&h=500&fit=crop',
          'amenities': item['amenities'] ?? ['WiFi', 'Breakfast'],
          'type': item['type'] ?? type,
          'description': item['description'] ?? item['summary'] ?? '',
          'status': item['status'] ?? 'active',
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
