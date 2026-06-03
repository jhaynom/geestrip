import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

class TripHubScreen extends StatelessWidget {
  const TripHubScreen({super.key});

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Trip Hub', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Serenity Suites · Lagos', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _TimelineItem(
                    status: 'completed',
                    title: 'Booked',
                    detail: 'Serenity Suites confirmed. Concierge monitoring.',
                    date: 'Dec 15',
                  ),
                  _TimelineItem(
                    status: 'active',
                    title: 'Pre-Arrival',
                    detail: 'Early check-in confirmed. Room 412, quiet floor.',
                    date: 'Dec 14',
                  ),
                  _TimelineItem(
                    status: 'upcoming',
                    title: 'During Stay',
                    detail: 'Something not right? Tap below.',
                    date: 'Dec 15-20',
                  ),
                  _TimelineItem(
                    status: 'upcoming',
                    title: 'Post-Stay',
                    detail: 'Rate your experience. Get loyalty code.',
                    date: 'Dec 21',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => context.push('/safe-stay'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.shield, size: 20),
                          SizedBox(width: 8),
                          Text('Something not right? We fix it in 15 min', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.tabInactive),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.messageCircle, size: 20),
                          SizedBox(width: 8),
                          Text('Message your concierge', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String status;
  final String title;
  final String detail;
  final String date;
  final bool isLast;

  const _TimelineItem({
    required this.status,
    required this.title,
    required this.detail,
    required this.date,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    if (status == 'completed') dotColor = AppColors.primary;
    else if (status == 'active') dotColor = AppColors.primaryLight;
    else dotColor = AppColors.tabInactive;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: status == 'active'
                    ? [BoxShadow(color: dotColor.withOpacity(0.4), blurRadius: 8)]
                    : null,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: AppColors.tabInactive,
                ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(detail, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
