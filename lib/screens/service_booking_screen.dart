import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/booking_service.dart';
import '../widgets/contact_method_selector.dart';

class ServiceBookingScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  const ServiceBookingScreen({super.key, required this.bookingData});

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  bool _isProcessing = false;
  bool _bookingSuccess = false;
  String _reference = '';

  @override
  void initState() {
    super.initState();
    _reference =
        'GEE-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }

  void _confirmBooking() async {
    final item = widget.bookingData['item'] as Map<String, dynamic>? ?? {};
    final serviceType = widget.bookingData['type'] as String? ?? 'service';

    // Show contact method modal and save a request record
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) {
          ContactMethod method = ContactMethod.whatsapp;
          final TextEditingController contactController =
              TextEditingController();
          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: MediaQuery.of(ctx).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('How should we contact you?',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  ContactMethodSelector(
                      selectedMethod: method,
                      onChanged: (m) {
                        setState(() {
                          method = m;
                          contactController.text = '';
                        });
                      }),
                  const SizedBox(height: 12),
                  if (method == ContactMethod.whatsapp)
                    TextField(
                      controller: contactController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                          hintText: 'WhatsApp number',
                          filled: true,
                          fillColor: AppColors.bgWhite,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none)),
                    ),
                  if (method == ContactMethod.email)
                    TextField(
                      controller: contactController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          hintText: 'Email address',
                          filled: true,
                          fillColor: AppColors.bgWhite,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none)),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        BookingService().addBooking({
                          'type': serviceType,
                          'name': item['name'] ?? _getServiceLabel(),
                          'detail': item['detail'] ?? item['price'] ?? '',
                          'price': item['price'] ?? item['rate'] ?? '',
                          'status': 'requested',
                          'contact_method': method.name,
                          'contact_value': contactController.text.trim(),
                        });

                        Navigator.of(ctx).pop();
                        setState(() {
                          _bookingSuccess = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Request Processing',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ]),
              ),
            );
          });
        });
  }

  String _getServiceLabel() {
    switch (widget.bookingData['type']) {
      case 'shuttle':
        return 'Shuttle Ride';
      case 'tours':
        return 'Tour Booking';
      case 'companion':
        return 'Companion Booking';
      case 'dining':
        return 'Dining Reservation';
      case 'flights':
        return 'Flight Booking';
      default:
        return 'Service';
    }
  }

  String _getIconName(String type) {
    switch (type) {
      case 'shuttle':
        return 'car';
      case 'tours':
        return 'map';
      case 'companion':
        return 'users';
      case 'dining':
        return 'utensilsCrossed';
      case 'flights':
        return 'plane';
      default:
        return 'sparkles';
    }
  }

  List<int> _getGradient(String type) {
    switch (type) {
      case 'shuttle':
        return [0xFF1F3BB3, 0xFF3B5CF6];
      case 'tours':
        return [0xFF059669, 0xFF10B981];
      case 'companion':
        return [0xFFBE185D, 0xFFEC4899];
      case 'dining':
        return [0xFFDC2626, 0xFFF43F5E];
      case 'flights':
        return [0xFF2563EB, 0xFF60A5FA];
      default:
        return [0xFF1F3BB3, 0xFF3B5CF6];
    }
  }

  IconData _getServiceIcon() {
    switch (widget.bookingData['type']) {
      case 'shuttle':
        return LucideIcons.car;
      case 'tours':
        return LucideIcons.map;
      case 'companion':
        return LucideIcons.users;
      case 'dining':
        return LucideIcons.utensilsCrossed;
      case 'flights':
        return LucideIcons.plane;
      default:
        return LucideIcons.sparkles;
    }
  }

  String _getNextSteps() {
    switch (widget.bookingData['type']) {
      case 'shuttle':
        return 'Our team will confirm your driver and share pickup details within 15 minutes. Your driver will be at the pickup location at the scheduled time.';
      case 'tours':
        return 'Your tour guide will contact you with meeting point details. Please check your email for the itinerary.';
      case 'companion':
        return 'We are matching you with the perfect companion. Our team will share profile details and contact information within 30 minutes.';
      case 'dining':
        return 'Your reservation is being processed. We will confirm your table and send you the restaurant details shortly.';
      case 'flights':
        return 'Your flight booking is being processed. We will send you the e-ticket and booking confirmation within 1 hour.';
      default:
        return 'Our team will contact you shortly with full details.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.bookingData['item'] as Map<String, dynamic>? ?? {};
    final serviceType = widget.bookingData['type'] as String? ?? 'service';
    final serviceName = item['name'] ?? 'Service';
    final serviceDetail = item['detail'] ?? '';
    final servicePrice = item['price'] ?? item['rate'] ?? '';
    final isFreeService = ['tours', 'dining', 'flights'].contains(serviceType);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Back button
            if (!_bookingSuccess)
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

            // ─── CONFIRMATION FORM ───
            if (!_bookingSuccess && !_isProcessing) ...[
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: Color(_getGradient(serviceType)[0]).value !=
                                  null
                              ? [
                                  Color(_getGradient(serviceType)[0]),
                                  Color(_getGradient(serviceType)[1])
                                ]
                              : [AppColors.primary, const Color(0xFF3B5CF6)]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10))
                      ]),
                  child: Icon(_getServiceIcon(), color: Colors.white, size: 48),
                ),
              ),
              const SizedBox(height: 32),
              Text('Confirm ${_getServiceLabel()}',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                  isFreeService
                      ? 'We\'ll handle this for you'
                      : 'Review your selection',
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),

              // Service details card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04), blurRadius: 12)
                    ]),
                child: Column(children: [
                  _DetailRow(label: 'Service', value: _getServiceLabel()),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Provider', value: serviceName.toString()),
                  if (serviceDetail.toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _DetailRow(
                        label: 'Details', value: serviceDetail.toString())
                  ],
                  if (servicePrice.toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _DetailRow(
                        label: isFreeService ? 'Price (paid at venue)' : 'Rate',
                        value: servicePrice.toString())
                  ],
                  if (isFreeService) ...[
                    const SizedBox(height: 12),
                    _DetailRow(
                        label: 'Booking Fee',
                        value: serviceType == 'flights' ? '\$5.00' : '\$2.00',
                        bold: true),
                  ],
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Reference', value: _reference),
                ]),
              ),

              const SizedBox(height: 12),
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
                      child: Text(_getNextSteps(),
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500))),
                ]),
              ),

              const SizedBox(height: 24),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text('Confirm ${_getServiceLabel()}',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                ),
              ),
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
                  Text('Confirming your ${_getServiceLabel().toLowerCase()}',
                      style: const TextStyle(
                          fontSize: 15, color: AppColors.textSecondary)),
                ]),
              ),

            // ─── SUCCESS ───
            if (_bookingSuccess) ...[
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
              const Text('Booking Confirmed! 🎉',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Your ${_getServiceLabel().toLowerCase()} has been booked.',
                  style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center),
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
                  _DetailRow(label: 'Service', value: _getServiceLabel()),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Provider', value: serviceName.toString()),
                  if (servicePrice.toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _DetailRow(label: 'Rate', value: servicePrice.toString())
                  ],
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Reference', value: _reference, bold: true),
                ]),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.accentGreenLight,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(LucideIcons.checkCircle,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_getNextSteps(),
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
