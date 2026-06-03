import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/content_service.dart';

class CompanionProfilesScreen extends StatefulWidget {
  const CompanionProfilesScreen({super.key});

  @override
  State<CompanionProfilesScreen> createState() =>
      _CompanionProfilesScreenState();
}

class _CompanionProfilesScreenState extends State<CompanionProfilesScreen> {
  String _selectedGender = 'all';
  late final Future<List<Map<String, dynamic>>> _companionsFuture;

  @override
  void initState() {
    super.initState();
    _companionsFuture = _loadCompanions();
  }

  Future<List<Map<String, dynamic>>> _loadCompanions() async {
    final entries = await ContentService().fetchCompanions();
    if (entries.isEmpty) return _fallbackCompanions;
    return entries.map((entry) {
      final metadata = entry['metadata'];
      return {
        'name': entry['title'] ?? 'Companion',
        'age': metadata is Map ? metadata['age'] ?? 0 : 0,
        'languages': metadata is Map ? metadata['languages'] ?? '' : '',
        'rating': entry['subtitle'] ?? '4.8',
        'reviews': metadata is Map ? metadata['reviews'] ?? '0' : '0',
        'price': metadata is Map ? metadata['price'] ?? '\$75/hr' : '\$75/hr',
        'gender': metadata is Map ? metadata['gender'] ?? 'all' : 'all',
        'location': entry['subtitle'] ?? metadata is Map
            ? metadata['location'] ?? ''
            : '',
        'bio': entry['body'] ?? '',
        'interests': metadata is Map ? metadata['interests'] ?? '' : '',
        'photos': metadata is Map ? metadata['photos'] ?? 5 : 5,
        'verified': metadata is Map ? metadata['verified'] ?? true : true,
      };
    }).toList();
  }

  final List<Map<String, dynamic>> _fallbackCompanions = [
    {
      'name': 'Amara O.',
      'age': 28,
      'languages': 'English, French',
      'rating': '4.9',
      'reviews': '127',
      'price': '\$80/hr',
      'gender': 'female',
      'location': 'Lagos, Nigeria',
      'bio':
          'Event companion with 5 years experience in hosting and event coordination. Available for dinners, galas, and business events.',
      'interests': 'Arts, Travel, Photography, Fine Dining',
      'photos': 5,
      'verified': true,
    },
    {
      'name': 'Chioma E.',
      'age': 26,
      'languages': 'English, Igbo',
      'rating': '4.7',
      'reviews': '89',
      'price': '\$85/hr',
      'gender': 'female',
      'location': 'Abuja, Nigeria',
      'bio':
          'Fine dining and conversation specialist. Loves culinary experiences and cultural events.',
      'interests': 'Food, Culture, Museums, Music',
      'photos': 5,
      'verified': true,
    },
    {
      'name': 'David K.',
      'age': 30,
      'languages': 'English, Swahili',
      'rating': '4.8',
      'reviews': '156',
      'price': '\$70/hr',
      'gender': 'male',
      'location': 'Nairobi, Kenya',
      'bio':
          'Travel buddy and local guide. Enjoys outdoor activities and adventure sports.',
      'interests': 'Hiking, Music, Sports, Travel',
      'photos': 5,
      'verified': true,
    },
    {
      'name': 'Michael T.',
      'age': 32,
      'languages': 'English, French',
      'rating': '4.9',
      'reviews': '203',
      'price': '\$90/hr',
      'gender': 'male',
      'location': 'Lagos, Nigeria',
      'bio':
          'Experienced in corporate events and business networking. Professional and discreet.',
      'interests': 'Business, Networking, Golf, Wine',
      'photos': 5,
      'verified': true,
    },
    {
      'name': 'Sarah J.',
      'age': 27,
      'languages': 'English',
      'rating': '5.0',
      'reviews': '42',
      'price': '\$95/hr',
      'gender': 'female',
      'location': 'Accra, Ghana',
      'bio':
          'Wedding and special event companion with exceptional presentation and charm.',
      'interests': 'Events, Fashion, Dance, Travel',
      'photos': 5,
      'verified': true,
    },
    {
      'name': 'James O.',
      'age': 29,
      'languages': 'English, Yoruba',
      'rating': '4.6',
      'reviews': '78',
      'price': '\$65/hr',
      'gender': 'male',
      'location': 'Lagos, Nigeria',
      'bio':
          'Friendly and outgoing travel buddy. Knows all the best spots in Lagos.',
      'interests': 'Nightlife, Food, Beaches, Sports',
      'photos': 5,
      'verified': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredCompanions {
    if (_selectedGender == 'all') return _fallbackCompanions;
    return _fallbackCompanions
        .where((c) => c['gender'] == _selectedGender)
        .toList();
  }

  List<Map<String, dynamic>> _filterCompanions(
      List<Map<String, dynamic>> companions) {
    if (_selectedGender == 'all') return companions;
    return companions.where((c) => c['gender'] == _selectedGender).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _companionsFuture,
          builder: (context, snapshot) {
            final companions = snapshot.hasData
                ? _filterCompanions(snapshot.data!)
                : _filteredCompanions;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Travel Companions',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${companions.length} profiles',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'FREE to browse',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Gender filter tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.bgWhite,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _GenderTab(
                          label: 'All',
                          isActive: _selectedGender == 'all',
                          onTap: () => setState(() => _selectedGender = 'all'),
                        ),
                        _GenderTab(
                          label: 'Female',
                          isActive: _selectedGender == 'female',
                          onTap: () =>
                              setState(() => _selectedGender = 'female'),
                        ),
                        _GenderTab(
                          label: 'Male',
                          isActive: _selectedGender == 'male',
                          onTap: () => setState(() => _selectedGender = 'male'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Companion list
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: companions.length,
                    itemBuilder: (context, index) {
                      final c = companions[index];
                      return _CompanionCard(
                        companion: c,
                        onTap: () => _showCompanionDetail(c),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCompanionDetail(Map<String, dynamic> c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo placeholder + name
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFBE185D), Color(0xFFEC4899)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFFBE185D).withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              LucideIcons.user,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    c['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (c['verified'] == true) ...[
                                    const SizedBox(width: 6),
                                    const Icon(
                                      LucideIcons.shieldCheck,
                                      color: AppColors.success,
                                      size: 20,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${c['age']} • ${c['location']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    LucideIcons.star,
                                    color: AppColors.accentGold,
                                    size: 16,
                                    fill: 1.0,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${c['rating']} (${c['reviews']} reviews)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Photo gallery placeholder
                    const Text(
                      'Photos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) => Container(
                          width: 80,
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFBE185D), Color(0xFFEC4899)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              LucideIcons.image,
                              color: Colors.white.withOpacity(0.7),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bio
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c['bio'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Languages
                    const Text(
                      'Languages',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c['languages'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Interests
                    const Text(
                      'Interests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (c['interests'] as String)
                          .split(', ')
                          .map((interest) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFBE185D).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  interest,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFBE185D),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),

                    const SizedBox(height: 24),

                    // Price + Request button
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c['price'] as String,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFBE185D),
                                ),
                              ),
                              const Text(
                                'Pay only when requesting',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              context.push('/service-paywall', extra: {
                                'type': 'companion',
                                'name': c['name'],
                                'fee': 5,
                                'answers': {'companion_name': c['name']},
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFBE185D),
                                    Color(0xFFEC4899)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFBE185D)
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Request Availability',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _GenderTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 250.ms,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanionCard extends StatelessWidget {
  final Map<String, dynamic> companion;
  final VoidCallback onTap;

  const _CompanionCard({
    required this.companion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = companion;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Portrait placeholder
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFBE185D), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.user,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        c['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (c['verified'] == true) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          LucideIcons.shieldCheck,
                          color: AppColors.success,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${c['age']} • ${c['location']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.star,
                        color: AppColors.accentGold,
                        size: 13,
                        fill: 1.0,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${c['rating']} (${c['reviews']} reviews)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        LucideIcons.camera,
                        color: AppColors.textMuted,
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${c['photos']} photos',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  c['price'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBE185D),
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).moveY(begin: 10),
    );
  }
}
