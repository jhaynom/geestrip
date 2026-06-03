import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'currency_service.dart';

// ─── PAYMENT TIERS ───
enum PaymentTier {
  quickReserve, // $2.00
  premiumReserve, // $5.00
  fullService, // $10.00
  tripGuardian, // $15.00
}

// ─── SUBSCRIPTION PLANS ───
enum SubscriptionPlan {
  none,
  travelerLite, // $30.00 - 3 months
  explorer, // $50.00 - 6 months
  globetrotter, // $90.00 - 12 months
}

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  static const String _paystackPublicKey =
      'pk_test_e97627c7372cc3040e9a541bb69fbe74c003195f';
  static const String _paystackBaseUrl = 'https://checkout.paystack.com';

  // ─── SUBSCRIPTION STATE ───
  SubscriptionPlan _currentPlan = SubscriptionPlan.none;
  DateTime? _subscriptionExpiry;

  SubscriptionPlan get currentPlan => _currentPlan;
  DateTime? get subscriptionExpiry => _subscriptionExpiry;
  bool get isSubscribed =>
      _currentPlan != SubscriptionPlan.none &&
      (_subscriptionExpiry == null ||
          _subscriptionExpiry!.isAfter(DateTime.now()));
  bool get hasTripGuardian =>
      isSubscribed &&
      (_currentPlan == SubscriptionPlan.explorer ||
          _currentPlan == SubscriptionPlan.globetrotter);

  // ─── PRICING (in USD) ───
  static const Map<PaymentTier, double> tierPrices = {
    PaymentTier.quickReserve: 2.00,
    PaymentTier.premiumReserve: 5.00,
    PaymentTier.fullService: 10.00,
    PaymentTier.tripGuardian: 15.00,
  };

  static const Map<SubscriptionPlan, double> planPrices = {
    SubscriptionPlan.travelerLite: 30.00,
    SubscriptionPlan.explorer: 50.00,
    SubscriptionPlan.globetrotter: 90.00,
  };

  static const Map<SubscriptionPlan, int> planDurationMonths = {
    SubscriptionPlan.travelerLite: 3,
    SubscriptionPlan.explorer: 6,
    SubscriptionPlan.globetrotter: 12,
  };

  // ─── FORMATTING ───
  String formatUSD(double amountUSD) {
    return CurrencyService().formatPrice(amountUSD);
  }

  String getTierPrice(PaymentTier tier) => formatUSD(tierPrices[tier]!);
  String getPlanPrice(SubscriptionPlan plan) => formatUSD(planPrices[plan]!);
  int getPlanDuration(SubscriptionPlan plan) => planDurationMonths[plan]!;

  String getTierLabel(PaymentTier tier) {
    switch (tier) {
      case PaymentTier.quickReserve:
        return 'Quick Reserve';
      case PaymentTier.premiumReserve:
        return 'Premium Reserve';
      case PaymentTier.fullService:
        return 'Full Service';
      case PaymentTier.tripGuardian:
        return 'Trip Guardian';
    }
  }

  String getTierDescription(PaymentTier tier) {
    switch (tier) {
      case PaymentTier.quickReserve:
        return 'Reserve your room instantly. Pay at check-in after seeing the room.';
      case PaymentTier.premiumReserve:
        return 'Priority booking, room upgrade requests, late checkout included.';
      case PaymentTier.fullService:
        return 'Complete trip planning, multiple bookings, airport pickup coordination.';
      case PaymentTier.tripGuardian:
        return '24/7 protection, emergency relocation, dispute resolution.';
    }
  }

  String getPlanLabel(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.travelerLite:
        return 'Traveler Lite';
      case SubscriptionPlan.explorer:
        return 'Explorer';
      case SubscriptionPlan.globetrotter:
        return 'Globetrotter';
      case SubscriptionPlan.none:
        return 'No Plan';
    }
  }

  List<String> getPlanFeatures(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.travelerLite:
        return [
          'Unlimited hotel reservations',
          'Free verification on all bookings',
          'Standard concierge support',
          'Pay-at-hotel option'
        ];
      case SubscriptionPlan.explorer:
        return [
          'All Traveler Lite features',
          'Trip Guardian (up to 5 trips)',
          'Priority concierge',
          'Room upgrade requests'
        ];
      case SubscriptionPlan.globetrotter:
        return [
          'All Explorer features',
          'Unlimited Trip Guardian',
          'VIP support line',
          'Personal travel manager',
          'Exclusive deals',
          'Free airport pickup coordination'
        ];
      case SubscriptionPlan.none:
        return [];
    }
  }

  // ─── CORE PAYMENT ───
  String generateReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 100000).toString().padLeft(5, '0');
    return 'GEE-$timestamp-$random';
  }

  double usdToNgn(double usd) => usd * 1600;

  Future<Map<String, dynamic>> startPaystackCheckout({
    required String email,
    required double usdAmount,
    String currency = 'NGN',
    String? reference,
    Map<String, dynamic>? metadata,
  }) async {
    final ref = reference ?? generateReference();
    final ngnAmount = (usdToNgn(usdAmount) * 100).toInt();

    final params = {
      'key': _paystackPublicKey,
      'email': email,
      'amount': ngnAmount.toString(),
      'reference': ref,
      'currency': currency,
      if (metadata != null && metadata.isNotEmpty)
        'metadata': jsonEncode(metadata),
    };

    final uri = Uri.https(
        _paystackBaseUrl.replaceFirst('https://', ''), '/pay', params);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      return {'success': false, 'message': 'Unable to open payment page'};
    }

    return {
      'success': true,
      'reference': ref,
      'payment_url': uri.toString(),
    };
  }

  Future<bool> completePaystackPayment(String reference) async {
    // Verify the payment status from the Supabase payments table.
    // This assumes a webhook or backend/edge function updates the payment record
    // after Paystack confirms the transaction.
    return await verifyPayment(reference);
  }

  Future<bool> _updatePaymentStatus(String reference, String status) async {
    try {
      await _client
          .from('payments')
          .update({'status': status}).eq('reference', reference);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── PROCESS PAYMENT FOR BOOKING ───
  Future<void> processBookingPayment({
    required String email,
    required PaymentTier tier,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    final usdAmount = tierPrices[tier]!;
    final reference = generateReference();

    try {
      final result = await startPaystackCheckout(
        email: email,
        usdAmount: usdAmount,
        reference: reference,
        metadata: {
          'type': 'booking',
          'tier': tier.name,
          'usdAmount': usdAmount,
        },
      );

      if (result['success'] == true) {
        await _savePaymentRecord(
          email: email,
          amount: (usdToNgn(usdAmount) * 100).toInt(),
          currency: 'NGN',
          reference: reference,
          paystackRef: reference,
          paymentType: 'booking',
          tier: tier.name,
        );
        onSuccess();
      } else {
        onError();
      }
    } catch (e) {
      onError();
    }
  }

  // ─── PROCESS SUBSCRIPTION PAYMENT ───
  Future<void> processSubscriptionPayment({
    required String email,
    required SubscriptionPlan plan,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    final usdAmount = planPrices[plan]!;
    final reference = generateReference();

    try {
      final result = await startPaystackCheckout(
        email: email,
        usdAmount: usdAmount,
        reference: reference,
        metadata: {
          'type': 'subscription',
          'plan': plan.name,
          'usdAmount': usdAmount,
        },
      );

      if (result['success'] == true) {
        final ngnAmount = (usdToNgn(usdAmount) * 100).toInt();
        await _savePaymentRecord(
          email: email,
          amount: ngnAmount,
          currency: 'NGN',
          reference: reference,
          paystackRef: reference,
          paymentType: 'subscription',
          tier: plan.name,
        );
        _currentPlan = plan;
        _subscriptionExpiry =
            DateTime.now().add(Duration(days: 30 * planDurationMonths[plan]!));
        onSuccess();
      } else {
        onError();
      }
    } catch (e) {
      onError();
    }
  }

  // ─── CHECK IF BOOKING IS FREE FOR SUBSCRIBER ───
  bool isBookingFreeForSubscriber(PaymentTier tier) {
    if (!isSubscribed) return false;
    // Subscribers get Quick Reserve free
    if (tier == PaymentTier.quickReserve) return true;
    // Explorer & Globetrotter get Premium Reserve free
    if (tier == PaymentTier.premiumReserve &&
        (_currentPlan == SubscriptionPlan.explorer ||
            _currentPlan == SubscriptionPlan.globetrotter)) return true;
    // Globetrotter gets Full Service free
    if (tier == PaymentTier.fullService &&
        _currentPlan == SubscriptionPlan.globetrotter) return true;
    // Explorer & Globetrotter get Trip Guardian free (limited for explorer)
    if (tier == PaymentTier.tripGuardian && hasTripGuardian) return true;
    return false;
  }

  double getBookingFee(PaymentTier tier) {
    if (isBookingFreeForSubscriber(tier)) return 0;
    return tierPrices[tier]!;
  }

  // ─── DATABASE ───
  Future<bool> _savePaymentRecord({
    required String email,
    required int amount,
    required String currency,
    required String reference,
    required String paystackRef,
    String paymentType = 'booking',
    String? tier,
  }) async {
    try {
      await _client.from('payments').insert({
        'email': email,
        'amount': amount,
        'currency': currency,
        'reference': reference,
        'paystack_ref': paystackRef,
        'status': 'pending',
        'payment_type': paymentType,
        'tier': tier,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPayment(String reference) async {
    try {
      final response = await _client
          .from('payments')
          .select()
          .eq('reference', reference)
          .maybeSingle();
      return response != null && response['status'] == 'completed';
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory(String email) async {
    try {
      final response = await _client
          .from('payments')
          .select()
          .eq('email', email)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<double> getTotalSpent(String email) async {
    try {
      final payments = await getPaymentHistory(email);
      double total = 0;
      for (var p in payments) {
        if (p['status'] == 'completed') total += (p['amount'] as int) / 100.0;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  String formatAmount(int amountInCents, String currency) {
    final amount = amountInCents / 100.0;
    switch (currency.toUpperCase()) {
      case 'NGN':
        return '₦${amount.toStringAsFixed(2)}';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'GHS':
        return 'GH₵${amount.toStringAsFixed(2)}';
      default:
        return '$currency ${amount.toStringAsFixed(2)}';
    }
  }

  String getPaystackPublicKey() => _paystackPublicKey;
}
