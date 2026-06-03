import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

class SafeStayScreen extends StatelessWidget {
  const SafeStayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.textMuted),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(LucideIcons.shield, color: AppColors.error, size: 28),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Safe Stay', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("We're here to protect you. What's happening?", style: TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SafeStayOption(
              icon: LucideIcons.triangleAlert,
              title: 'Hotel is not as described',
              subtitle: 'Unsafe, unclean, or different from what was promised',
              color: const Color(0xFFFFFBEB),
              iconColor: Colors.amber,
            ),
            _SafeStayOption(
              icon: LucideIcons.shield,
              title: "I'm being treated unfairly",
              subtitle: 'Discrimination, harassment, or staff misconduct',
              color: const Color(0xFFFFF1F2),
              iconColor: AppColors.error,
            ),
            _SafeStayOption(
              icon: LucideIcons.phone,
              title: 'Emergency contact needed',
              subtitle: 'Medical, safety, or urgent relocation needed',
              color: AppColors.bgWhite,
              iconColor: AppColors.textMuted,
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Your GeesTrip concierge will respond within 15 minutes.\nFor emergencies, contact local authorities.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafeStayOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;

  const _SafeStayOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
