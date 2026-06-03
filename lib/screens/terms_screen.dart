import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/content_service.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  late final Future<List<Map<String, String>>> _sectionsFuture;

  @override
  void initState() {
    super.initState();
    _sectionsFuture = _loadTerms();
  }

  Future<List<Map<String, String>>> _loadTerms() async {
    final page = await ContentService().fetchPage(slug: 'terms');
    if (page == null ||
        page['body'] == null ||
        page['body'].toString().isEmpty) {
      return [
        {
          'title': '1. Acceptance of Terms',
          'content':
              'By accessing or using GeesTrip, you agree to be bound by these Terms of Service. If you do not agree, please do not use our services.',
        },
        {
          'title': '2. Our Services',
          'content':
              'GeesTrip provides a platform connecting travelers with hotels, flights, tours, and other travel services. We act as an intermediary between you and service providers.',
        },
        {
          'title': '3. Reservations & Payments',
          'content':
              'GeesTrip offers multiple reservation options:\n\n• Quick Reserve (₦2,000): Reserve now, pay at check-in\n• Premium Reserve (₦5,000): Priority booking with upgrades\n• Full Service (₦10,000): Complete trip planning\n• Trip Guardian (₦15,000): 24/7 protection\n\nVerification fees are non-refundable as they cover identity verification and concierge services.',
        },
        {
          'title': '4. Cancellations',
          'content':
              'Cancellation policies vary by hotel. Please review the specific cancellation policy before booking. GeesTrip verification fees are non-refundable.',
        },
        {
          'title': '5. Pay at Hotel',
          'content':
              'For Quick Reserve bookings, payment is made directly at the hotel after room inspection. If the room does not match the description, you may cancel without penalty.',
        },
        {
          'title': '6. Trip Guardian Protection',
          'content':
              'Trip Guardian provides 24/7 emergency support, dispute resolution, and relocation assistance. Coverage begins at booking confirmation and ends at check-out.',
        },
        {
          'title': '7. Privacy',
          'content':
              'We collect and process personal data as described in our Privacy Policy. Your data is encrypted and never shared without consent.',
        },
        {
          'title': '8. Limitation of Liability',
          'content':
              'GeesTrip is not liable for disputes between guests and service providers. We facilitate resolution through our concierge and Trip Guardian services.',
        },
        {
          'title': '9. Contact',
          'content':
              'For questions about these terms, contact us at:\n📧 legal@geestrip.com\n📞 +234 800 GEESTRIP',
        },
      ];
    }

    final body = page['body']?.toString() ?? '';
    final sections = body.split('\n\n').map((chunk) {
      final lines = chunk.split('\n');
      final title = lines.isNotEmpty ? lines.first : 'Section';
      final content = lines.skip(1).join('\n');
      return {
        'title': title,
        'content': content,
      };
    }).toList();

    return sections.isNotEmpty
        ? sections
        : [
            {
              'title': page['title']?.toString() ?? 'Terms',
              'content': body,
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
              decoration: BoxDecoration(color: AppColors.bgWhite, boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
              ]),
              child: Row(children: [
                GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: AppColors.bgPrimary,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(LucideIcons.arrowLeft,
                            size: 22, color: AppColors.textSecondary))),
                const SizedBox(width: 14),
                const Expanded(
                    child: Text('Terms of Service',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary))),
              ]),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: _sectionsFuture,
                builder: (context, snapshot) {
                  final sections = snapshot.data ?? [];
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final section in sections)
                          _Section(
                            title: section['title'] ?? '',
                            content: section['content'] ?? '',
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

class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});

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
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(content,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
      ]),
    );
  }
}
