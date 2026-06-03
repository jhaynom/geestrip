import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../widgets/contact_method_selector.dart';
import '../services/booking_service.dart';
import '../services/content_service.dart';

class ServiceResultsScreen extends StatefulWidget {
  final String serviceType;
  final Map<String, String> answers;
  const ServiceResultsScreen(
      {super.key, required this.serviceType, required this.answers});

  @override
  State<ServiceResultsScreen> createState() => _ServiceResultsScreenState();
}

class _ServiceResultsScreenState extends State<ServiceResultsScreen> {
  late final Future<List<Map<String, dynamic>>> _resultItemsFuture;

  @override
  void initState() {
    super.initState();
    _resultItemsFuture = _loadResults();
  }

  Future<List<Map<String, dynamic>>> _loadResults() async {
    if (widget.serviceType == 'shuttle') {
      final entries = await ContentService().fetchDrivers();
      return entries.map((entry) {
        final metadata = entry['metadata'];
        return {
          'name': entry['title'] ?? 'Car Service',
          'detail': entry['subtitle'] ??
              (metadata is Map ? metadata['detail'] ?? '' : ''),
          'price': metadata is Map ? metadata['price'] ?? '\$25-35' : '\$25-35',
          'eta': metadata is Map ? metadata['eta'] ?? '5-10 min' : '5-10 min',
          'icon': metadata is Map && metadata['icon'] is String
              ? ContentService().parseIcon(metadata['icon'] as String)
              : LucideIcons.car,
          'color': metadata is Map && metadata['color'] is String
              ? Color(int.parse(
                  (metadata['color'] as String).replaceFirst('#', '0xFF')))
              : const Color(0xFF1F3BB3),
        };
      }).toList();
    }

    if (widget.serviceType == 'companion') {
      final entries = await ContentService().fetchCompanions();
      return entries.map((entry) {
        final metadata = entry['metadata'];
        return {
          'name': entry['title'] ?? 'Companion',
          'age': metadata is Map ? metadata['age'] ?? 0 : 0,
          'languages': metadata is Map ? metadata['languages'] ?? '' : '',
          'rating': entry['subtitle'] ?? '4.8',
          'price': metadata is Map ? metadata['price'] ?? '\$75/hr' : '\$75/hr',
          'gender': metadata is Map ? metadata['gender'] ?? 'all' : 'all',
          'bio': entry['body'] ?? '',
          'interests': metadata is Map ? metadata['interests'] ?? '' : '',
          'location': entry['subtitle'] ??
              (metadata is Map ? metadata['location'] ?? '' : ''),
        };
      }).toList();
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              decoration: BoxDecoration(color: AppColors.bgWhite, boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
              ]),
              child: Row(children: [
                GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: AppColors.bgPrimary,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(LucideIcons.arrowLeft,
                            size: 22, color: AppColors.textSecondary))),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(_getTitle(),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      Text(_getSubtitle(),
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500)),
                    ])),
              ]),
            ),
            // Results
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _resultItemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary));
                  }
                  final results = snapshot.data ?? [];
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.serviceType == 'shuttle')
                            ..._buildShuttleResults(results),
                          if (widget.serviceType == 'tours')
                            ..._buildToursResults(),
                          if (widget.serviceType == 'companion')
                            ..._buildCompanionResults(results),
                          if (widget.serviceType == 'dining')
                            ..._buildDiningResults(),
                          if (widget.serviceType == 'flights')
                            ..._buildFlightsResults(),
                        ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (widget.serviceType) {
      case 'shuttle':
        return 'Available Cars';
      case 'tours':
        return 'Available Tours';
      case 'companion':
        return 'Verified Companions';
      case 'dining':
        return 'Restaurant Reservations';
      case 'flights':
        return 'Flight Options';
      default:
        return 'Results';
    }
  }

  String _getSubtitle() {
    switch (widget.serviceType) {
      case 'shuttle':
        return '${widget.answers['pickup'] ?? ''} → ${widget.answers['dropoff'] ?? ''}';
      case 'tours':
        return widget.answers['city'] ?? 'Browse all tours';
      case 'companion':
        return 'Filtered by your preferences';
      case 'dining':
        return '${widget.answers['cuisine'] ?? 'All'} cuisine in ${widget.answers['city'] ?? 'your city'}';
      case 'flights':
        return '${widget.answers['from'] ?? ''} → ${widget.answers['to'] ?? ''}';
      default:
        return '';
    }
  }

  // ─── SHUTTLE ───
  List<Widget> _buildShuttleResults([List<Map<String, dynamic>>? cars]) {
    cars = (cars != null && cars.isNotEmpty)
        ? cars
        : [
            {
              'name': 'Executive Sedan',
              'detail': 'Toyota Camry • Up to 3 passengers • AC',
              'price': '\$25-35',
              'eta': '5-10 min',
              'icon': LucideIcons.car,
              'color': const Color(0xFF1F3BB3)
            },
            {
              'name': 'Premium SUV',
              'detail': 'Toyota Prado • Up to 5 passengers • Leather',
              'price': '\$40-60',
              'eta': '3-8 min',
              'icon': LucideIcons.carTaxiFront,
              'color': const Color(0xFFEA580C)
            },
            {
              'name': 'Luxury Van',
              'detail': 'Mercedes V-Class • Up to 7 passengers • WiFi',
              'price': '\$60-90',
              'eta': '5-12 min',
              'icon': LucideIcons.truck,
              'color': const Color(0xFF059669)
            },
          ];

    return [
      const Text('Choose Your Ride',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text('All drivers are verified. Exact fare confirmed before dispatch.',
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
      const SizedBox(height: 16),
      ...cars.map((car) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 10)
                ]),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: (car['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14)),
                    child: Icon(car['icon'] as IconData,
                        color: car['color'] as Color, size: 24)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(car['name'] as String,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      Text(car['detail'] as String,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted))
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(car['price'] as String,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  Text('Est. fare',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textMuted))
                ]),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.accentGreenLight,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(LucideIcons.clock,
                          size: 12, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(car['eta'] as String,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600))
                    ])),
                const Spacer(),
                GestureDetector(
                  onTap: () => _bookService(car),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Text('Select & Pay \$2',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600))),
                ),
              ]),
            ]),
          ).animate().fadeIn(duration: 300.ms).moveY(begin: 10)),
    ];
  }

  // ─── TOURS (FREE + optional $2 booking) ───
  List<Widget> _buildToursResults() {
    final tours = [
      {
        'name': 'City Heritage Tour',
        'detail': '4 hours • Historical landmarks • Guide included',
        'price': '\$35/person',
        'icon': LucideIcons.map,
        'color': const Color(0xFF059669)
      },
      {
        'name': 'Food & Market Tour',
        'detail': '3 hours • Local cuisine tasting • 5 stops',
        'price': '\$45/person',
        'icon': LucideIcons.utensilsCrossed,
        'color': const Color(0xFFDC2626)
      },
      {
        'name': 'Photography Tour',
        'detail': '5 hours • Instagram spots • Pro photographer',
        'price': '\$55/person',
        'icon': LucideIcons.camera,
        'color': const Color(0xFF7C3AED)
      },
    ];

    return [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Available Tours',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.accentGreenLight,
                borderRadius: BorderRadius.circular(10)),
            child: const Text('FREE to browse',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success))),
      ]),
      const SizedBox(height: 4),
      const Text('Book yourself for free, or we\'ll handle it for \$2',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
      const SizedBox(height: 16),
      ...tours.map((tour) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 10)
                ]),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: (tour['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14)),
                    child: Icon(tour['icon'] as IconData,
                        color: tour['color'] as Color, size: 24)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(tour['name'] as String,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      Text(tour['detail'] as String,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted))
                    ])),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Text(tour['price'] as String,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _bookService(tour),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                          color: AppColors.bgPrimary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary)),
                      child: const Text('Book for Me \$2',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600))),
                ),
              ]),
            ]),
          ).animate().fadeIn(duration: 300.ms).moveY(begin: 10)),
    ];
  }

  // ─── COMPANION ───
  List<Widget> _buildCompanionResults(
      [List<Map<String, dynamic>>? companions]) {
    final genderPreference = widget.answers['type']?.toLowerCase() ?? '';
    final allCompanions = (companions != null && companions.isNotEmpty)
        ? companions
        : [
            {
              'name': 'Amara O.',
              'age': 28,
              'languages': 'English, French',
              'rating': '4.9',
              'price': '\$80/hr',
              'gender': 'female',
              'bio':
                  'Event companion with 5 years experience in hosting and event coordination.',
              'interests': 'Arts, Travel, Photography'
            },
            {
              'name': 'Chioma E.',
              'age': 26,
              'languages': 'English, Igbo',
              'rating': '4.7',
              'price': '\$85/hr',
              'gender': 'female',
              'bio':
                  'Fine dining and conversation specialist. Loves culinary experiences.',
              'interests': 'Food, Culture, Museums'
            },
            {
              'name': 'David K.',
              'age': 30,
              'languages': 'English, Swahili',
              'rating': '4.8',
              'price': '\$70/hr',
              'gender': 'male',
              'bio': 'Travel buddy and local guide. Enjoys outdoor activities.',
              'interests': 'Hiking, Music, Sports'
            },
            {
              'name': 'Michael T.',
              'age': 32,
              'languages': 'English, French',
              'rating': '4.9',
              'price': '\$90/hr',
              'gender': 'male',
              'bio': 'Experienced in corporate events and business networking.',
              'interests': 'Business, Networking'
            },
            {
              'name': 'Sarah J.',
              'age': 27,
              'languages': 'English',
              'rating': '5.0',
              'price': '\$95/hr',
              'gender': 'female',
              'bio':
                  'Wedding and special event companion with exceptional presentation.',
              'interests': 'Events, Fashion'
            },
          ];

    final filteredCompanions = genderPreference.contains('male')
        ? allCompanions.where((c) => c['gender'] == 'male').toList()
        : genderPreference.contains('female')
            ? allCompanions.where((c) => c['gender'] == 'female').toList()
            : allCompanions;

    return [
      const Text('Verified Companions',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text('${filteredCompanions.length} companions matching your preferences',
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
      const SizedBox(height: 16),
      ...filteredCompanions.map((c) => GestureDetector(
            onTap: () => _showCompanionDetails(c),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 10)
                  ]),
              child: Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFBE185D), Color(0xFFEC4899)]),
                        borderRadius: BorderRadius.circular(14)),
                    child: Center(
                        child: Text((c['name'] as String)[0],
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)))),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(children: [
                        Text(c['name'] as String,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const SizedBox(width: 6),
                        const Icon(LucideIcons.shieldCheck,
                            color: AppColors.success, size: 14)
                      ]),
                      Text('${c['languages'] ?? ''} • ${c['age'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                      Row(children: [
                        const Icon(LucideIcons.star,
                            color: AppColors.accentGold, size: 14, fill: 1.0),
                        const SizedBox(width: 4),
                        Text(c['rating'] as String,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600))
                      ]),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(c['price'] as String,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const SizedBox(height: 6),
                  GestureDetector(
                      onTap: () => _showContactMethodDialog(c),
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                              color: const Color(0xFFBE185D),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Text('Request Introduction',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600))))
                ]),
              ]),
            ),
          ).animate().fadeIn(duration: 300.ms).moveY(begin: 10)),
    ];
  }

  // ─── DINING (FREE + optional $2) ───
  List<Widget> _buildDiningResults() {
    final restaurants = [
      {
        'name': 'The Skyline Restaurant',
        'detail': 'Rooftop • Continental • Victoria Island',
        'rating': '4.8',
        'price': '\$\$\$',
        'icon': LucideIcons.utensilsCrossed,
        'color': const Color(0xFFDC2626)
      },
      {
        'name': 'Ocean Blue Grill',
        'detail': 'Seafood • Beachfront • Lekki',
        'rating': '4.7',
        'price': '\$\$',
        'icon': LucideIcons.fish,
        'color': const Color(0xFF2563EB)
      },
      {
        'name': 'Spice Garden',
        'detail': 'African • Authentic • Wuse II',
        'rating': '4.9',
        'price': '\$\$',
        'icon': LucideIcons.flame,
        'color': const Color(0xFFEA580C)
      },
    ];

    return [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Restaurants',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.accentGreenLight,
                borderRadius: BorderRadius.circular(10)),
            child: const Text('FREE to browse',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success))),
      ]),
      const SizedBox(height: 4),
      const Text('Reserve yourself for free, or we\'ll handle it for \$2',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
      const SizedBox(height: 16),
      ...restaurants.map((r) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 10)
                ]),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: (r['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14)),
                    child: Icon(r['icon'] as IconData,
                        color: r['color'] as Color, size: 24)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(r['name'] as String,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      Text(r['detail'] as String,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted))
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Row(children: [
                    const Icon(LucideIcons.star,
                        color: AppColors.accentGold, size: 14, fill: 1.0),
                    const SizedBox(width: 3),
                    Text(r['rating'] as String,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700))
                  ]),
                  Text(r['price'] as String,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary))
                ]),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                const Spacer(),
                GestureDetector(
                    onTap: () => _bookService(r),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                            color: AppColors.bgPrimary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primary)),
                        child: const Text('Reserve for Me \$2',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)))),
              ]),
            ]),
          ).animate().fadeIn(duration: 300.ms).moveY(begin: 10)),
    ];
  }

  // ─── FLIGHTS (FREE + optional $5) ───
  List<Widget> _buildFlightsResults() {
    final flights = [
      {
        'name': 'Air Peace',
        'detail': 'Direct • 1h 15m • Lagos → Abuja',
        'rating': '4.5',
        'price': '\$120-180',
        'icon': LucideIcons.plane,
        'color': const Color(0xFF2563EB)
      },
      {
        'name': 'Arik Air',
        'detail': 'Direct • 1h 20m • Lagos → Abuja',
        'rating': '4.3',
        'price': '\$100-160',
        'icon': LucideIcons.plane,
        'color': const Color(0xFF0891B2)
      },
      {
        'name': 'Ibom Air',
        'detail': 'Direct • 1h 10m • Lagos → Abuja',
        'rating': '4.6',
        'price': '\$130-200',
        'icon': LucideIcons.plane,
        'color': const Color(0xFF7C3AED)
      },
    ];

    return [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Flight Options',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.accentGreenLight,
                borderRadius: BorderRadius.circular(10)),
            child: const Text('FREE to browse',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success))),
      ]),
      const SizedBox(height: 4),
      const Text('Book yourself or let us handle it for \$5',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
      const SizedBox(height: 16),
      ...flights.map((f) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 10)
                ]),
            child: Row(children: [
              Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: (f['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(f['icon'] as IconData,
                      color: f['color'] as Color, size: 24)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(f['name'] as String,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text(f['detail'] as String,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                    Row(children: [
                      const Icon(LucideIcons.star,
                          color: AppColors.accentGold, size: 14, fill: 1.0),
                      const SizedBox(width: 3),
                      Text(f['rating'] as String,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600))
                    ]),
                  ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(f['price'] as String,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
                const SizedBox(height: 6),
                GestureDetector(
                    onTap: () => _bookService(f),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            color: AppColors.bgPrimary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primary)),
                        child: const Text('Book \$5',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)))),
              ]),
            ]),
          ).animate().fadeIn(duration: 300.ms).moveY(begin: 10)),
    ];
  }

  void _bookService(Map<String, dynamic> item) {
    // Open contact method dialog to request processing instead of direct booking
    _showContactMethodDialog(item);
  }

  void _showCompanionDetails(Map<String, dynamic> c) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) {
          return Padding(
            padding: MediaQuery.of(ctx).viewInsets,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFBE185D), Color(0xFFEC4899)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                            child: Text((c['name'] as String)[0],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['name'] ?? '',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text('${c['age'] ?? ''} • ${c['languages'] ?? ''}',
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.textMuted)),
                        ],
                      ))
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(LucideIcons.star,
                        color: AppColors.accentGold, size: 16, fill: 1.0),
                    const SizedBox(width: 6),
                    Text(c['rating'] ?? '',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text(c['price'] ?? '',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                  ]),
                  const SizedBox(height: 12),
                  if ((c['bio'] ?? '').toString().isNotEmpty) ...[
                    const Text('Bio',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(c['bio'] ?? '',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                  ],
                  if ((c['interests'] ?? '').toString().isNotEmpty) ...[
                    const Text('Interests',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(c['interests'] ?? '',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _showContactMethodDialog(c);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBE185D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Request This Companion',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        });
  }

  void _showContactMethodDialog(Map<String, dynamic> item) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) {
          ContactMethod method = ContactMethod.whatsapp;
          final TextEditingController contactController =
              TextEditingController();
          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: MediaQuery.of(ctx).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How should we contact you?',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    ContactMethodSelector(
                        selectedMethod: method,
                        onChanged: (m) {
                          setState(() {
                            method = m;
                            contactController.text = '';
                          });
                        }),
                    const SizedBox(height: 12),
                    if (method == ContactMethod.whatsapp)
                      TextField(
                        controller: contactController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            hintText: 'WhatsApp number',
                            filled: true,
                            fillColor: AppColors.bgWhite,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none)),
                      ),
                    if (method == ContactMethod.email)
                      TextField(
                        controller: contactController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            hintText: 'Email address',
                            filled: true,
                            fillColor: AppColors.bgWhite,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none)),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final contactValue = contactController.text.trim();
                          // Save a request record (status: requested)
                          BookingService().addBooking({
                            'type': widget.serviceType,
                            'name': item['name'] ?? item['detail'] ?? '',
                            'detail': item['detail'] ?? '',
                            'price': item['price'] ?? '',
                            'status': 'requested',
                            'contact_method': method.name,
                            'contact_value': contactValue,
                          });

                          Navigator.of(ctx).pop();

                          // Show confirmation
                          showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20))),
                              builder: (c) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 8),
                                      const Icon(LucideIcons.check,
                                          color: AppColors.success, size: 42),
                                      const SizedBox(height: 12),
                                      Text(
                                          'Request received. Our team will contact you via ${method == ContactMethod.whatsapp ? 'WhatsApp' : method == ContactMethod.email ? 'Email' : 'In-app chat'} within 15 minutes to finalise arrangements.',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: AppColors.textSecondary)),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(c).pop(),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12),
                                            child: Text('Close',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Request Processing',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          });
        });
  }
}
