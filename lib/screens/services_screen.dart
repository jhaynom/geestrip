import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/chat_service.dart';
import '../services/content_service.dart';

class ServicesScreen extends StatefulWidget {
  final String category;
  const ServicesScreen({super.key, required this.category});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late final Future<List<Map<String, dynamic>>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = _loadServices();
  }

  Future<List<Map<String, dynamic>>> _loadServices() async {
    final entries = await ContentService().fetchServices();
    if (entries.isEmpty) return _getServices();

    final services = entries.map((entry) {
      final metadata = entry['metadata'];
      final gradient = metadata is Map && metadata['gradient'] is List
          ? (metadata['gradient'] as List).map((item) {
              if (item is String) {
                return Color(int.parse(item.replaceFirst('#', '0xFF')));
              }
              if (item is int) {
                return Color(item);
              }
              return const Color(0xFF3B5CF6);
            }).toList()
          : <Color>[const Color(0xFF1F3BB3), const Color(0xFF3B5CF6)];
      return {
        'icon': metadata is Map && metadata['icon'] is String
            ? ContentService().parseIcon(metadata['icon'] as String)
            : LucideIcons.star,
        'title': entry['title'] ?? 'Service',
        'subtitle': entry['subtitle'] ?? '',
        'gradient': gradient,
        'price': metadata is Map ? metadata['price'] : null,
        'tag': metadata is Map ? metadata['tag'] : null,
        'category': metadata is Map && metadata['category'] is String
            ? metadata['category'] as String
            : widget.category,
      };
    }).toList();

    if (widget.category == 'all') return services;
    return services
        .where((service) => service['category'] == widget.category)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
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
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTitle(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            _getSubtitle(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Service cards
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _servicesFuture,
                    builder: (context, snapshot) {
                      final services = snapshot.data ?? _getServices();
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          final gradient = service['gradient'] as List<Color>;
                          final price = service['price'] as String?;
                          final tag = service['tag'] as String?;

                          return GestureDetector(
                            onTap: () {
                              if (service['category'] == 'companion' &&
                                  service['tag'] == 'Browse Free') {
                                context.push('/companion-profiles');
                                return;
                              }
                              context.push(
                                '/service-chat',
                                extra: {
                                  'type': service['category'],
                                  'name': service['title'],
                                },
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: gradient.first.withOpacity(0.25),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      service['icon'] as IconData,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service['title'] as String,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          service['subtitle'] as String,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Price or Tag
                                  if (price != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        price,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  if (tag != null && price == null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        tag,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                  const SizedBox(width: 6),

                                  // Arrow
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      LucideIcons.chevronRight,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                              .moveY(begin: 10);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // Chat FAB
            Positioned(
              bottom: 85,
              right: 20,
              child: GestureDetector(
                onTap: () => context.push('/chat-detail', extra: 0),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1F3BB3).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        LucideIcons.messageCircle,
                        color: Colors.white,
                        size: 26,
                      ),
                      if (ChatService().totalUnread > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${ChatService().totalUnread}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (widget.category) {
      case 'shuttle':
        return 'Shuttle & Transport';
      case 'tours':
        return 'City Tours';
      case 'companion':
        return 'Travel Companion';
      case 'dining':
        return 'Dining Reservations';
      case 'flights':
        return 'Flight Booking';
      default:
        return 'All Services';
    }
  }

  String _getSubtitle() {
    switch (widget.category) {
      case 'shuttle':
        return 'Airport transfers, car rentals & drivers';
      case 'tours':
        return 'Guided tours, group outings & local experiences';
      case 'companion':
        return 'Browse profiles • Pay only when requesting';
      case 'dining':
        return 'Restaurant bookings, food delivery & private chefs';
      case 'flights':
        return 'Best rates across all airlines';
      default:
        return 'Premium travel services';
    }
  }

  List<Map<String, dynamic>> _getServices() {
    final all = [
      // ─── SHUTTLE ───
      {
        'icon': LucideIcons.car,
        'title': 'Car Hiring (Self-Drive)',
        'subtitle': 'Drive yourself • Insurance included',
        'gradient': <Color>[const Color(0xFF1F3BB3), const Color(0xFF3B5CF6)],
        'price': 'From \$45/day',
        'category': 'shuttle',
      },
      {
        'icon': LucideIcons.carTaxiFront,
        'title': 'Car + Driver',
        'subtitle': 'Professional chauffeur • Flexible hours',
        'gradient': <Color>[const Color(0xFF3B5CF6), const Color(0xFF6366F1)],
        'price': 'From \$65/day',
        'category': 'shuttle',
      },
      {
        'icon': LucideIcons.planeLanding,
        'title': 'Airport Transfer',
        'subtitle': 'Flight tracking • Meet & greet',
        'gradient': <Color>[const Color(0xFF6366F1), const Color(0xFF8B9CFE)],
        'price': 'From \$25/trip',
        'category': 'shuttle',
      },

      // ─── TOURS ───
      {
        'icon': LucideIcons.map,
        'title': 'Guided City Tour',
        'subtitle': '4 hours • Local guide • Transport',
        'gradient': <Color>[const Color(0xFF1F3BB3), const Color(0xFF6366F1)],
        'price': 'From \$40/person',
        'category': 'tours',
      },
      {
        'icon': LucideIcons.users,
        'title': 'Group Outings',
        'subtitle': 'Social • Group rates • Curated',
        'gradient': <Color>[const Color(0xFF3B5CF6), const Color(0xFF8B9CFE)],
        'price': 'From \$30/person',
        'category': 'tours',
      },
      {
        'icon': LucideIcons.messageCircle,
        'title': 'Connect with People',
        'subtitle': 'Local hosts • Cultural exchange',
        'gradient': <Color>[const Color(0xFF6366F1), const Color(0xFF3B5CF6)],
        'tag': 'FREE',
        'category': 'tours',
      },

      // ─── COMPANION ───
      {
        'icon': LucideIcons.users,
        'title': 'Event Companion',
        'subtitle': 'Vetted • Professional • Discreet',
        'gradient': <Color>[const Color(0xFF1F3BB3), const Color(0xFF3B5CF6)],
        'tag': 'Browse Free',
        'category': 'companion',
      },
      {
        'icon': LucideIcons.coffee,
        'title': 'Travel Buddy',
        'subtitle': 'Background checked • Local guide',
        'gradient': <Color>[const Color(0xFF3B5CF6), const Color(0xFF6366F1)],
        'tag': 'Browse Free',
        'category': 'companion',
      },
      {
        'icon': LucideIcons.crown,
        'title': 'Special Companion (VIP)',
        'subtitle': 'VIP vetted • Luxury experience',
        'gradient': <Color>[const Color(0xFF6366F1), const Color(0xFF8B9CFE)],
        'tag': 'Premium',
        'category': 'companion',
      },

      // ─── DINING ───
      {
        'icon': LucideIcons.utensilsCrossed,
        'title': 'Restaurant Reservations',
        'subtitle': 'Priority seating • Exclusive spots',
        'gradient': <Color>[const Color(0xFF1F3BB3), const Color(0xFF6366F1)],
        'tag': 'FREE',
        'category': 'dining',
      },
      {
        'icon': LucideIcons.pizza,
        'title': 'Food Ordering',
        'subtitle': 'Fast delivery • Track order',
        'gradient': <Color>[const Color(0xFF3B5CF6), const Color(0xFF8B9CFE)],
        'tag': 'FREE',
        'category': 'dining',
      },
      {
        'icon': LucideIcons.chefHat,
        'title': 'Private Chef',
        'subtitle': 'Custom menu • In-room dining',
        'gradient': <Color>[const Color(0xFF6366F1), const Color(0xFF3B5CF6)],
        'price': 'From \$80/meal',
        'category': 'dining',
      },

      // ─── FLIGHTS ───
      {
        'icon': LucideIcons.plane,
        'title': 'Flight Search',
        'subtitle': 'Best price • All airlines',
        'gradient': <Color>[const Color(0xFF1F3BB3), const Color(0xFF3B5CF6)],
        'tag': 'FREE',
        'category': 'flights',
      },
      {
        'icon': LucideIcons.building2,
        'title': 'Travel Agency Connection',
        'subtitle': 'Full service • Trusted partners',
        'gradient': <Color>[const Color(0xFF3B5CF6), const Color(0xFF6366F1)],
        'tag': 'FREE',
        'category': 'flights',
      },
      {
        'icon': LucideIcons.planeLanding,
        'title': 'Multi-City Booking',
        'subtitle': 'Complex itineraries • Flexible',
        'gradient': <Color>[const Color(0xFF6366F1), const Color(0xFF8B9CFE)],
        'price': 'From \$5',
        'category': 'flights',
      },
    ];

    if (widget.category == 'all') return all;
    return all.where((s) => s['category'] == widget.category).toList();
  }
}
