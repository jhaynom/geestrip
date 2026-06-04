import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

class ResultsScreen extends StatefulWidget {
  final Map<String, String> bookingData;
  ResultsScreen({super.key, required this.bookingData});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int _selectedHotelIndex = 0;
  int _selectedRoomIndex = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _hotels = [
    {
      'name': 'Serenity Suites',
      'location': 'Victoria Island, Lagos',
      'rating': '4.8',
      'reviews': '234',
      'price': 120,
      'description':
          'A tranquil escape in the heart of Victoria Island. Modern rooms with stunning city views, world-class dining, and a rooftop pool that will take your breath away.',
      'images': [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&h=500&fit=crop',
        'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&h=500&fit=crop',
        'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&h=500&fit=crop',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&h=500&fit=crop',
      ],
      'amenities': [
        'Free WiFi',
        'Pool',
        'Gym',
        'Restaurant',
        'Room Service',
        'Spa'
      ],
      'insiderTip':
          'Request the 3rd floor facing the garden. Dead quiet, blazing fast WiFi.',
      'rooms': [
        {
          'name': 'Deluxe King',
          'price': 120,
          'bed': 'King Bed',
          'view': 'City View',
          'size': '32 m²',
          'guests': 2
        },
        {
          'name': 'Premium Suite',
          'price': 180,
          'bed': 'King Bed',
          'view': 'Ocean View',
          'size': '48 m²',
          'guests': 2
        },
        {
          'name': 'Executive Room',
          'price': 150,
          'bed': 'Queen Bed',
          'view': 'Garden View',
          'size': '36 m²',
          'guests': 2
        },
      ],
    },
    {
      'name': 'The Urban Haven',
      'location': 'Maitama, Abuja',
      'rating': '4.6',
      'reviews': '189',
      'price': 95,
      'description':
          'Designed for the modern business traveler. Ergonomic workspaces, high-speed internet, and a dedicated business center make this the perfect work-from-hotel destination.',
      'images': [
        'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&h=500&fit=crop',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&h=500&fit=crop',
        'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&h=500&fit=crop',
      ],
      'amenities': [
        'Free WiFi',
        'Workspace',
        'Meeting Room',
        'Airport Shuttle',
        'Restaurant'
      ],
      'insiderTip':
          'Best business facilities in Abuja. Ask for room with workspace view.',
      'rooms': [
        {
          'name': 'Business Standard',
          'price': 95,
          'bed': 'Queen Bed',
          'view': 'City View',
          'size': '28 m²',
          'guests': 2
        },
        {
          'name': 'Business Premium',
          'price': 140,
          'bed': 'King Bed',
          'view': 'Skyline View',
          'size': '38 m²',
          'guests': 2
        },
      ],
    },
    {
      'name': 'Palm Grove Hotel',
      'location': 'Airport City, Accra',
      'rating': '4.5',
      'reviews': '156',
      'price': 140,
      'description':
          'Your gateway to Accra. Minutes from the airport with a lush tropical garden, infinity pool, and authentic Ghanaian hospitality that makes every guest feel like family.',
      'images': [
        'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&h=500&fit=crop',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&h=500&fit=crop',
      ],
      'amenities': [
        'Free WiFi',
        'Pool',
        'Airport Shuttle',
        'Restaurant',
        'Bar'
      ],
      'insiderTip':
          'Airport shuttle included. Early check-in available on request.',
      'rooms': [
        {
          'name': 'Garden Room',
          'price': 140,
          'bed': 'Queen Bed',
          'view': 'Garden View',
          'size': '30 m²',
          'guests': 2
        },
        {
          'name': 'Poolside Suite',
          'price': 200,
          'bed': 'King Bed',
          'view': 'Pool View',
          'size': '45 m²',
          'guests': 3
        },
      ],
    },
  ];

  Map<String, dynamic> get _selectedHotel => _hotels[_selectedHotelIndex];
  Map<String, dynamic> get _selectedRoom =>
      _selectedHotel['rooms'][_selectedRoomIndex];

  List<Map<String, dynamic>> _filteredHotels = [];
  List<Map<String, dynamic>> _exactMatches = [];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  @override
  void didUpdateWidget(covariant ResultsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookingData != widget.bookingData) _applyFilters();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPersonalizedHeader(),
                    if (_exactMatches.isNotEmpty) ...[
                      ..._exactMatches.map((h) => _HotelCard(h)),
                    ] else ...[
                      if (_filteredHotels.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'No hotels match all criteria. Here are the closest options:',
                            style: const TextStyle(
                                fontSize: 16, color: AppColors.textMuted),
                          ),
                        ),
                      ..._filteredHotels.map((h) => _HotelCard(h)),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    final data = widget.bookingData;
    final rawDestination = (data['destination'] ?? data['city'] ?? '').trim();
    final destination = rawDestination.toLowerCase();
    final rawBudget = (data['budget'] ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final budget = int.tryParse(rawBudget) ?? 0;
    final amenitiesRaw = (data['amenities'] ?? '').toLowerCase();
    final requestedAmenities = amenitiesRaw.isEmpty
        ? <String>[]
        : amenitiesRaw
            .split(RegExp(r'[;,\|]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

    List<Map<String, dynamic>> scored = [];
    for (final h in _hotels) {
      final location = (h['location'] as String).toLowerCase();
      final price = (h['price'] is num)
          ? (h['price'] as num).toDouble()
          : double.tryParse('${h['price']}') ?? 0.0;
      final hotelAmenities = (h['amenities'] as List)
          .map((a) => a.toString().toLowerCase())
          .toList();

      final locationMatch =
          destination.isEmpty ? true : location.contains(destination);
      // budget within ±30%
      final budgetMatch =
          budget <= 0 ? true : (price >= budget * 0.7 && price <= budget * 1.3);
      int amenityMatchCount = 0;
      for (final ra in requestedAmenities) {
        if (hotelAmenities.any((ha) => ha.contains(ra))) amenityMatchCount++;
      }

      // Score: amenities first, then budget, then location, then rating
      final rating = double.tryParse('${h['rating']}') ?? 0.0;
      final score = amenityMatchCount * 100 +
          (budgetMatch ? 30 : 0) +
          (locationMatch ? 20 : 0) +
          rating;

      final reasons = <String>[];
      if (locationMatch) reasons.add('Matches your destination');
      if (budgetMatch && budget > 0) reasons.add('Within budget');
      if (amenityMatchCount > 0)
        reasons.add('Has ${requestedAmenities.join(", ")}');

      scored.add({
        ...h,
        '_score': score,
        '_reasons': reasons,
        '_amenityMatchCount': amenityMatchCount
      });
    }

    scored.sort((a, b) {
      final sB = (b['_score'] as num).toDouble();
      final sA = (a['_score'] as num).toDouble();
      if (sB.compareTo(sA) != 0) return sB.compareTo(sA);
      final aCount = (b['_amenityMatchCount'] as int)
          .compareTo(a['_amenityMatchCount'] as int);
      if (aCount != 0) return aCount;
      return (double.tryParse('${b['rating']}') ?? 0)
          .compareTo(double.tryParse('${a['rating']}') ?? 0);
    });

    // Exact matches: location && budget && all amenities (if requested)
    _exactMatches = scored.where((h) {
      final location = (h['location'] as String).toLowerCase();
      final locationMatch =
          destination.isEmpty ? true : location.contains(destination);
      final price = (h['price'] is num)
          ? (h['price'] as num).toDouble()
          : double.tryParse('${h['price']}') ?? 0.0;
      final budgetMatch =
          budget <= 0 ? true : (price >= budget * 0.7 && price <= budget * 1.3);
      final amenityCount = h['_amenityMatchCount'] as int;
      final allAmenities = requestedAmenities.isEmpty
          ? true
          : amenityCount >= requestedAmenities.length;
      return locationMatch && budgetMatch && allAmenities;
    }).toList();

    // If exact matches exist, show them; otherwise show top scored as closest
    if (_exactMatches.isNotEmpty) {
      _filteredHotels = _exactMatches;
    } else {
      _filteredHotels = scored.where((h) {
        // show hotels that match at least one criterion
        return (h['_amenityMatchCount'] as int) > 0 ||
            (widget.bookingData['budget'] ?? '').isNotEmpty ||
            (widget.bookingData['destination'] ?? '').isNotEmpty;
      }).toList();
    }

    // Ensure indices are valid
    if (_filteredHotels.isNotEmpty) {
      final firstHotel = _filteredHotels.first;
      _selectedHotelIndex = _hotels.indexWhere((h) =>
          h['name'] == firstHotel['name'] &&
          h['location'] == firstHotel['location']);
      if (_selectedHotelIndex < 0) _selectedHotelIndex = 0;
      _selectedRoomIndex = 0;
    }
    setState(() {});
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: AppColors.bgWhite,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(LucideIcons.arrowLeft,
                  size: 22, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedHotel['name'],
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text(_selectedHotel['location'],
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: AppColors.accentPinkLight,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(LucideIcons.heart,
                  color: AppColors.accentPink, size: 20),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(LucideIcons.share2,
                  color: AppColors.textSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedRoom['name'],
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text('\$${_selectedRoom['price']} / night',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showConfirmationSheet(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: const Row(
                  children: [
                    Text('Confirm & Pay',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    SizedBox(width: 6),
                    Icon(LucideIcons.chevronRight,
                        color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.tabInactive,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Confirm Your Booking',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text('Please review your selection before we proceed to payment.',
                style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  _ConfirmRow('Hotel', _selectedHotel['name']),
                  const SizedBox(height: 10),
                  _ConfirmRow('Room', _selectedRoom['name']),
                  const SizedBox(height: 10),
                  _ConfirmRow('Location', _selectedHotel['location']),
                  const SizedBox(height: 10),
                  _ConfirmRow('Price', '\$${_selectedRoom['price']} / night'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accentGreenLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.shieldCheck,
                      color: AppColors.success, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        'Your booking is protected by GeesTrip. Free cancellation within 24 hours.',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          '🎉 Booking confirmed! Redirecting to payment...',
                          style: TextStyle(fontSize: 16)),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('Proceed to Payment',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedHeader() {
    final dest =
        (widget.bookingData['destination'] ?? widget.bookingData['city'] ?? '')
            .trim();
    final cityLabel = dest.isEmpty ? '' : ' in ${dest.split(',').first}';
    final count = _exactMatches.isNotEmpty
        ? _exactMatches.length
        : _filteredHotels.length;
    final title = count > 0
        ? '$count hotels matching your style$cityLabel'
        : 'Handpicked hotels${cityLabel.isEmpty ? '' : cityLabel}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(
                    'We matched hotels based on your preferences. Tap a card to view details.',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => context.push('/concierge', extra: 'stay'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bgPrimary,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('Refine Search',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  final Map<String, dynamic> hotel;
  const _HotelCard(this.hotel);

  @override
  Widget build(BuildContext context) {
    final reasons = (hotel['_reasons'] as List<String>? ?? []).cast<String>();
    final imgs = (hotel['images'] as List).cast<String>();
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ResultsScreen(bookingData: {}))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(imgs.isNotEmpty ? imgs[0] : '',
                    height: 160, width: double.infinity, fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(hotel['name'] as String,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary))),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(children: [
                            const Icon(LucideIcons.star,
                                color: AppColors.accentGold, size: 14),
                            const SizedBox(width: 6),
                            Text('${hotel['rating']}',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700))
                          ]),
                          Text('\$${hotel['price']}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(hotel['location'] as String,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  Wrap(
                      spacing: 6,
                      children: reasons
                          .map((r) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                  color: AppColors.accentBlueLight,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.check,
                                        size: 12, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(r,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700))
                                  ])))
                          .toList()),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomFeature extends StatelessWidget {
  final IconData icon;
  final String label;
  const _RoomFeature(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  const _ConfirmRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500)),
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ],
    );
  }
}
