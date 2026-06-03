import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/payment_service.dart';

class ServicePaywallScreen extends StatefulWidget {
  final String serviceType;
  final String serviceName;
  final double fee;
  final Map<String, String> answers;
  const ServicePaywallScreen({
    super.key,
    required this.serviceType,
    required this.serviceName,
    required this.fee,
    required this.answers,
  });

  @override
  State<ServicePaywallScreen> createState() => _ServicePaywallScreenState();
}

class _ServicePaywallScreenState extends State<ServicePaywallScreen> {
  bool _processing = false;
  bool _paymentStarted = false;
  bool _paymentVerified = false;
  String _paymentReference = '';
  String _paymentError = '';
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (['tours', 'dining', 'flights'].contains(widget.serviceType)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _goToResults();
      });
    }
  }

  void _goToResults() {
    context.push('/service-results', extra: {
      'type': widget.serviceType,
      'answers': widget.answers,
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String get _feeDisplay {
    return '\$${widget.fee.toStringAsFixed(0)}';
  }

  Future<void> _handlePayment() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _paymentError = 'Enter a valid email address to proceed.');
      return;
    }

    setState(() {
      _processing = true;
      _paymentError = '';
    });

    final result = await PaymentService().startPaystackCheckout(
      email: email,
      usdAmount: widget.fee,
      metadata: {
        'type': widget.serviceType,
        'service': widget.serviceName,
        'email': email,
      },
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _processing = false;
        _paymentStarted = true;
        _paymentReference = result['reference'] as String? ?? '';
      });
    } else {
      setState(() {
        _processing = false;
        _paymentError = result['message'] as String? ?? 'Payment failed.';
      });
    }
  }

  Future<void> _verifyPayment() async {
    if (_paymentReference.isEmpty) return;

    setState(() {
      _processing = true;
      _paymentError = '';
    });

    final verified =
        await PaymentService().completePaystackPayment(_paymentReference);

    if (!mounted) return;

    if (verified) {
      setState(() {
        _processing = false;
        _paymentVerified = true;
      });
    } else {
      setState(() {
        _processing = false;
        _paymentError = 'Payment verification failed. Please try again.';
      });
    }
  }

  Future<void> _openWhatsApp() async {
    final message = _buildWhatsAppMessage();
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/2348000000000?text=$encoded');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }

    if (mounted) {
      context.go('/');
    }
  }

  String _buildWhatsAppMessage() {
    final details = widget.answers.entries
        .map((e) => '${_formatKey(e.key)}: ${e.value}')
        .join('\n');

    return 'Hi GeesTrip! I\'ve paid the $_feeDisplay request fee for *${widget.serviceName}*.\n\n'
        'My details:\n$details\n\n'
        'Please connect me. My payment reference: $_paymentReference';
  }

  @override
  Widget build(BuildContext context) {
    if (['tours', 'dining', 'flights'].contains(widget.serviceType)) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 24),
              Text('Loading results...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    // Payment verified — show success
    if (_paymentVerified) {
      return _buildSuccessScreen();
    }

    return _buildPaywall();
  }

  // ─── SUCCESS SCREEN ───
  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.check,
                    color: Colors.white,
                    size: 48,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 32),

                const Text(
                  'Payment Confirmed!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                const SizedBox(height: 12),

                Text(
                  'Your $_feeDisplay request fee has been received.\nWe\'ll connect you via WhatsApp shortly.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                const SizedBox(height: 32),

                // Reference card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.receipt,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Reference',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _paymentReference,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                const SizedBox(height: 32),

                // WhatsApp button
                GestureDetector(
                  onTap: _openWhatsApp,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25D366).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.messageCircle,
                            color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Continue on WhatsApp',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 700.ms),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Text(
                    'Go to Home',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.primary.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── PAYWALL ───
  Widget _buildPaywall() {
    final isCompanion = widget.serviceType == 'companion';
    final gradient = isCompanion
        ? const [Color(0xFFBE185D), Color(0xFFEC4899)]
        : const [Color(0xFF1F3BB3), Color(0xFF3B5CF6)];
    final icon = isCompanion ? LucideIcons.users : LucideIcons.car;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
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
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withOpacity(0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 36),
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

              const SizedBox(height: 24),

              // Title
              Center(
                child: Text(
                  isCompanion ? 'Request Availability' : 'Reserve Your Ride',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  isCompanion
                      ? 'Pay $_feeDisplay to request ${widget.serviceName}. We\'ll connect you via WhatsApp within 15 minutes.'
                      : 'A $_feeDisplay deposit reserves your ride. We\'ll find the best drivers for you.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Details card
              if (widget.answers.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: gradient.first.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              LucideIcons.clipboardList,
                              color: gradient.first,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Your Request Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ..._getSummaryRows(),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Email field
              Container(
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
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(
                      LucideIcons.mail,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),

              if (_paymentError.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.alertCircle,
                          color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _paymentError,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Pay button
              if (!_paymentStarted)
                GestureDetector(
                  onTap: _processing ? null : _handlePayment,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.first.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _processing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.lock,
                                    color: Colors.white70, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Pay $_feeDisplay to Continue',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

              // Verify payment
              if (_paymentStarted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              LucideIcons.clock,
                              color: AppColors.accentGold,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Payment in progress',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Complete the payment on the Paystack page, then verify to continue.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Reference: $_paymentReference',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _processing ? null : _verifyPayment,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF34D399)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: _processing
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(LucideIcons.shieldCheck,
                                          color: Colors.white, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Verify Payment',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
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

              const SizedBox(height: 20),

              // Trust badge
              const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.shield,
                        color: AppColors.textMuted, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Secured by GeesTrip',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getSummaryRows() {
    return widget.answers.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 3),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${_formatKey(entry.key)}: ${entry.value}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatKey(String key) {
    switch (key) {
      case 'pickup':
        return 'Pickup';
      case 'dropoff':
        return 'Dropoff';
      case 'datetime':
        return 'Date & Time';
      case 'passengers':
        return 'Passengers';
      case 'city':
        return 'City';
      case 'interests':
        return 'Interests';
      case 'groupSize':
        return 'Group Size';
      case 'duration':
        return 'Duration';
      case 'type':
        return 'Companion Type';
      case 'occasion':
        return 'Occasion';
      case 'preferences':
        return 'Preferences';
      case 'cuisine':
        return 'Cuisine';
      case 'guests':
        return 'Guests';
      case 'from':
        return 'From';
      case 'to':
        return 'To';
      case 'departDate':
        return 'Departure';
      case 'returnDate':
        return 'Return';
      case 'notes':
        return 'Notes';
      case 'companion_name':
        return 'Companion';
      default:
        return key;
    }
  }
}
