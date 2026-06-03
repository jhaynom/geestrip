import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContentService {
  static final ContentService _instance = ContentService._internal();
  factory ContentService() => _instance;
  ContentService._internal();

  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchEntries({
    required String section,
    String? slug,
  }) async {
    try {
      final query =
          _supabase.from('cms_entries').select().eq('section', section);
      if (slug != null && slug.isNotEmpty) {
        query.eq('slug', slug);
      }
      final response = await query
          .eq('status', 'active')
          .order('sort_order', ascending: true);
      return _normalizeResponse(response);
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> _normalizeResponse(dynamic response) {
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>?> fetchPage({required String slug}) async {
    final entries = await fetchEntries(section: 'pages', slug: slug);
    if (entries.isEmpty) return null;
    return entries.first;
  }

  final Map<String, Map<String, dynamic>> _serviceOverrides = {};

  Future<List<Map<String, dynamic>>> fetchServices() async {
    final cmsEntries = await fetchEntries(section: 'services');
    return getMergedServiceEntries(cmsEntries);
  }

  List<Map<String, dynamic>> getMergedServiceEntries(
      List<Map<String, dynamic>> cmsEntries) {
    final merged = <String, Map<String, dynamic>>{};

    for (final entry in _defaultServiceEntries) {
      final slug = entry['slug']?.toString();
      if (slug != null && slug.isNotEmpty) {
        merged[slug] = Map<String, dynamic>.from(entry);
      }
    }

    for (final entry in cmsEntries) {
      final slug = entry['slug']?.toString();
      if (slug != null && slug.isNotEmpty) {
        merged[slug] = Map<String, dynamic>.from(entry);
      }
    }

    for (final entry in _serviceOverrides.values) {
      final slug = entry['slug']?.toString();
      if (slug != null && slug.isNotEmpty) {
        merged[slug] = Map<String, dynamic>.from(entry);
      }
    }

    final List<Map<String, dynamic>> combined = [];
    for (final defaultEntry in _defaultServiceEntries) {
      final slug = defaultEntry['slug']?.toString();
      if (slug != null && merged.containsKey(slug)) {
        combined.add(merged.remove(slug)!);
      }
    }
    combined.addAll(merged.values);
    return combined;
  }

  void updateServiceOverride(Map<String, dynamic> entry) {
    final slug = entry['slug']?.toString();
    if (slug == null || slug.isEmpty) return;
    _serviceOverrides[slug] = Map<String, dynamic>.from(entry);
  }

  void removeServiceOverride(String? slug) {
    if (slug == null || slug.isEmpty) return;
    _serviceOverrides.remove(slug);
  }

  static final List<Map<String, dynamic>> _defaultServiceEntries = [
    {
      'section': 'services',
      'slug': 'shuttle-self-drive',
      'title': 'Car Hiring (Self-Drive)',
      'subtitle': 'Drive yourself • Insurance included',
      'body': '',
      'metadata': {
        'price': 'From \$45/day',
        'category': 'shuttle',
        'features': [
          'Self-drive',
          'Insurance included',
          'Flexible pickup',
        ],
        'gradient': ['#1F3BB3', '#3B5CF6'],
        'icon': 'car',
      },
      'status': 'active',
      'sort_order': 0,
    },
    {
      'section': 'services',
      'slug': 'shuttle-driver',
      'title': 'Car + Driver',
      'subtitle': 'Professional chauffeur • Flexible hours',
      'body': '',
      'metadata': {
        'price': 'From \$65/day',
        'category': 'shuttle',
        'features': [
          'Professional driver',
          'Flexible schedule',
          'Door-to-door service',
        ],
        'gradient': ['#3B5CF6', '#6366F1'],
        'icon': 'carTaxiFront',
      },
      'status': 'active',
      'sort_order': 1,
    },
    {
      'section': 'services',
      'slug': 'shuttle-airport-transfer',
      'title': 'Airport Transfer',
      'subtitle': 'Flight tracking • Meet & greet',
      'body': '',
      'metadata': {
        'price': 'From \$25/trip',
        'category': 'shuttle',
        'features': [
          'Flight tracking',
          'Meet & greet',
          'Fixed fare',
        ],
        'gradient': ['#6366F1', '#8B9CFE'],
        'icon': 'planeLanding',
      },
      'status': 'active',
      'sort_order': 2,
    },
    {
      'section': 'services',
      'slug': 'tour-guided-city',
      'title': 'Guided City Tour',
      'subtitle': '4 hours • Local guide • Transport',
      'body': '',
      'metadata': {
        'price': 'From \$40/person',
        'category': 'tours',
        'features': [
          'Local guide',
          'Transport included',
          'Small groups',
        ],
        'gradient': ['#1F3BB3', '#6366F1'],
        'icon': 'map',
      },
      'status': 'active',
      'sort_order': 3,
    },
    {
      'section': 'services',
      'slug': 'tour-group-outings',
      'title': 'Group Outings',
      'subtitle': 'Social • Group rates • Curated',
      'body': '',
      'metadata': {
        'price': 'From \$30/person',
        'category': 'tours',
        'features': [
          'Group discounts',
          'Curated itinerary',
          'Local experiences',
        ],
        'gradient': ['#3B5CF6', '#8B9CFE'],
        'icon': 'users',
      },
      'status': 'active',
      'sort_order': 4,
    },
    {
      'section': 'services',
      'slug': 'tour-cultural-connection',
      'title': 'Connect with People',
      'subtitle': 'Local hosts • Cultural exchange',
      'body': '',
      'metadata': {
        'price': 'FREE',
        'category': 'tours',
        'features': [
          'Community hosts',
          'Cultural exchange',
          'Free browsing',
        ],
        'gradient': ['#6366F1', '#3B5CF6'],
        'icon': 'users',
      },
      'status': 'active',
      'sort_order': 5,
    },
    {
      'section': 'services',
      'slug': 'companion-event',
      'title': 'Event Companion',
      'subtitle': 'Vetted • Professional • Discreet',
      'body': '',
      'metadata': {
        'price': 'Browse Free',
        'category': 'companion',
        'features': [
          'Vetted profiles',
          'Discreet support',
          'Event readiness',
        ],
        'gradient': ['#1F3BB3', '#3B5CF6'],
        'icon': 'users',
      },
      'status': 'active',
      'sort_order': 6,
    },
    {
      'section': 'services',
      'slug': 'companion-travel-buddy',
      'title': 'Travel Buddy',
      'subtitle': 'Background checked • Local guide',
      'body': '',
      'metadata': {
        'price': 'Browse Free',
        'category': 'companion',
        'features': [
          'Local guide',
          'Background checked',
          'Flexible support',
        ],
        'gradient': ['#3B5CF6', '#6366F1'],
        'icon': 'coffee',
      },
      'status': 'active',
      'sort_order': 7,
    },
    {
      'section': 'services',
      'slug': 'companion-vip',
      'title': 'Special Companion (VIP)',
      'subtitle': 'VIP vetted • Luxury experience',
      'body': '',
      'metadata': {
        'price': 'Premium',
        'category': 'companion',
        'features': [
          'VIP service',
          'Luxury experience',
          'Premium support',
        ],
        'gradient': ['#6366F1', '#8B9CFE'],
        'icon': 'crown',
      },
      'status': 'active',
      'sort_order': 8,
    },
    {
      'section': 'services',
      'slug': 'dining-reservations',
      'title': 'Restaurant Reservations',
      'subtitle': 'Priority seating • Exclusive spots',
      'body': '',
      'metadata': {
        'price': 'FREE',
        'category': 'dining',
        'features': [
          'Priority seating',
          'Exclusive spots',
          'Special requests',
        ],
        'gradient': ['#1F3BB3', '#6366F1'],
        'icon': 'utensilsCrossed',
      },
      'status': 'active',
      'sort_order': 9,
    },
    {
      'section': 'services',
      'slug': 'dining-food-ordering',
      'title': 'Food Ordering',
      'subtitle': 'Fast delivery • Track order',
      'body': '',
      'metadata': {
        'price': 'FREE',
        'category': 'dining',
        'features': [
          'Fast delivery',
          'Order tracking',
          'Local restaurants',
        ],
        'gradient': ['#3B5CF6', '#8B9CFE'],
        'icon': 'pizza',
      },
      'status': 'active',
      'sort_order': 10,
    },
    {
      'section': 'services',
      'slug': 'dining-private-chef',
      'title': 'Private Chef',
      'subtitle': 'Custom menu • In-room dining',
      'body': '',
      'metadata': {
        'price': 'From \$80/meal',
        'category': 'dining',
        'features': [
          'Custom menu',
          'In-room dining',
          'Professional chef',
        ],
        'gradient': ['#6366F1', '#3B5CF6'],
        'icon': 'chefHat',
      },
      'status': 'active',
      'sort_order': 11,
    },
    {
      'section': 'services',
      'slug': 'flight-search',
      'title': 'Flight Search',
      'subtitle': 'Best price • All airlines',
      'body': '',
      'metadata': {
        'price': 'FREE',
        'category': 'flights',
        'features': [
          'Best price',
          'All airlines',
          'Flexible dates',
        ],
        'gradient': ['#1F3BB3', '#3B5CF6'],
        'icon': 'plane',
      },
      'status': 'active',
      'sort_order': 12,
    },
    {
      'section': 'services',
      'slug': 'flight-agency-connection',
      'title': 'Travel Agency Connection',
      'subtitle': 'Full service • Trusted partners',
      'body': '',
      'metadata': {
        'price': 'FREE',
        'category': 'flights',
        'features': [
          'Trusted partners',
          'Full service',
          'Route planning',
        ],
        'gradient': ['#3B5CF6', '#6366F1'],
        'icon': 'building2',
      },
      'status': 'active',
      'sort_order': 13,
    },
    {
      'section': 'services',
      'slug': 'flight-multi-city',
      'title': 'Multi-City Booking',
      'subtitle': 'Complex itineraries • Flexible',
      'body': '',
      'metadata': {
        'price': 'From \$5',
        'category': 'flights',
        'features': [
          'Multi-city',
          'Flexible routing',
          'Expert support',
        ],
        'gradient': ['#6366F1', '#8B9CFE'],
        'icon': 'planeLanding',
      },
      'status': 'active',
      'sort_order': 14,
    },
  ];

  Future<List<Map<String, dynamic>>> fetchCompanions() async {
    return fetchEntries(section: 'companions');
  }

  Future<List<Map<String, dynamic>>> fetchDrivers() async {
    return fetchEntries(section: 'drivers');
  }

  Future<List<Map<String, dynamic>>> fetchFaqs() async {
    return fetchEntries(section: 'faq');
  }

  Color getColor(String value) {
    switch (value.toLowerCase()) {
      case 'blue':
        return const Color(0xFF1F3BB3);
      case 'purple':
        return const Color(0xFF6366F1);
      case 'pink':
        return const Color(0xFFEC4899);
      case 'green':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF3B5CF6);
    }
  }

  List<Color> parseGradient(dynamic gradientData) {
    if (gradientData is String) {
      try {
        final decoded = jsonDecode(gradientData) as List<dynamic>;
        return decoded
            .map((item) =>
                Color(int.parse(item.toString().replaceFirst('#', '0xFF'))))
            .toList();
      } catch (_) {
        return const [Color(0xFF1F3BB3), Color(0xFF3B5CF6)];
      }
    }
    if (gradientData is List) {
      return gradientData.map<Color>((item) {
        if (item is String) {
          return Color(int.parse(item.replaceFirst('#', '0xFF')));
        }
        if (item is int) {
          return Color(item);
        }
        return const Color(0xFF3B5CF6);
      }).toList();
    }
    return const [Color(0xFF1F3BB3), Color(0xFF3B5CF6)];
  }

  IconData parseIcon(String? iconName) {
    switch (iconName) {
      case 'car':
        return Icons.directions_car;
      case 'carTaxiFront':
        return Icons.local_taxi;
      case 'plane':
        return Icons.flight;
      case 'planeLanding':
        return Icons.flight_land;
      case 'map':
        return Icons.map;
      case 'utensils':
      case 'utensilsCrossed':
        return Icons.restaurant;
      case 'pizza':
        return Icons.local_pizza;
      case 'chefHat':
        return Icons.restaurant_menu;
      case 'flame':
        return Icons.local_fire_department;
      case 'fish':
        return Icons.set_meal;
      case 'camera':
        return Icons.camera_alt;
      case 'globe':
        return Icons.public;
      case 'backpack':
        return Icons.backpack;
      case 'users':
        return Icons.people;
      case 'crown':
        return Icons.workspace_premium;
      case 'coffee':
        return Icons.coffee;
      default:
        return Icons.star;
    }
  }
}
