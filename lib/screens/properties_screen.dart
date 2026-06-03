import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/chat_service.dart';
import '../services/property_service.dart';

class PropertiesScreen extends StatefulWidget {
  final String propertyType;
  const PropertiesScreen({super.key, required this.propertyType});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  late final Future<List<Map<String, dynamic>>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    _propertiesFuture = PropertyService().getPropertiesByType(widget.propertyType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _propertiesFuture,
          builder: (context, snapshot) {
            final properties = snapshot.data;
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.bgWhite,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                LucideIcons.arrowLeft,
                                size: 22,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _getTitle(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.bgWhite,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.slidersHorizontal,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        itemCount: properties?.length ?? _getProperties().length,
                        itemBuilder: (context, index) {
                          final property = properties != null && properties.isNotEmpty
                              ? properties[index]
                              : _getProperties()[index];

                          return GestureDetector(
                            onTap: () => context.push('/property-detail', extra: property),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.bgWhite,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 16,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                        child: Image.network(
                                          property['image'] as String,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(LucideIcons.shieldCheck, color: Colors.white, size: 12),
                                              SizedBox(width: 4),
                                              Text('Verified', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(LucideIcons.heart, color: AppColors.error, size: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                property['name'] as String,
                                                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                              ),
                                            ),
                                            Row(children: [
                                              const Icon(LucideIcons.star, color: AppColors.accentGold, size: 16, fill: 1.0),
                                              const SizedBox(width: 3),
                                              Text('${property['rating']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                            ]),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(children: [
                                          const Icon(LucideIcons.mapPin, size: 14, color: AppColors.textMuted),
                                          const SizedBox(width: 3),
                                          Text(property['location'] as String, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                                        ]),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: (property['amenities'] as List<String>)
                                              .take(4)
                                              .map(
                                                (a) => Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(color: AppColors.accentBlueLight, borderRadius: BorderRadius.circular(8)),
                                                  child: Text(a, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '\$${property['price']}',
                                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary),
                                                ),
                                                const SizedBox(width: 3),
                                                const Padding(
                                                  padding: EdgeInsets.only(bottom: 2),
                                                  child: Text('/ night', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Text('View Details', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 300.ms, delay: (60 * index).ms).moveY(begin: 15);
                        },
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 85,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => context.push('/chat-detail', extra: 0),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(LucideIcons.messageCircle, color: Colors.white, size: 26),
                          if (ChatService().totalUnread > 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                                child: Center(
                                  child: Text('${ChatService().totalUnread}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getTitle() {
    switch (widget.propertyType) {
      case 'hotels':
        return 'Hotels';
      case 'apartments':
        return 'Apartments & Shortlets';
      case 'resorts':
        return 'Resorts & Villas';
      default:
        return 'Properties';
    }
  }

  List<Map<String, dynamic>> _getProperties() {
    if (widget.propertyType == 'hotels') {
      return [
        {
          'name': 'Serenity Suites',
          'location': 'Victoria Island, Lagos',
          'rating': 4.8,
          'price': 120,
          'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&h=500&fit=crop',
          'amenities': ['Pool', 'Gym', 'Spa', 'Restaurant'],
          'type': 'hotel',
        },
        {
          'name': 'The Urban Haven',
          'location': 'Maitama, Abuja',
          'rating': 4.6,
          'price': 95,
          'image': 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&h=500&fit=crop',
          'amenities': ['Workspace', 'Meeting Room', 'Shuttle'],
          'type': 'hotel',
        },
        {
          'name': 'Palm Grove Hotel',
          'location': 'Airport City, Accra',
          'rating': 4.5,
          'price': 140,
          'image': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&h=500&fit=crop',
          'amenities': ['Pool', 'Bar', 'Shuttle'],
          'type': 'hotel',
        },
        {
          'name': 'Royal Continental',
          'location': 'Ikoyi, Lagos',
          'rating': 4.7,
          'price': 200,
          'image': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&h=500&fit=crop',
          'amenities': ['Pool', 'Spa', 'Fine Dining', 'Concierge'],
          'type': 'hotel',
        },
      ];
    } else if (widget.propertyType == 'apartments') {
      return [
        {
          'name': 'Skyline Apartments',
          'location': 'Lekki Phase 1, Lagos',
          'rating': 4.7,
          'price': 85,
          'image': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=500&fit=crop',
          'amenities': ['Kitchen', 'WiFi', 'Parking', 'Security'],
          'type': 'apartment',
        },
        {
          'name': 'The Executive Pad',
          'location': 'Wuse II, Abuja',
          'rating': 4.5,
          'price': 110,
          'image': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&h=500&fit=crop',
          'amenities': ['Full Kitchen', 'Workspace', 'Gym'],
          'type': 'apartment',
        },
      ];
    } else {
      return [
        {
          'name': 'Oceanview Resort',
          'location': 'Tarkwa Bay, Lagos',
          'rating': 4.9,
          'price': 350,
          'image': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&h=500&fit=crop',
          'amenities': ['Beach Access', 'Pool', 'Spa', 'Restaurant'],
          'type': 'resort',
        },
        {
          'name': 'Mountain Retreat',
          'location': 'Obudu, Cross River',
          'rating': 4.6,
          'price': 250,
          'image': 'https://images.unsplash.com/photo-1602002418082-a4443e081dd1?w=800&h=500&fit=crop',
          'amenities': ['Hiking', 'Spa', 'Fireplace', 'All-Inclusive'],
          'type': 'resort',
        },
      ];
    }
  }
}
