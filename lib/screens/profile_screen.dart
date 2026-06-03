import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/admin_service.dart';
import '../services/auth_service.dart';
import '../services/partner_service.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  @override
  void initState() {
    super.initState();
    _loadAdminRole();
  }

  Future<void> _loadAdminRole() async {
    await AdminService().checkRole();
    if (mounted) {
      setState(() {
        _isAdmin = AdminService().isAdmin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AuthService().isLoggedIn) {
      return _buildLoggedInProfile(context);
    }
    return _buildGuestProfile(context);
  }

  Widget _buildLoggedInProfile(BuildContext context) {
    final bookingsCount = BookingService().totalBookings;
    final isSubscribed = PaymentService().isSubscribed;
    final planName =
        PaymentService().getPlanLabel(PaymentService().currentPlan);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D1B6B), Color(0xFF1F3BB3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              LucideIcons.arrowLeft,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const Text(
                          'My Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/payment-methods'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              LucideIcons.settings,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Avatar
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B5CF6), Color(0xFF8B9CFE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B5CF6).withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          AuthService().userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AuthService().userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      AuthService().userEmail.isNotEmpty
                          ? AuthService().userEmail
                          : 'user@email.com',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ELITE MEMBER',
                            style: TextStyle(
                              color: AppColors.accentGold,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        if (isSubscribed) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              planName,
                              style: const TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _StatCard(
                      icon: LucideIcons.building2,
                      value: '$bookingsCount',
                      label: 'Bookings',
                      gradient: const [Color(0xFF1F3BB3), Color(0xFF3B5CF6)],
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      icon: LucideIcons.star,
                      value: '4.8',
                      label: 'Rating',
                      gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      icon: LucideIcons.award,
                      value: isSubscribed ? 'Active' : 'Free',
                      label: 'Plan',
                      gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Menu items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Section: Account
                    const _SectionHeader(title: 'ACCOUNT'),
                    const SizedBox(height: 8),
                    if (isSubscribed)
                      _MenuItem(
                        icon: LucideIcons.crown,
                        title: 'My Subscription',
                        subtitle: 'Manage your $planName plan',
                        iconColor: AppColors.accentGold,
                        onTap: () => context.push('/subscription-management'),
                      )
                    else
                      _MenuItem(
                        icon: LucideIcons.crown,
                        title: 'Subscribe & Save',
                        subtitle: 'Get unlimited bookings from ₦50k',
                        iconColor: AppColors.accentGold,
                        onTap: () => context.push('/subscription-plans'),
                      ),
                    _MenuItem(
                      icon: LucideIcons.calendarCheck,
                      title: 'My Bookings',
                      subtitle: 'View all your reservations',
                      iconColor: const Color(0xFF3B5CF6),
                      onTap: () => context.push('/my-bookings'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.messageCircle,
                      title: 'Messages',
                      subtitle: 'Chat with our concierge team',
                      iconColor: const Color(0xFF6366F1),
                      onTap: () => context.push('/chat-list'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.heart,
                      title: 'Saved Properties',
                      subtitle: 'Hotels and apartments you liked',
                      iconColor: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: LucideIcons.creditCard,
                      title: 'Payment Methods',
                      subtitle: 'Manage cards and mobile money',
                      iconColor: const Color(0xFF059669),
                      onTap: () => context.push('/payment-methods'),
                    ),

                    const SizedBox(height: 16),
                    const _SectionHeader(title: 'MORE'),
                    const SizedBox(height: 8),

                    _MenuItem(
                      icon: LucideIcons.star,
                      title: 'Write a Review',
                      subtitle: 'Share your experience',
                      iconColor: const Color(0xFFF59E0B),
                      onTap: () => context.push('/write-review',
                          extra: 'Serenity Suites'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.building2,
                      title: 'Partner with Us',
                      subtitle: 'List your property and start earning',
                      iconColor: const Color(0xFF1F3BB3),
                      onTap: () {
                        if (PartnerService().isPartner) {
                          context.push('/partner-dashboard');
                        } else {
                          context.push('/partner-register');
                        }
                      },
                    ),
                    if (isAdmin)
                      _MenuItem(
                        icon: LucideIcons.shield,
                        title: 'Admin Dashboard',
                        subtitle: 'Manage properties, users & bookings',
                        iconColor: const Color(0xFF7C3AED),
                        onTap: () => context.push('/admin'),
                      ),
                    _MenuItem(
                      icon: LucideIcons.languages,
                      title: 'Language',
                      subtitle: 'Change app language',
                      iconColor: const Color(0xFF0891B2),
                      onTap: () => context.push('/language'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.bell,
                      title: 'Notifications',
                      subtitle: 'Booking updates and alerts',
                      iconColor: const Color(0xFFEA580C),
                      onTap: () => context.push('/notifications'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.shield,
                      title: 'Trip Guardian',
                      subtitle: 'Manage your protection plan',
                      iconColor: const Color(0xFF059669),
                      onTap: () => context.push('/trip-guardian'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.helpCircle,
                      title: 'Help & Support',
                      subtitle: 'FAQs, contact us',
                      iconColor: const Color(0xFF6366F1),
                      onTap: () => context.push('/faq'),
                    ),

                    const SizedBox(height: 16),
                    const _SectionHeader(title: 'LEGAL'),
                    const SizedBox(height: 8),

                    _MenuItem(
                      icon: LucideIcons.fileText,
                      title: 'Terms of Service',
                      subtitle: 'Our terms and conditions',
                      iconColor: AppColors.textMuted,
                      onTap: () => context.push('/terms'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.lock,
                      title: 'Privacy Policy',
                      subtitle: 'How we handle your data',
                      iconColor: AppColors.textMuted,
                      onTap: () => context.push('/privacy'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Sign Out
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () async {
                    await AuthService().signOut();
                    if (context.mounted) context.go('/');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D1B6B), Color(0xFF1F3BB3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              LucideIcons.arrowLeft,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const Text(
                          'My Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF64748B), Color(0xFF94A3B8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.user,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Guest User',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'Sign up to unlock all features',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1F3BB3).withOpacity(0.28),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Create Free Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Premium banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accentGold.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          LucideIcons.crown,
                          color: AppColors.accentGold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unlock Premium Features',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Create an account to save bookings, earn rewards, and access exclusive deals.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFA16207),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const _SectionHeader(title: 'ACCOUNT'),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: LucideIcons.crown,
                      title: 'Subscription Plans',
                      subtitle: 'View our subscription packages',
                      iconColor: AppColors.accentGold,
                      onTap: () => context.push('/subscription-plans'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.calendarCheck,
                      title: 'My Bookings',
                      subtitle: 'View your reservations',
                      iconColor: const Color(0xFF3B5CF6),
                      onTap: () => context.push('/my-bookings'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.messageCircle,
                      title: 'Messages',
                      subtitle: 'Chat with our concierge team',
                      iconColor: const Color(0xFF6366F1),
                      onTap: () => context.push('/chat-list'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.heart,
                      title: 'Saved Properties',
                      subtitle: 'Hotels and apartments you liked',
                      iconColor: const Color(0xFFEC4899),
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    const _SectionHeader(title: 'MORE'),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: LucideIcons.star,
                      title: 'Write a Review',
                      subtitle: 'Share your experience',
                      iconColor: const Color(0xFFF59E0B),
                      onTap: () => context.push('/write-review',
                          extra: 'Serenity Suites'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.building2,
                      title: 'Partner with Us',
                      subtitle: 'List your property and start earning',
                      iconColor: const Color(0xFF1F3BB3),
                      onTap: () => context.push('/partner-register'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.languages,
                      title: 'Language',
                      subtitle: 'Change app language',
                      iconColor: const Color(0xFF0891B2),
                      onTap: () => context.push('/language'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.shield,
                      title: 'Trip Guardian',
                      subtitle: 'Learn about protection plans',
                      iconColor: const Color(0xFF059669),
                      onTap: () => context.push('/trip-guardian'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.helpCircle,
                      title: 'Help & Support',
                      subtitle: 'FAQs, contact us',
                      iconColor: const Color(0xFF6366F1),
                      onTap: () => context.push('/faq'),
                    ),
                    const SizedBox(height: 16),
                    const _SectionHeader(title: 'LEGAL'),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: LucideIcons.fileText,
                      title: 'Terms of Service',
                      subtitle: 'Our terms and conditions',
                      iconColor: AppColors.textMuted,
                      onTap: () => context.push('/terms'),
                    ),
                    _MenuItem(
                      icon: LucideIcons.lock,
                      title: 'Privacy Policy',
                      subtitle: 'How we handle your data',
                      iconColor: AppColors.textMuted,
                      onTap: () => context.push('/privacy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Sign up / Sign in buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/signup'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1F3BB3).withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.bgWhite,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: const Center(
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final List<Color> gradient;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withOpacity(0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: gradient.first,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconColor.withOpacity(0.95),
                    iconColor.withOpacity(0.7)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
