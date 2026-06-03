import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/payment_service.dart';

class CompanionPaywallScreen extends StatefulWidget {
  final Map<String, String> answers;
  const CompanionPaywallScreen({super.key, required this.answers});

  @override
  State<CompanionPaywallScreen> createState() => _CompanionPaywallScreenState();
}

class _CompanionPaywallScreenState extends State<CompanionPaywallScreen> {
  bool _agreed = false;
  bool _processing = false;
  bool _paymentStarted = false;
  String _paymentRef = '';
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        color: AppColors.bgWhite,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8)
                        ]),
                    child: const Icon(LucideIcons.arrowLeft,
                        size: 22, color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 24),
              // Shield icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFBE185D), Color(0xFFEC4899)]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFBE185D).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  child: const Icon(LucideIcons.shield,
                      color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Access Companion Profiles',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                  'To ensure safety and serious inquiries only, we require a small verification fee before viewing companion profiles.',
                  style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5)),
              const SizedBox(height: 24),

              // Disclaimer Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04), blurRadius: 12)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📋 Important Disclaimer',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    _DisclaimerItem(
                        'All companions are identity-verified and background-checked.'),
                    _DisclaimerItem(
                        'Companions provide professional social companionship only.'),
                    _DisclaimerItem(
                        'Any inappropriate requests will result in permanent ban.'),
                    _DisclaimerItem(
                        'GeesTrip reserves the right to remove any companion.'),
                    _DisclaimerItem(
                        'This fee is non-refundable but ensures quality matches.'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Agreement checkbox
              GestureDetector(
                onTap: () => setState(() => _agreed = !_agreed),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.bgWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8)
                      ]),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color:
                              _agreed ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: _agreed
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              width: 2),
                        ),
                        child: _agreed
                            ? const Icon(LucideIcons.check,
                                color: Colors.white, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                          child: Text(
                              'I understand and agree to the terms above',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary))),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Payment summary
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04), blurRadius: 10)
                    ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Verification Fee',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          Text('One-time payment',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textMuted))
                        ]),
                    const Text('\$2.99',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.bgWhite,
                    hintText: 'Email for payment receipt',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_agreed && !_processing)
                      ? () async {
                          final email = _emailController.text.trim();
                          if (email.isEmpty || !email.contains('@')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Enter a valid email')));
                            return;
                          }
                          setState(() => _processing = true);
                          final result = await PaymentService()
                              .startPaystackCheckout(
                                  email: email,
                                  usdAmount: 2.99,
                                  metadata: {'type': 'companion_access'});
                          if (!mounted) return;
                          setState(() => _processing = false);
                          if (result['success'] == true) {
                            _paymentStarted = true;
                            _paymentRef = result['reference'] ?? '';
                            // navigate to results after payment verification
                            showModalBottomSheet(
                                context: context,
                                builder: (ctx) {
                                  return Padding(
                                    padding: MediaQuery.of(ctx).viewInsets,
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                                'Payment started. Complete payment in the opened page and verify.'),
                                            const SizedBox(height: 12),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.of(ctx).pop();
                                                  setState(
                                                      () => _processing = true);
                                                  final ok = await PaymentService()
                                                      .completePaystackPayment(
                                                          _paymentRef);
                                                  setState(() =>
                                                      _processing = false);
                                                  if (ok) {
                                                    context.push(
                                                        '/service-results',
                                                        extra: {
                                                          'type': 'companion',
                                                          'answers':
                                                              widget.answers
                                                        });
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    'Payment verification failed')));
                                                  }
                                                },
                                                child: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 12),
                                                    child:
                                                        Text('Verify Payment')),
                                              ),
                                            )
                                          ]),
                                    ),
                                  );
                                });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    result['message'] ?? 'Payment failed')));
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBE185D),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.tabInactive,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: _processing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('Pay \$2.99 to View Profiles',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    const Icon(LucideIcons.lock,
                        color: AppColors.textMuted, size: 14),
                    const SizedBox(width: 6),
                    Text('Secured by GeesTrip',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500))
                  ])),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisclaimerItem extends StatelessWidget {
  final String text;
  const _DisclaimerItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.check, color: AppColors.success, size: 16),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4))),
        ],
      ),
    );
  }
}
