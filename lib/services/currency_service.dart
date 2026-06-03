import 'package:supabase_flutter/supabase_flutter.dart';

enum Currency {
  usd, // $
  ngn, // ₦
  ghs, // GH₵
  eur, // €
  gbp, // £
}

class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Exchange rates relative to USD
  static const Map<Currency, double> exchangeRates = {
    Currency.usd: 1.0,
    Currency.ngn: 1600.0,
    Currency.ghs: 15.50,
    Currency.eur: 0.92,
    Currency.gbp: 0.79,
  };

  static const Map<Currency, String> currencySymbols = {
    Currency.usd: '\$',
    Currency.ngn: '₦',
    Currency.ghs: 'GH₵',
    Currency.eur: '€',
    Currency.gbp: '£',
  };

  static const Map<Currency, String> currencyNames = {
    Currency.usd: 'USD',
    Currency.ngn: 'NGN',
    Currency.ghs: 'GHS',
    Currency.eur: 'EUR',
    Currency.gbp: 'GBP',
  };

  Currency _userPreferredCurrency = Currency.usd;

  Currency get userCurrency => _userPreferredCurrency;

  Future<void> loadUserCurrency() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('profiles')
          .select('preferred_currency')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && response['preferred_currency'] != null) {
        final currencyStr = response['preferred_currency'] as String;
        _userPreferredCurrency = Currency.values.firstWhere(
            (c) => c.name == currencyStr,
            orElse: () => Currency.usd);
      }
    } catch (e) {
      print('Error loading user currency: $e');
    }
  }

  Future<void> setUserCurrency(Currency currency) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      _userPreferredCurrency = currency;

      await _supabase
          .from('profiles')
          .update({'preferred_currency': currency.name}).eq('id', user.id);
    } catch (e) {
      print('Error setting user currency: $e');
    }
  }

  /// Convert amount from USD to target currency
  double convertFromUSD(double usdAmount, Currency targetCurrency) {
    if (targetCurrency == Currency.usd) {
      return usdAmount;
    }
    return usdAmount * exchangeRates[targetCurrency]!;
  }

  /// Convert amount from source currency to USD
  double convertToUSD(double amount, Currency sourceCurrency) {
    if (sourceCurrency == Currency.usd) {
      return amount;
    }
    return amount / exchangeRates[sourceCurrency]!;
  }

  /// Format USD amount to user's preferred currency
  String formatPrice(double usdAmount,
      {Currency? currency, int decimalPlaces = 2}) {
    final targetCurrency = currency ?? _userPreferredCurrency;
    final convertedAmount = convertFromUSD(usdAmount, targetCurrency);

    // Format based on currency conventions
    if (targetCurrency == Currency.ngn) {
      if (convertedAmount >= 1000) {
        return '₦${(convertedAmount / 1000).toStringAsFixed(1)}k';
      }
      return '₦${convertedAmount.toStringAsFixed(0)}';
    } else if (targetCurrency == Currency.ghs) {
      return 'GH₵${convertedAmount.toStringAsFixed(2)}';
    } else if (targetCurrency == Currency.eur) {
      return '€${convertedAmount.toStringAsFixed(2)}';
    } else if (targetCurrency == Currency.gbp) {
      return '£${convertedAmount.toStringAsFixed(2)}';
    } else {
      // USD
      return '\$${convertedAmount.toStringAsFixed(2)}';
    }
  }

  /// Get symbol for currency
  String getSymbol(Currency currency) {
    return currencySymbols[currency] ?? '\$';
  }

  /// Get name for currency
  String getCurrencyName(Currency currency) {
    return currencyNames[currency] ?? 'USD';
  }

  /// Format amount with currency name (e.g., "USD 2.00")
  String formatWithName(double usdAmount, {Currency? currency}) {
    final targetCurrency = currency ?? _userPreferredCurrency;
    final formatted = formatPrice(usdAmount, currency: targetCurrency);
    return formatted;
  }
}
