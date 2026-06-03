import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(LucideIcons.arrowLeft,
                              size: 22, color: AppColors.textSecondary))),
                  const SizedBox(width: 14),
                  const Expanded(
                      child: Text('Payment Methods',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary))),
                  GestureDetector(
                      onTap: () {},
                      child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(LucideIcons.plus,
                              color: Colors.white, size: 20))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _PaymentCard(
                      icon: LucideIcons.creditCard,
                      title: 'Credit / Debit Card',
                      subtitle: 'Visa, Mastercard, Verve',
                      color: AppColors.primary,
                      isDefault: true),
                  const SizedBox(height: 10),
                  _PaymentCard(
                      icon: LucideIcons.smartphone,
                      title: 'Mobile Money',
                      subtitle: 'MTN MoMo, Airtel Money',
                      color: AppColors.accentGold),
                  const SizedBox(height: 10),
                  _PaymentCard(
                      icon: LucideIcons.banknote,
                      title: 'Bank Transfer',
                      subtitle: 'Direct bank deposit',
                      color: AppColors.accentGreen),
                  const SizedBox(height: 10),
                  _PaymentCard(
                      icon: LucideIcons.wallet,
                      title: 'Wallet Balance',
                      subtitle: '\$0.00 available',
                      color: AppColors.primaryLight),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.bgWhite,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8)
                      ]),
                  child: const Row(children: [
                    Icon(LucideIcons.shieldCheck,
                        color: AppColors.success, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            'Your payment information is securely encrypted. We support Flutterwave, Paystack, and Stripe.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w500)))
                  ])),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDefault;
  const _PaymentCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.color,
      this.isDefault = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ]),
      child: Row(
        children: [
          Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted))
              ])),
          if (isDefault)
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('Default',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success))),
        ],
      ),
    );
  }
}
