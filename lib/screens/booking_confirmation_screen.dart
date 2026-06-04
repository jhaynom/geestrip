import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  const BookingConfirmationScreen({super.key, required this.bookingData});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isProcessing = false;
  bool _paymentSuccess = false;
  String _reference = '';
  PaymentTier _selectedTier = PaymentTier.quickReserve;
  SubscriptionPlan _selectedSubscriptionPlan = SubscriptionPlan.explorer;
  final _service = PaymentService();
  String _paymentReference = '';
  late TextEditingController _emailController;

  bool get _isSubscription => widget.bookingData['type'] == 'subscription';

  SubscriptionPlan _planFromName(String? planName) {
    if (planName == null || planName.isEmpty) return SubscriptionPlan.explorer;
    try {
      return SubscriptionPlan.values
          .firstWhere((plan) => plan.name == planName);
    } catch (_) {
      return SubscriptionPlan.explorer;
    }
  }

  @override
  void initState() {
    super.initState();
    _reference = _service.generateReference();
    _emailController = TextEditingController();
    _selectedSubscriptionPlan =
        _planFromName(widget.bookingData['plan']?.toString() ?? 'explorer');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _initiatePayment(PaymentTier tier) async {
    setState(() {
      _isProcessing = true;
      _selectedTier = tier;
    });

    // require email for payment receipt
    final email = (_emailController.text).trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enter a valid email address to proceed')));
      return;
    }

    final result = await PaymentService().startPaystackCheckout(
      email: email,
      usdAmount: _service.getBookingFee(tier),
      metadata: {'type': 'hotel', 'tier': tier.name},
    );

    if (!mounted) return;

    if (result['success'] == true) {
      // store reference and prompt verification
      _paymentReference = result['reference'] as String? ?? '';
      setState(() {
        _isProcessing = false;
      });
      // Show verify dialog
      showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (ctx) {
            return Padding(
              padding: MediaQuery.of(ctx).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Payment started',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  const Text(
                      'A Paystack page opened. Complete the payment and then tap Verify to confirm your reservation.',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          setState(() {
                            _isProcessing = true;
                          });
                          final ok = await PaymentService()
                              .completePaystackPayment(_paymentReference);
                          if (!mounted) return;
                          if (ok) {
                            BookingService().addBooking({
                              'type': 'hotel',
                              'name': widget.bookingData['name'] ?? 'Hotel',
                              'detail': widget.bookingData['detail'] ?? '',
                              'price': widget.bookingData['price'] ?? '',
                              'tier': tier.name,
                              'reference': _paymentReference,
                              'status': 'confirmed',
                            });
                            setState(() {
                              _isProcessing = false;
                              _paymentSuccess = true;
                            });
                          } else {
                            setState(() {
                              _isProcessing = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Payment verification failed.')));
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Verify Payment',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        )),
                  )
                ]),
              ),
            );
          });
    } else {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] as String? ?? 'Payment failed')));
    }
  }

  void _initiateSubscriptionPayment() async {
    setState(() {
      _isProcessing = true;
    });

    final email = (_emailController.text).trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enter a valid email address to proceed')));
      return;
    }

    await _service.processSubscriptionPayment(
      email: email,
      plan: _selectedSubscriptionPlan,
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
          _paymentSuccess = true;
        });
      },
      onError: () {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Subscription payment could not be completed.')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemName = widget.bookingData['name'] ?? 'Service';
    final itemDetail = widget.bookingData['detail'] ?? '';
    final itemPrice = widget.bookingData['price'] ?? '';
    final planPrice = _service.getPlanPrice(_selectedSubscriptionPlan);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Back button
            if (!_paymentSuccess)
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

            // ─── PAYMENT SELECTION ───
            if (!_paymentSuccess && !_isProcessing) ...[
              Center(
                child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF3B5CF6)]),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10))
                        ]),
                    child: const Icon(LucideIcons.building2,
                        color: Colors.white, size: 48)),
              ),
              const SizedBox(height: 32),
              Text(
                _isSubscription
                    ? 'Confirm Subscription'
                    : 'Confirm Hotel Reservation',
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _isSubscription
                    ? 'Complete your plan purchase with secure payment'
                    : 'Choose how you\'d like to reserve',
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04), blurRadius: 12)
                    ]),
                child: Row(children: [
                  Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(LucideIcons.building2,
                          color: AppColors.primary, size: 24)),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(itemName,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Row(children: [
                          const Icon(LucideIcons.mapPin,
                              size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                              child: Text(itemDetail,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted)))
                        ]),
                        const SizedBox(height: 4),
                        Text(
                            _isSubscription
                                ? 'Subscription: $planPrice'
                                : 'Hotel rate: $itemPrice',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      ])),
                ]),
              ),

              const SizedBox(height: 24),
              Text(
                _isSubscription
                    ? 'Subscription details'
                    : 'Select Reservation Type',
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),

              if (_isSubscription) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _initiateSubscriptionPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Pay $planPrice',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                _TierOption(
                  tier: PaymentTier.quickReserve,
                  isSelected: _selectedTier == PaymentTier.quickReserve,
                  onTap: () => _initiatePayment(PaymentTier.quickReserve),
                ),
                const SizedBox(height: 10),
                _TierOption(
                  tier: PaymentTier.premiumReserve,
                  isSelected: _selectedTier == PaymentTier.premiumReserve,
                  onTap: () => _initiatePayment(PaymentTier.premiumReserve),
                ),
                const SizedBox(height: 10),
                _TierOption(
                  tier: PaymentTier.fullService,
                  isSelected: _selectedTier == PaymentTier.fullService,
                  onTap: () => _initiatePayment(PaymentTier.fullService),
                ),
              ],
            ],

            // ─── PROCESSING ───
            if (_isProcessing)
              Center(
                child: Column(children: [
                  Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.primary, Color(0xFF3B5CF6)]),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 10))
                          ]),
                      child: const Padding(
                          padding: EdgeInsets.all(25),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3))),
                  const SizedBox(height: 32),
                  const Text('Processing...',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('Confirming your reservation',
                      style: TextStyle(
                          fontSize: 15, color: AppColors.textSecondary)),
                ]),
              ),

            // ─── SUCCESS ───
            if (_paymentSuccess) ...[
              Center(
                child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [AppColors.success, Color(0xFF4ADE80)]),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.success.withOpacity(0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10))
                            ]),
                        child: const Icon(LucideIcons.check,
                            color: Colors.white, size: 48))
                    .animate()
                    .scale(
                        duration: 500.ms,
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1))
                    .then()
                    .shake(duration: 400.ms),
              ),
              const SizedBox(height: 32),
              Text(
                _isSubscription
                    ? 'Subscription Confirmed! 🎉'
                    : 'Reservation Confirmed! 🎉',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _isSubscription
                    ? 'Your plan is now active and ready for your next trip.'
                    : 'Your hotel has been reserved successfully.',
                style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04), blurRadius: 16)
                    ]),
                child: Column(children: [
                  _DetailRow(
                      label: _isSubscription ? 'Plan' : 'Hotel',
                      value: itemName),
                  const SizedBox(height: 12),
                  _DetailRow(
                      label: _isSubscription ? 'Details' : 'Room',
                      value: itemDetail),
                  const SizedBox(height: 12),
                  _DetailRow(
                      label: _isSubscription ? 'Price' : 'Hotel Rate',
                      value: _isSubscription ? planPrice : itemPrice),
                  const SizedBox(height: 12),
                  if (!_isSubscription) ...[
                    _DetailRow(
                        label: 'Reservation Fee',
                        value: _service.getTierPrice(_selectedTier)),
                    const Divider(height: 24),
                    _DetailRow(
                        label: 'Reference', value: _reference, bold: true),
                  ] else ...[
                    _DetailRow(label: 'Status', value: 'Active', bold: true),
                  ],
                ]),
              ),
              const SizedBox(height: 12),
              if (!_isSubscription)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.accentBlueLight,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(LucideIcons.info,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            'Show reference $_reference at check-in. Pay balance at the hotel after inspecting your room.',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500))),
                  ]),
                ),
              if (_isSubscription)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.accentGreenLight,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(LucideIcons.info,
                        color: AppColors.success, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            'Your subscription is active and can be used immediately for new bookings.',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.success,
                                fontWeight: FontWeight.w500))),
                  ]),
                ),
              const SizedBox(height: 32),
              Row(children: [
                Expanded(
                    child: GestureDetector(
                        onTap: () => context.push('/my-bookings'),
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                                color: AppColors.bgWhite,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8)
                                ]),
                            child: const Center(
                                child: Text('View Bookings',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary)))))),
                const SizedBox(width: 12),
                Expanded(
                    child: GestureDetector(
                        onTap: () => context.go('/'),
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFF1F3BB3),
                                  Color(0xFF3B5CF6)
                                ]),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6))
                                ]),
                            child: const Center(
                                child: Text('Back to Home',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)))))),
              ]),
            ],
          ]),
        ),
      ),
    );
  }
}

class _TierOption extends StatelessWidget {
  final PaymentTier tier;
  final bool isSelected;
  final VoidCallback onTap;

  const _TierOption(
      {required this.tier, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final service = PaymentService();
    String subtitle;
    switch (tier) {
      case PaymentTier.quickReserve:
        subtitle = 'Reserve now, pay at check-in after seeing your room';
        break;
      case PaymentTier.premiumReserve:
        subtitle = 'Priority booking, room upgrade requests, late checkout';
        break;
      case PaymentTier.fullService:
        subtitle = 'We handle everything - booking, check-in, special requests';
        break;
      default:
        subtitle = '';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: isSelected ? 2 : 0),
          boxShadow: [
            BoxShadow(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 8)
          ],
        ),
        child: Row(children: [
          Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(
                  isSelected ? LucideIcons.checkCircle : LucideIcons.shield,
                  color: AppColors.primary,
                  size: 22)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(service.getTierLabel(tier),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ])),
          Text(service.getTierPrice(tier),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _DetailRow(
      {required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label,
          style: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500)),
      Text(value,
          style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              color: bold ? AppColors.primary : AppColors.textPrimary)),
    ]);
  }
}
