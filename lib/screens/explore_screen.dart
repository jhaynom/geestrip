import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/chat_service.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  GestureDetector(onTap: () => context.pop(), child: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.bgWhite, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]), child: const Icon(LucideIcons.arrowLeft, size: 22, color: AppColors.textSecondary))),
                  const SizedBox(width: 14),
                  const Expanded(child: Text('Explore GeesTrip', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _SectionHeader(title: 'Properties', icon: LucideIcons.building2),
                    const SizedBox(height: 12),
                    _GlassCard(icon: LucideIcons.building2, title: 'Hotels', subtitle: '150+ verified hotels across Africa', count: '150+', gradient: [const Color(0xFF1F3BB3), const Color(0xFF3B5CF6)], onTap: () => context.push('/properties', extra: 'hotels')),
                    const SizedBox(height: 10),
                    _GlassCard(icon: LucideIcons.home, title: 'Apartments & Shortlets', subtitle: 'Fully furnished apartments for any stay', count: '80+', gradient: [const Color(0xFF0D9488), const Color(0xFF14B8A6)], onTap: () => context.push('/properties', extra: 'apartments')),
                    const SizedBox(height: 10),
                    _GlassCard(icon: LucideIcons.warehouse, title: 'Resorts & Villas', subtitle: 'Luxury escapes for unforgettable stays', count: '25+', gradient: [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)], onTap: () => context.push('/properties', extra: 'resorts')),
                    const SizedBox(height: 28),
                    _SectionHeader(title: 'Concierge Services', icon: LucideIcons.sparkles),
                    const SizedBox(height: 12),
                    _GlassCard(icon: LucideIcons.car, title: 'Shuttle & Transport', subtitle: 'Airport pickups, city transfers, car rentals', count: '24/7', gradient: [const Color(0xFFEA580C), const Color(0xFFF97316)], onTap: () => context.push('/services', extra: 'shuttle')),
                    const SizedBox(height: 10),
                    _GlassCard(icon: LucideIcons.map, title: 'City Tours & Experiences', subtitle: 'Guided tours, local attractions, hidden gems', count: '50+ Tours', gradient: [const Color(0xFF059669), const Color(0xFF10B981)], onTap: () => context.push('/services', extra: 'tours')),
                    const SizedBox(height: 10),
                    _GlassCard(icon: LucideIcons.users, title: 'Travel Companion', subtitle: 'Professional companions for events & travel', count: 'Verified', gradient: [const Color(0xFFBE185D), const Color(0xFFEC4899)], onTap: () => context.push('/services', extra: 'companion')),
                    const SizedBox(height: 10),
                    _GlassCard(icon: LucideIcons.utensilsCrossed, title: 'Dining & Reservations', subtitle: 'Exclusive restaurant bookings & private chef', count: '100+ Spots', gradient: [const Color(0xFFDC2626), const Color(0xFFF43F5E)], onTap: () => context.push('/services', extra: 'dining')),
                    const SizedBox(height: 10),
                    _GlassCard(icon: LucideIcons.plane, title: 'Flight Booking', subtitle: 'Best rates on local & international flights', count: 'Global', gradient: [const Color(0xFF2563EB), const Color(0xFF60A5FA)], onTap: () => context.push('/services', extra: 'flights')),
                    const SizedBox(height: 10),
                    _GlassCard(icon: LucideIcons.conciergeBell, title: 'Personal Concierge', subtitle: 'Custom requests, errands, anything you need', count: 'Premium', gradient: [const Color(0xFF4F46E5), const Color(0xFF818CF8)], onTap: () => context.push('/concierge', extra: 'stay')),
                  ],
                ),
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
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(LucideIcons.messageCircle,
                          color: Colors.white, size: 26),
                      if (ChatService().totalUnread > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle),
                            child: Center(
                                child: Text('${ChatService().totalUnread}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700))),
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
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppColors.primary, size: 16)), const SizedBox(width: 10), Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary))]);
  }
}

class _GlassCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String count;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _GlassCard({required this.icon, required this.title, required this.subtitle, required this.count, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.bgWhite, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))], border: Border.all(color: Colors.white.withOpacity(0.8))),
        child: Row(
          children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: gradient.first.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]), child: Icon(icon, color: Colors.white, size: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500))])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: gradient.first.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(count, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: gradient.first))),
            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 18),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).moveY(begin: 10),
    );
  }
}