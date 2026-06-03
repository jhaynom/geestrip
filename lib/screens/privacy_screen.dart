import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/content_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  late final Future<List<Map<String, dynamic>>> _privacyFuture;

  @override
  void initState() {
    super.initState();
    _privacyFuture = _loadPrivacyContent();
  }

  Future<List<Map<String, dynamic>>> _loadPrivacyContent() async {
    final page = await ContentService().fetchPage(slug: 'privacy');
    if (page == null ||
        page['body'] == null ||
        page['body'].toString().isEmpty) {
      return [
        {
          'title': 'Information We Collect',
          'items': [
            'Name and contact details',
            'Travel preferences and history',
            'Payment information (processed securely by Paystack)',
            'Device and usage data',
          ],
        },
        {
          'title': 'How We Use Your Data',
          'items': [
            'To process bookings and reservations',
            'To personalize travel recommendations',
            'To communicate booking confirmations',
            'To improve our services',
            'To comply with legal obligations',
          ],
        },
        {
          'title': 'Data Protection',
          'items': [
            'All data is encrypted in transit and at rest',
            'Payment data is handled by Paystack (PCI DSS compliant)',
            'We never sell your personal information',
            'You can request data deletion anytime',
          ],
        },
        {
          'title': 'Your Rights',
          'items': [
            'Access your personal data',
            'Correct inaccurate data',
            'Delete your account and data',
            'Opt out of marketing communications',
            'Data portability',
          ],
        },
      ];
    }
    final body = page['body']?.toString() ?? '';
    final blocks = body.split('\n\n').map((block) {
      final lines = block.split('\n');
      return {
        'title': lines.first,
        'items': lines.skip(1).toList(),
      };
    }).toList();
    return blocks.isNotEmpty
        ? blocks
        : [
            {
              'title': page['title']?.toString() ?? 'Privacy Policy',
              'items': [body],
            }
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04), blurRadius: 10)
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: AppColors.bgPrimary,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(LucideIcons.arrowLeft,
                          size: 22, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text('Privacy Policy',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _privacyFuture,
                builder: (context, snapshot) {
                  final sections = snapshot.data ?? [];
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final section in sections)
                          _PrivacySection(
                            title: section['title']?.toString() ?? '',
                            items: (section['items'] as List<dynamic>?)
                                    ?.map((item) => item.toString())
                                    .toList() ??
                                [],
                          ),
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlueLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(LucideIcons.shield,
                                  color: AppColors.primary, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Your data is protected. We use industry-standard security measures to keep your information safe.',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  final String title;
  final List<String> items;
  const _PrivacySection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.check,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
