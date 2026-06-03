import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/content_service.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expandedIndex;
  late final Future<List<Map<String, String>>> _faqFuture;

  final List<Map<String, String>> _fallbackFaqs = [
    {
      'q': 'How does GeesTrip work?',
      'a':
          'GeesTrip is your personal travel concierge. Tell us what you need — hotels, flights, tours — and we handle everything. You can reserve with a small verification fee and pay at the hotel after seeing your room.'
    },
    {
      'q': 'Is my payment secure?',
      'a':
          'Yes! All payments are processed securely through Paystack, a PCI DSS compliant payment gateway. Your card details are never stored on our servers.'
    },
    {
      'q': 'What is the verification fee?',
      'a':
          'The verification fee (₦2,000-₦10,000 depending on service level) confirms your identity and secures your reservation. It covers our concierge service and is non-refundable.'
    },
    {
      'q': 'Can I pay at the hotel?',
      'a':
          'Yes! With Quick Reserve, you only pay the verification fee now. The room charge is paid directly at the hotel after seeing your room.'
    },
    {
      'q': 'What is Trip Guardian?',
      'a':
          'Trip Guardian is our 24/7 protection service. It includes emergency support, dispute resolution, and instant relocation if your accommodation is unsatisfactory. ₦15,000 per trip or FREE with Explorer/Globetrotter subscriptions.'
    },
    {
      'q': 'How do subscriptions work?',
      'a':
          'Subscribe to Traveler Lite (3 months/₦50,000), Explorer (6 months/₦85,000), or Globetrotter (12 months/₦150,000) for unlimited bookings with free verification and premium features.'
    },
    {
      'q': 'Can I cancel a booking?',
      'a':
          'Cancellation policies vary by hotel. Check the specific policy before booking. Verification fees are non-refundable as they cover services already rendered.'
    },
    {
      'q': 'How do I contact support?',
      'a':
          'Chat with our virtual assistant 24/7, request a live agent, call +234 800 GEESTRIP, or email support@geestrip.com. Explorer and Globetrotter subscribers get priority support.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _faqFuture = _loadFaqs();
  }

  Future<List<Map<String, String>>> _loadFaqs() async {
    final entries = await ContentService().fetchFaqs();
    if (entries.isEmpty) return _fallbackFaqs;
    return entries
        .map((entry) => {
              'q': entry['title']?.toString() ?? '',
              'a': entry['body']?.toString() ?? '',
            })
        .where((faq) => faq['q']!.isNotEmpty && faq['a']!.isNotEmpty)
        .toList();
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
                    child: Text('FAQ',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary))),
              ]),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: _faqFuture,
                builder: (context, snapshot) {
                  final faqs = snapshot.data ?? _fallbackFaqs;
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: faqs.length,
                    itemBuilder: (context, index) {
                      final isExpanded = _expandedIndex == index;
                      return GestureDetector(
                        onTap: () => setState(
                            () => _expandedIndex = isExpanded ? null : index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: AppColors.bgWhite,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8)
                              ],
                              border: isExpanded
                                  ? Border.all(
                                      color: AppColors.primary, width: 1)
                                  : null),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                      child: Text(faqs[index]['q']!,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: isExpanded
                                                  ? AppColors.primary
                                                  : AppColors.textPrimary))),
                                  Icon(
                                      isExpanded
                                          ? LucideIcons.chevronUp
                                          : LucideIcons.chevronDown,
                                      color: isExpanded
                                          ? AppColors.primary
                                          : AppColors.textMuted,
                                      size: 20),
                                ]),
                                if (isExpanded) ...[
                                  const SizedBox(height: 12),
                                  Text(faqs[index]['a']!,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                          height: 1.5))
                                ],
                              ]),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                          .moveY(begin: 10);
                    },
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
