import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/main_shell.dart';
import 'screens/welcome_screen.dart';
import 'screens/concierge_chat_screen.dart';
import 'screens/results_screen.dart';
import 'screens/trip_hub_screen.dart';
import 'screens/safe_stay_screen.dart';
import 'screens/trip_guardian_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/services_screen.dart';
import 'screens/properties_screen.dart';
import 'screens/property_detail_screen.dart';
import 'screens/service_chat_screen.dart';
import 'screens/service_results_screen.dart';
import 'screens/service_booking_screen.dart';
import 'screens/service_paywall_screen.dart';
import 'screens/booking_confirmation_screen.dart';
import 'screens/subscription_plans_screen.dart';
import 'screens/subscription_management_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/partner_register_screen.dart';
import 'screens/partner_dashboard_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/reviews_screen.dart';
import 'screens/write_review_screen.dart';
import 'screens/language_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/faq_screen.dart';
import 'screens/companion_profiles_screen.dart';
import 'services/language_service.dart';
import 'services/realtime_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vvvcapumlfydulmfmeje.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2dmNhcHVtbGZ5ZHVsbWZtZWplIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk5ODc0NzEsImV4cCI6MjA5NTU2MzQ3MX0.Js82vA6KgODXl2RZC30puTQhkr4BW51ilfUtt3uS1zM',
  );

  RealtimeService().connect();

  runApp(const GeesTripApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash Screen
    GoRoute(
      path: '/splash',
      builder: (_, state) => SplashScreen(isGuestMode: state.extra == 'guest'),
    ),

    // Auth screens (no bottom nav)
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),

    // Main screens WITH Bottom Navigation
    GoRoute(
        path: '/', builder: (_, __) => const MainShell(child: WelcomeScreen())),
    GoRoute(
        path: '/my-bookings',
        builder: (_, __) => const MainShell(child: MyBookingsScreen())),
    GoRoute(
        path: '/explore',
        builder: (_, __) => const MainShell(child: ExploreScreen())),
    GoRoute(
        path: '/profile',
        builder: (_, __) => const MainShell(child: ProfileScreen())),

    // Companion Profiles (FREE browsing)
    GoRoute(
        path: '/companion-profiles',
        builder: (_, __) => const CompanionProfilesScreen()),

    // Sub-screens (no bottom nav)
    GoRoute(
        path: '/concierge',
        builder: (_, state) {
          final intent = state.extra as String? ?? 'stay';
          return ConciergeChatScreen(intent: intent);
        }),
    GoRoute(
        path: '/results',
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return ResultsScreen(bookingData: Map<String, String>.from(data));
        }),
    GoRoute(path: '/trip-hub', builder: (_, __) => const TripHubScreen()),
    GoRoute(path: '/safe-stay', builder: (_, __) => const SafeStayScreen()),
    GoRoute(
        path: '/trip-guardian', builder: (_, __) => const TripGuardianScreen()),
    GoRoute(
        path: '/services',
        builder: (_, state) {
          final category = state.extra as String? ?? 'all';
          return ServicesScreen(category: category);
        }),
    GoRoute(
        path: '/properties',
        builder: (_, state) {
          final type = state.extra as String? ?? 'hotels';
          return PropertiesScreen(propertyType: type);
        }),
    GoRoute(
        path: '/property-detail',
        builder: (_, state) {
          final property = state.extra as Map<String, dynamic>? ?? {};
          return PropertyDetailScreen(property: property);
        }),
    GoRoute(
        path: '/service-chat',
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return ServiceChatScreen(
              serviceType: data['type'] as String? ?? 'shuttle',
              serviceName: data['name'] as String? ?? 'Service');
        }),
    GoRoute(
        path: '/service-paywall',
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return ServicePaywallScreen(
              serviceType: data['type'] as String? ?? 'shuttle',
              serviceName: data['name'] as String? ?? 'Service',
              fee: (data['fee'] as num?)?.toDouble() ?? 0.0,
              answers: Map<String, String>.from(data['answers'] as Map? ?? {}));
        }),
    GoRoute(
        path: '/service-results',
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return ServiceResultsScreen(
              serviceType: data['type'] as String? ?? 'shuttle',
              answers: Map<String, String>.from(data['answers'] as Map? ?? {}));
        }),
    GoRoute(
        path: '/service-booking',
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return ServiceBookingScreen(bookingData: data);
        }),
    GoRoute(
        path: '/booking-confirmation',
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return BookingConfirmationScreen(bookingData: data);
        }),
    GoRoute(
        path: '/subscription-plans',
        builder: (_, __) => const SubscriptionPlansScreen()),
    GoRoute(
        path: '/subscription-management',
        builder: (_, __) => const SubscriptionManagementScreen()),
    GoRoute(
        path: '/partner-register',
        builder: (_, __) => const PartnerRegisterScreen()),
    GoRoute(
        path: '/partner-dashboard',
        builder: (_, __) => const PartnerDashboardScreen()),
    GoRoute(path: '/chat-list', builder: (_, __) => const ChatListScreen()),
    GoRoute(
        path: '/chat-detail',
        builder: (_, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return ChatDetailScreen(
                conversationIndex: extra['index'] as int? ?? 0,
                isAdminView: extra['isAdminView'] as bool? ?? false,
                adminUserId: extra['adminUserId'] as String?,
                adminUserName: extra['adminUserName'] as String?);
          }
          final index = state.extra as int? ?? 0;
          return ChatDetailScreen(conversationIndex: index);
        }),
    GoRoute(
        path: '/reviews',
        builder: (_, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return ReviewsScreen(
              propertyName: data['name'] as String? ?? '',
              rating: (data['rating'] as num?)?.toDouble() ?? 0.0);
        }),
    GoRoute(
        path: '/write-review',
        builder: (_, state) {
          final propertyName = state.extra as String? ?? '';
          return WriteReviewScreen(propertyName: propertyName);
        }),
    GoRoute(path: '/language', builder: (_, __) => const LanguageScreen()),
    GoRoute(
        path: '/payment-methods',
        builder: (_, __) => const PaymentMethodsScreen()),
    GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
    GoRoute(path: '/terms', builder: (_, __) => const TermsScreen()),
    GoRoute(path: '/privacy', builder: (_, __) => const PrivacyScreen()),
    GoRoute(path: '/faq', builder: (_, __) => const FaqScreen()),
  ],
);

class GeesTripApp extends StatelessWidget {
  const GeesTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GeesTrip',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      locale: LanguageService().currentLocale,
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('pt')],
    );
  }
}
