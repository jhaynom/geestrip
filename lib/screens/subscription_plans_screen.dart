import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/payment_service.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  int _selectedPlan = 1; // Default: Explorer (recommended)
  final _service = PaymentService();

  @override
  Widget build(BuildContext context) {
    final plans = [
      {
        'plan': SubscriptionPlan.travelerLite,
        'name': 'Traveler Lite',
        'price': _service.getPlanPrice(SubscriptionPlan.travelerLite),
        'duration': '3 months',
        'color': const Color(0xFF3B5CF6),
        'gradient': [const Color(0xFF3B5CF6), const Color(0xFF6366F1)],
        'icon': LucideIcons.backpack,
        'features': _service.getPlanFeatures(SubscriptionPlan.travelerLite),
        'savings': 'Perfect for occasional travelers',
      },
      {
        'plan': SubscriptionPlan.explorer,
        'name': 'Explorer',
        'price': _service.getPlanPrice(SubscriptionPlan.explorer),
        'duration': '6 months',
        'color': const Color(0xFF1F3BB3),
        'gradient': [const Color(0xFF1F3BB3), const Color(0xFF8B5CF6)],
        'icon': LucideIcons.compass,
        'features': _service.getPlanFeatures(SubscriptionPlan.explorer),
        'savings': 'Save ₦15,000 vs per-trip',
        'recommended': true,
      },
      {
        'plan': SubscriptionPlan.globetrotter,
        'name': 'Globetrotter',
        'price': _service.getPlanPrice(SubscriptionPlan.globetrotter),
        'duration': '12 months',
        'color': const Color(0xFF0D1B6B),
        'gradient': [const Color(0xFF1A237E), const Color(0xFFF59E0B)],
        'icon': LucideIcons.globe,
        'features': _service.getPlanFeatures(SubscriptionPlan.globetrotter),
        'savings': 'Save ₦30,000+ vs per-trip',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF0D1B6B), Color(0xFF1F3BB3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(LucideIcons.arrowLeft,
                                color: Colors.white, size: 20)),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                          child: Text('Subscription Plans',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Book unlimited trips. Save more.',
                      style: TextStyle(color: Colors.white60, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text('Choose your travel style',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Plans
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final isSelected = _selectedPlan == index;
                  final isRecommended = plan['recommended'] == true;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedPlan = index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: isSelected
                            ? LinearGradient(
                                colors: plan['gradient'] as List<Color>,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight)
                            : null,
                        color: isSelected ? null : AppColors.bgWhite,
                        boxShadow: [
                          BoxShadow(
                            color: (isSelected
                                    ? (plan['gradient'] as List<Color>).first
                                    : Colors.black)
                                .withOpacity(isSelected ? 0.3 : 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: isSelected
                            ? null
                            : Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Plan header
                                Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.2)
                                            : (plan['color'] as Color)
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(plan['icon'] as IconData,
                                          color: isSelected
                                              ? Colors.white
                                              : plan['color'] as Color,
                                          size: 26),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(plan['name'] as String,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : AppColors.textPrimary)),
                                          Text(plan['duration'] as String,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: isSelected
                                                      ? Colors.white60
                                                      : AppColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(plan['price'] as String,
                                            style: TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.w800,
                                                color: isSelected
                                                    ? Colors.white
                                                    : AppColors.primary)),
                                        Text('one-time',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: isSelected
                                                    ? Colors.white54
                                                    : AppColors.textMuted)),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Features
                                ...(plan['features'] as List<String>)
                                    .map((feature) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 22,
                                                height: 22,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.white
                                                          .withOpacity(0.2)
                                                      : AppColors.success
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                ),
                                                child: Icon(LucideIcons.check,
                                                    color: isSelected
                                                        ? Colors.white
                                                        : AppColors.success,
                                                    size: 14),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                  child: Text(feature,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: isSelected
                                                              ? Colors.white
                                                                  .withOpacity(
                                                                      0.9)
                                                              : AppColors
                                                                  .textSecondary))),
                                            ],
                                          ),
                                        )),

                                const SizedBox(height: 16),

                                // Savings badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.15)
                                        : AppColors.accentGreenLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.trendingDown,
                                          color: isSelected
                                              ? AppColors.accentGold
                                              : AppColors.success,
                                          size: 16),
                                      const SizedBox(width: 6),
                                      Text(plan['savings'] as String,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? AppColors.accentGold
                                                  : AppColors.success)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Recommended badge
                          if (isRecommended)
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        color: AppColors.accentGold
                                            .withOpacity(0.4),
                                        blurRadius: 8)
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.crown,
                                        color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('BEST VALUE',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (100 * index).ms)
                        .moveY(begin: 20),
                  );
                },
              ),
            ),

            // Bottom button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(color: AppColors.bgWhite, boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -2))
              ]),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final selectedPlanData = plans[_selectedPlan];
                        final plan =
                            selectedPlanData['plan'] as SubscriptionPlan;
                        context.push('/booking-confirmation', extra: {
                          'type': 'subscription',
                          'name': selectedPlanData['name'],
                          'detail':
                              '${selectedPlanData['duration']} subscription',
                          'price': _service.getPlanPrice(plan),
                          'plan': plan.name,
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 6))
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Select ${plans[_selectedPlan]['name']} - ${plans[_selectedPlan]['price']}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('All plans include free verification on every booking',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500)),
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
