import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

class TripGuardianScreen extends StatelessWidget {
  const TripGuardianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(LucideIcons.arrowLeft,
                        size: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(LucideIcons.shield,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trip Guardian™',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        Text('Your personal travel protector',
                            style: TextStyle(
                                color: Color(0xFF99F6E4), fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'A dedicated guardian angel for your entire journey. From booking to checkout, we monitor your stay and intervene instantly if anything goes wrong.',
                  style: TextStyle(color: Color(0xFF99F6E4), height: 1.6),
                ),
                const SizedBox(height: 24),
                ...[
                  '24/7 Emergency Helpline',
                  'Instant Relocation',
                  'Dispute Resolution',
                  'Real-Time Safety Alerts'
                ].map((f) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.check,
                              color: Color(0xFF5EEAD4), size: 20),
                          const SizedBox(width: 12),
                          Text(f,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$15.00',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(width: 6),
                          Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Text('/ per trip',
                                style: TextStyle(
                                    color: Color(0xFF99F6E4), fontSize: 14)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...[
                        'Full trip coverage',
                        'Priority concierge access',
                        'Emergency relocation guarantee',
                        'Dispute resolution support'
                      ].map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.check,
                                    color: Color(0xFF5EEAD4), size: 18),
                                const SizedBox(width: 10),
                                Text(item,
                                    style: const TextStyle(
                                        color: Color(0xFFCCFBF1),
                                        fontSize: 14)),
                              ],
                            ),
                          )),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () => context.push('/subscription-plans'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryDark,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                          ),
                          child: const Text('Activate My Guardian',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
