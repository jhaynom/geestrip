import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/partner_service.dart';
import '../services/auth_service.dart';

class PartnerDashboardScreen extends StatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await PartnerService().loadProperties();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final service = PartnerService();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                  onTap: () => context.go('/'),
                                  child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: const Icon(LucideIcons.arrowLeft,
                                          color: Colors.white, size: 20))),
                              const Text('My Properties',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              GestureDetector(
                                onTap: () => context.push('/partner-register'),
                                child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: const Icon(LucideIcons.plus,
                                        color: Colors.white, size: 22)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFF3B5CF6),
                                  Color(0xFF8B5CF6)
                                ]),
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: Colors.white, width: 3)),
                            child: const Icon(LucideIcons.building2,
                                color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 12),
                          Text(
                              service.partnerName.isNotEmpty
                                  ? service.partnerName
                                  : AuthService().userName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                          Text(
                              service.partnerEmail.isNotEmpty
                                  ? service.partnerEmail
                                  : AuthService().userEmail,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 14)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _StatCard(
                              icon: LucideIcons.building2,
                              value: '${service.myProperties.length}',
                              label: 'Properties',
                              color: AppColors.primary),
                          const SizedBox(width: 10),
                          _StatCard(
                              icon: LucideIcons.eye,
                              value: '${service.totalViews}',
                              label: 'Total Views',
                              color: AppColors.accentGreen),
                          const SizedBox(width: 10),
                          _StatCard(
                              icon: LucideIcons.calendarCheck,
                              value: '${service.totalBookings}',
                              label: 'Bookings',
                              color: AppColors.accentGold),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Info Banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: AppColors.accentBlueLight,
                            borderRadius: BorderRadius.circular(14)),
                        child: const Row(
                          children: [
                            Icon(LucideIcons.info,
                                color: AppColors.primary, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                                child: Text(
                                    'GeesTrip handles all bookings, guest communication, and payments. You just manage your property listing.',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500))),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Properties List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('My Properties',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          GestureDetector(
                            onTap: () => context.push('/partner-register'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.plus,
                                      color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text('Add New',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (service.myProperties.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                              color: AppColors.bgWhite,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10)
                              ]),
                          child: Column(
                            children: [
                              Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                      color: AppColors.primarySurface,
                                      borderRadius: BorderRadius.circular(16)),
                                  child: const Icon(LucideIcons.building2,
                                      color: AppColors.primary, size: 28)),
                              const SizedBox(height: 14),
                              const Text('No properties yet',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              const Text(
                                  'Tap "Add New" to list your first property',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ),

                    ...service.myProperties.map((property) => Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.bgWhite,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10)
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: Text(property['name'] as String,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary))),
                                    _StatusBadge(
                                        status: property['status'] as String),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _PropertyInfo(
                                        icon: LucideIcons.mapPin,
                                        value: property['location'] as String),
                                    const SizedBox(width: 14),
                                    _PropertyInfo(
                                        icon: LucideIcons.bedDouble,
                                        value: '${property['rooms']} rooms'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _PropertyInfo(
                                        icon: LucideIcons.dollarSign,
                                        value: '\$${property['price']}/night'),
                                    const SizedBox(width: 14),
                                    _PropertyInfo(
                                        icon: LucideIcons.eye,
                                        value: '${property['views']} views'),
                                    const SizedBox(width: 14),
                                    _PropertyInfo(
                                        icon: LucideIcons.calendarCheck,
                                        value:
                                            '${property['bookings']} bookings'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Submitted: ${property['submittedAt']}',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 300.ms).moveY(begin: 10)),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case 'active':
        color = AppColors.success;
        text = 'Live';
        break;
      case 'pending':
        color = AppColors.warning;
        text = 'Under Review';
        break;
      default:
        color = AppColors.textMuted;
        text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
            ]),
        child: Column(
          children: [
            Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _PropertyInfo extends StatelessWidget {
  final IconData icon;
  final String value;
  const _PropertyInfo({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppColors.textMuted),
      const SizedBox(width: 3),
      Text(value,
          style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500))
    ]);
  }
}
