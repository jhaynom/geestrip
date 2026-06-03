import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/chat_service.dart';
import '../services/partner_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  String _activeTab = 'stay';
  late final AnimationController _orbController;
  late final AnimationController _pulseController;
  late final AnimationController _chatPulseController;
  late final AnimationController _chatBounceController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    )..repeat();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _chatPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _chatBounceController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (AuthService().isLoggedIn) {
      await Future.wait([
        BookingService().loadBookings(),
        NotificationService().loadNotifications(),
        ChatService().loadConversations(),
        PartnerService().loadProperties(),
      ]);
      if (mounted) setState(() {});
    }
  }

  void _showChatModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return _ChatPopupModal(conversationIndex: 0);
      },
    );
  }

  @override
  void dispose() {
    _orbController.dispose();
    _pulseController.dispose();
    _chatPulseController.dispose();
    _chatBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            _buildOrbs(),
            RefreshIndicator(
              onRefresh: _loadUserData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildHeader().animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 12),
                    if (!AuthService().isLoggedIn)
                      _buildGuestBanner()
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 100.ms),
                    const SizedBox(height: 12),
                    _buildHeroCard()
                        .animate()
                        .fadeIn(duration: 350.ms, delay: 200.ms)
                        .moveY(begin: -8),
                    const SizedBox(height: 18),
                    _buildPillTabs()
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 320.ms),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      switchInCurve: Curves.easeOutCubic,
                      child: Container(
                        key: ValueKey(_activeTab),
                        child: _buildPillContent(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildQuickServices()
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 420.ms)
                        .moveY(begin: 12),
                    const SizedBox(height: 18),
                    _buildGuardianCard()
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 520.ms),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildEmergencyButton()
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 600.ms),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Chat bubble (bounce + pulse + scale)
            Positioned(
              bottom: 85,
              right: 20,
              child: GestureDetector(
                onTap: () => _showChatModal(context),
                child: AnimatedBuilder(
                  animation: Listenable.merge(
                      [_chatBounceController, _chatPulseController]),
                  builder: (_, __) {
                    final bounce =
                        math.sin(_chatBounceController.value * 2 * math.pi) *
                            -10;
                    final shake =
                        math.sin(_chatPulseController.value * 2 * math.pi) * 2;

                    return Transform.translate(
                      offset: Offset(shake, bounce),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B5CF6), Color(0xFF6366F1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B5CF6).withOpacity(0.25),
                              blurRadius: 14,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: const Color(0xFF8B9CFE).withOpacity(0.15),
                              blurRadius: 8,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              LucideIcons.messageCircle,
                              color: Colors.white,
                              size: 26,
                            ),
                            if (ChatService().totalUnread > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  constraints: const BoxConstraints(
                                      minWidth: 20, minHeight: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444)
                                            .withOpacity(0.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${ChatService().totalUnread}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Background orbs
  Widget _buildOrbs() {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _orbController,
          builder: (_, __) => Positioned(
            top: -50 + math.sin(_orbController.value * 6.28 * 0.6) * 25,
            right: -40 + math.cos(_orbController.value * 6.28 * 0.4) * 18,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1F3BB3).withOpacity(0.1),
                    const Color(0xFF1F3BB3).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _orbController,
          builder: (_, __) => Positioned(
            bottom: -70 + math.cos(_orbController.value * 6.28 * 0.5) * 35,
            left: -60 + math.sin(_orbController.value * 6.28 * 0.7) * 25,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B5CF6).withOpacity(0.07),
                    const Color(0xFF3B5CF6).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 100,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ClipRect(
                  child: Transform.scale(
                    scale: 1.5,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/GeesTrip logo.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                _HeaderIcon(
                    icon: LucideIcons.search,
                    onTap: () => context.push('/explore')),
                const SizedBox(width: 6),
                _HeaderIcon(
                  icon: LucideIcons.bell,
                  badge: NotificationService().unreadCount > 0,
                  onTap: () => context.push('/notifications'),
                ),
                const SizedBox(width: 6),
                _HeaderIcon(
                  icon: LucideIcons.user,
                  onTap: () => context.push('/profile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentGold.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accentGold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.crown,
                  color: AppColors.accentGold, size: 16),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Browsing as guest. Create an account for exclusive perks!',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E)),
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/signup'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Sign Up',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D1B6B), Color(0xFF1528A0), Color(0xFF1F3BB3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF1F3BB3).withOpacity(0.35),
                blurRadius: 30,
                offset: const Offset(0, 12)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.crown,
                          color: AppColors.accentGold, size: 12),
                      SizedBox(width: 6),
                      Text('ELITE',
                          style: TextStyle(
                              color: AppColors.accentGold,
                              fontSize: 9,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/notifications'),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(LucideIcons.bell,
                            color: Colors.white, size: 20),
                        if (NotificationService().unreadCount > 0)
                          Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) {
                    return ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(colors: [
                        Colors.white,
                        Colors.white.withOpacity(
                            0.75 + (_pulseController.value * 0.25)),
                        Colors.white
                      ]).createShader(bounds),
                      child: const Text('150+',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800)),
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text('Verified Hotels\nAcross Africa',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _HeroStat(
                    icon: LucideIcons.building2,
                    value: '12',
                    label: 'Countries'),
                const SizedBox(width: 14),
                _HeroStat(
                    icon: LucideIcons.users,
                    value: '2.4k',
                    label: 'Happy Guests'),
                const SizedBox(width: 14),
                _HeroStat(
                    icon: LucideIcons.star, value: '4.8', label: 'Avg Rating'),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/properties', extra: 'hotels'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14)),
                      child: const Column(children: [
                        Icon(LucideIcons.building2, color: Colors.white),
                        SizedBox(height: 6),
                        Text('Hotels', style: TextStyle(color: Colors.white))
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        context.push('/properties', extra: 'apartments'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14)),
                      child: const Column(children: [
                        Icon(LucideIcons.home, color: Colors.white),
                        SizedBox(height: 6),
                        Text('Apartments',
                            style: TextStyle(color: Colors.white))
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/explore'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          color: AppColors.accentGold.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(14)),
                      child: const Column(children: [
                        Icon(LucideIcons.compass, color: AppColors.accentGold),
                        SizedBox(height: 6),
                        Text('Explore All',
                            style: TextStyle(color: AppColors.accentGold))
                      ]),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPillTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)
            ]),
        child: Row(children: [
          _PillTab(
              icon: LucideIcons.building2,
              label: 'Stay',
              isActive: _activeTab == 'stay',
              onTap: () => setState(() => _activeTab = 'stay')),
          _PillTab(
              icon: LucideIcons.briefcase,
              label: 'Business',
              isActive: _activeTab == 'business',
              onTap: () => setState(() => _activeTab = 'business')),
          _PillTab(
              icon: LucideIcons.gift,
              label: 'Special',
              isActive: _activeTab == 'special',
              onTap: () => setState(() => _activeTab = 'special')),
          _PillTab(
              icon: LucideIcons.heart,
              label: 'Help',
              isActive: _activeTab == 'help',
              onTap: () => setState(() => _activeTab = 'help')),
        ]),
      ),
    );
  }

  Widget _buildPillContent() {
    switch (_activeTab) {
      case 'business':
        return _buildBusinessTabContent();
      case 'special':
        return _buildSpecialTabContent();
      case 'help':
        return _buildHelpTabContent();
      case 'stay':
      default:
        return _buildConciergeCards();
    }
  }

  Widget _buildConciergeCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        _ConciergeCard(
            title: 'Find a Place to Stay',
            subtitle: 'Curated hotels • Best rates • Instant confirm',
            icon: LucideIcons.bedDouble,
            gradient: const [Color(0xFF1F3BB3), Color(0xFF3B5CF6)],
            onTap: () => context.push('/concierge', extra: 'stay')),
        const SizedBox(height: 12),
        _ConciergeCard(
            title: 'Business Travel Solutions',
            subtitle: 'Premium workspace • Priority check-in',
            icon: LucideIcons.briefcase,
            gradient: const [Color(0xFF111D4A), Color(0xFF1F3BB3)],
            onTap: () => context.push('/concierge', extra: 'business')),
        const SizedBox(height: 12),
        _ConciergeCard(
            title: 'Special Requests',
            subtitle: 'Anniversary • Accessibility • Surprises',
            icon: LucideIcons.gift,
            gradient: [AppColors.bgWhite, AppColors.bgWhite],
            textColor: AppColors.textPrimary,
            subtitleColor: AppColors.textMuted,
            iconBg: AppColors.primarySurface,
            onTap: () => context.push('/concierge', extra: 'special')),
      ]),
    );
  }

  Widget _buildBusinessTabContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        _ConciergeCard(
            title: 'Workspace Hotels',
            subtitle: 'Quiet workspaces • Business-ready rooms',
            icon: LucideIcons.type,
            gradient: const [Color(0xFF1F3BB3), Color(0xFF3B82F6)],
            onTap: () => context.push('/concierge', extra: 'workspace')),
        const SizedBox(height: 12),
        _ConciergeCard(
            title: 'Meeting Rooms',
            subtitle: 'Book rooms for teams & events',
            icon: LucideIcons.users,
            gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            onTap: () => context.push('/concierge', extra: 'meeting')),
        const SizedBox(height: 12),
        _ConciergeCard(
            title: 'Fast WiFi Hotels',
            subtitle: 'High-speed internet & streaming',
            icon: LucideIcons.wifi,
            gradient: const [Color(0xFF059669), Color(0xFF10B981)],
            onTap: () => context.push('/concierge', extra: 'wifi')),
      ]),
    );
  }

  Widget _buildSpecialTabContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        _ConciergeCard(
            title: 'Romantic Getaways',
            subtitle: 'Curated stays for couples',
            icon: LucideIcons.heart,
            gradient: const [Color(0xFFEC4899), Color(0xFFBE185D)],
            onTap: () => context.push('/concierge', extra: 'romantic')),
        const SizedBox(height: 12),
        _ConciergeCard(
            title: 'Celebration Packages',
            subtitle: 'Cake, flowers & surprises',
            icon: LucideIcons.gift,
            gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
            onTap: () => context.push('/concierge', extra: 'celebration')),
        const SizedBox(height: 12),
        _ConciergeCard(
            title: 'Surprise Experiences',
            subtitle: 'Unique local adventures',
            icon: LucideIcons.star,
            gradient: const [Color(0xFF6366F1), Color(0xFF3B82F6)],
            onTap: () => context.push('/concierge', extra: 'surprise')),
      ]),
    );
  }

  Widget _buildHelpTabContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        _ConciergeCard(
            title: 'FAQ Quick Links',
            subtitle: 'Fast answers to common questions',
            icon: LucideIcons.helpCircle,
            gradient: const [Color(0xFF1F3BB3), Color(0xFF3B5CF6)],
            onTap: () => context.push('/faq')),
        const SizedBox(height: 12),
        _ConciergeCard(
            title: 'Live Agent Request',
            subtitle: 'Connect with support now',
            icon: LucideIcons.phone,
            gradient: const [Color(0xFF059669), Color(0xFF10B981)],
            onTap: () => context.push('/concierge', extra: 'agent')),
        const SizedBox(height: 12),
        _ConciergeCard(
            title: 'Trip Guardian Promo',
            subtitle: 'Learn about protection plans',
            icon: LucideIcons.shield,
            gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
            onTap: () => context.push('/trip-guardian')),
        const SizedBox(height: 12),
        _ConciergeCard(
            title: 'Emergency Contact',
            subtitle: 'Quick access to emergency help',
            icon: LucideIcons.mapPin,
            gradient: const [Color(0xFFDC2626), Color(0xFFF43F5E)],
            onTap: () => context.push('/safe-stay')),
      ]),
    );
  }

  Widget _buildQuickServices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Our Services',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          GestureDetector(
              onTap: () => context.push('/explore'),
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('See All',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                    SizedBox(width: 4),
                    Icon(LucideIcons.arrowRight,
                        color: AppColors.primary, size: 14)
                  ]))),
        ]),
        const SizedBox(height: 14),
        SizedBox(
            height: 175,
            child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 8),
                children: [
                  _ServiceCard(
                      icon: LucideIcons.car,
                      title: 'Shuttle',
                      subtitle: 'Airport transfers\n& car rentals',
                      gradient: const [Color(0xFF3B5CF6), Color(0xFF6366F1)],
                      badge: 'From \$25',
                      onTap: () => context.push('/services', extra: 'shuttle')),
                  const SizedBox(width: 12),
                  _ServiceCard(
                      icon: LucideIcons.users,
                      title: 'Companion',
                      subtitle: 'Event & travel\ncompanions',
                      gradient: const [Color(0xFFBE185D), Color(0xFFEC4899)],
                      badge: 'Verified',
                      onTap: () =>
                          context.push('/services', extra: 'companion')),
                  const SizedBox(width: 12),
                  _ServiceCard(
                      icon: LucideIcons.map,
                      title: 'Tours',
                      subtitle: 'City tours &\nexperiences',
                      gradient: const [Color(0xFF059669), Color(0xFF10B981)],
                      badge: '50+ Tours',
                      onTap: () => context.push('/services', extra: 'tours')),
                  const SizedBox(width: 12),
                  _ServiceCard(
                      icon: LucideIcons.utensilsCrossed,
                      title: 'Dining',
                      subtitle: 'Restaurant bookings\n& private chef',
                      gradient: const [Color(0xFFDC2626), Color(0xFFF43F5E)],
                      badge: '100+ Spots',
                      onTap: () => context.push('/services', extra: 'dining')),
                  const SizedBox(width: 12),
                  _ServiceCard(
                      icon: LucideIcons.plane,
                      title: 'Flights',
                      subtitle: 'Best rates on\nall airlines',
                      gradient: const [Color(0xFF2563EB), Color(0xFF60A5FA)],
                      badge: 'Global',
                      onTap: () => context.push('/services', extra: 'flights')),
                ])),
      ]),
    );
  }

  Widget _buildGuardianCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push('/trip-guardian'),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D1B6B), Color(0xFF1A237E), Color(0xFF1F3BB3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A237E).withOpacity(0.4),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: const Icon(LucideIcons.shield,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trip Guardian™',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700)),
                        Text('24/7 Protection & Emergency Support',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('NEW',
                        style: TextStyle(
                            color: AppColors.accentGold,
                            fontSize: 9,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _GuardianChip(LucideIcons.phone, '24/7 Helpline'),
                  _GuardianChip(LucideIcons.mapPin, 'Instant Relocation'),
                  _GuardianChip(LucideIcons.scale, 'Dispute Resolution'),
                  _GuardianChip(LucideIcons.bellRing, 'Safety Alerts'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$15.00',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800)),
                      SizedBox(width: 3),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text('/ trip',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.accentGold.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Activate',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        SizedBox(width: 3),
                        Icon(LucideIcons.chevronRight,
                            color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -2)),
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
          border: Border.all(color: Colors.white.withOpacity(0.9))),
      child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: () => context.push('/safe-stay'),
              borderRadius: BorderRadius.circular(20),
              child: const Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Icon(LucideIcons.shield, color: AppColors.error, size: 20),
                    SizedBox(width: 8),
                    Text('Need Emergency Help?',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(LucideIcons.chevronRight,
                        color: AppColors.textMuted, size: 16)
                  ])))),
    );
  }
}

class _ChatPopupModal extends StatefulWidget {
  final int conversationIndex;

  const _ChatPopupModal({super.key, this.conversationIndex = 0});

  @override
  State<_ChatPopupModal> createState() => _ChatPopupModalState();
}

class _ChatPopupModalState extends State<_ChatPopupModal> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  late ChatConversation _conversation;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _conversation = _chatService.conversations.length > widget.conversationIndex
        ? _chatService.conversations[widget.conversationIndex]
        : ChatConversation(
            name: 'Support',
            avatar: 'G',
            lastMessage: '',
            time: '',
            unread: 0,
            icon: LucideIcons.messageCircle,
            messages: [],
          );
    _chatService.onMessagesUpdated = _handleMessagesUpdated;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    if (_chatService.onMessagesUpdated == _handleMessagesUpdated) {
      _chatService.onMessagesUpdated = null;
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleMessagesUpdated() {
    if (!mounted) return;
    setState(() {
      if (_chatService.conversations.length > widget.conversationIndex) {
        _conversation = _chatService.conversations[widget.conversationIndex];
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    Future.delayed(100.ms, () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: 250.ms,
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage([String? text]) {
    final messageText = text?.trim() ?? _messageController.text.trim();
    if (messageText.isEmpty) return;
    _messageController.clear();
    _isTyping = true;
    setState(() {});
    _chatService.sendMessage(widget.conversationIndex, messageText);
    Future.delayed(150.ms, _scrollToBottom);
    Future.delayed(450.ms, () {
      if (mounted) {
        _isTyping = false;
        setState(() {});
      }
    });
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(_conversation.avatar,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(6)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _TypingDot(delay: 0),
            const SizedBox(width: 5),
            _TypingDot(delay: 200),
            const SizedBox(width: 5),
            _TypingDot(delay: 400),
          ]),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = _conversation.messages;
    final lastMessage = messages.isNotEmpty ? messages.last : null;
    final showQuickReplies = lastMessage?.quickReplies != null &&
        lastMessage!.quickReplies!.isNotEmpty &&
        !_isTyping;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 560),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Chat support',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.x,
                          size: 20, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _chatService.totalUnread > 0
                          ? 'You have ${_chatService.totalUnread} unread message${_chatService.totalUnread == 1 ? '' : 's'}.'
                          : 'No unread messages at the moment.',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/chat-detail',
                          extra: widget.conversationIndex);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF3B5CF6), Color(0xFF6366F1)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('Open full chat',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                itemCount: messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  final message = messages[index];
                  final isSystemMessage = !message.isMe &&
                      (message.text.contains('has joined') ||
                          message.text.contains('Chat ended'));
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: isSystemMessage
                        ? Center(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                  color: AppColors.accentBlueLight,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text(message.text,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: message.isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!message.isMe)
                                Container(
                                  width: 32,
                                  height: 32,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color(0xFF1F3BB3),
                                      Color(0xFF3B5CF6)
                                    ]),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(_conversation.avatar,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: message.isMe
                                        ? AppColors.primary
                                        : AppColors.bgWhite,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(18),
                                      topRight: const Radius.circular(18),
                                      bottomLeft: message.isMe
                                          ? const Radius.circular(18)
                                          : const Radius.circular(6),
                                      bottomRight: message.isMe
                                          ? const Radius.circular(6)
                                          : const Radius.circular(18),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (message.isMe
                                                ? AppColors.primary
                                                : Colors.black)
                                            .withOpacity(
                                                message.isMe ? 0.2 : 0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(message.text,
                                          style: TextStyle(
                                              color: message.isMe
                                                  ? Colors.white
                                                  : AppColors.textPrimary,
                                              fontSize: 15,
                                              height: 1.4)),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(message.time,
                                              style: TextStyle(
                                                  color: message.isMe
                                                      ? Colors.white60
                                                      : AppColors.textMuted,
                                                  fontSize: 10)),
                                          if (message.isMe) ...[
                                            const SizedBox(width: 4),
                                            Icon(LucideIcons.check,
                                                size: 12,
                                                color: message.isRead
                                                    ? Colors.white
                                                    : Colors.white60),
                                          ]
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
            if (showQuickReplies)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lastMessage!.quickReplies!.map((reply) {
                    final isBack = reply.contains('Back');
                    return GestureDetector(
                      onTap: () => _sendMessage(reply),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isBack ? AppColors.bgWhite : AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          border: isBack
                              ? Border.all(color: AppColors.tabInactive)
                              : null,
                          boxShadow: [
                            BoxShadow(
                                color:
                                    (isBack ? Colors.black : AppColors.primary)
                                        .withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Text(reply,
                            style: TextStyle(
                                color: isBack
                                    ? AppColors.textSecondary
                                    : Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -2))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgPrimary,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(
                            fontSize: 15, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: _chatService.isAgentConnected
                              ? 'Chat with agent...'
                              : (_chatService.isWaitingForAgent
                                  ? 'Waiting for agent...'
                                  : 'Type a message...'),
                          hintStyle:
                              const TextStyle(color: AppColors.textPlaceholder),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(LucideIcons.send,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.9), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 0.3), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(widget.delay / 1000, 1.0, curve: Curves.easeInOut),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.textSecondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── HELPER WIDGETS ───

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final bool badge;
  final VoidCallback onTap;
  const _HeaderIcon(
      {required this.icon, this.badge = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
            ]),
        child: Stack(alignment: Alignment.center, children: [
          Icon(icon, color: AppColors.textSecondary, size: 17),
          if (badge)
            Positioned(
                top: 5,
                right: 5,
                child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: AppColors.error, shape: BoxShape.circle)))
        ]),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _HeroStat(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: Colors.white54, size: 13),
      const SizedBox(width: 6),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9))
      ])
    ]);
  }
}

class _PillTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _PillTab(
      {required this.icon,
      required this.label,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 250.ms,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.tabActive : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.tabActive.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 13,
                  color: isActive ? Colors.white : AppColors.tabInactiveText),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color:
                          isActive ? Colors.white : AppColors.tabInactiveText)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConciergeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color textColor;
  final Color subtitleColor;
  final Color? iconBg;
  final VoidCallback onTap;

  const _ConciergeCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.gradient,
      this.textColor = Colors.white,
      this.subtitleColor = Colors.white70,
      this.iconBg,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool useGradientBackground =
        gradient.any((color) => color != AppColors.bgWhite);

    return Material(
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            splashColor: AppColors.primary.withOpacity(0.04),
            child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: useGradientBackground ? null : AppColors.bgWhite,
                  gradient: useGradientBackground
                      ? LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Row(children: [
                  Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: gradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: gradient.first.withOpacity(0.18),
                                blurRadius: 10,
                                offset: const Offset(0, 6))
                          ]),
                      child: Icon(icon, color: Colors.white)),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(title,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                        const SizedBox(height: 3),
                        Text(subtitle,
                            style: TextStyle(
                                fontSize: 11,
                                color: subtitleColor,
                                height: 1.3))
                      ])),
                  Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: useGradientBackground
                              ? Colors.white.withOpacity(0.18)
                              : AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(LucideIcons.chevronRight,
                          color: AppColors.textMuted, size: 16))
                ]))));
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String badge;
  final VoidCallback onTap;

  const _ServiceCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.gradient,
      required this.badge,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            width: 155,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: gradient.first.withOpacity(0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 6))
                ]),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(icon, color: Colors.white, size: 22)),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                height: 1.15)),
                        const SizedBox(height: 6),
                        Text(subtitle,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.5)),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.17),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(badge,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white))),
                        Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(LucideIcons.chevronRight,
                                size: 14, color: Colors.white))
                      ])
                ])));
  }
}

class _GuardianChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GuardianChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white54, size: 10),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 9,
                  fontWeight: FontWeight.w500))
        ]));
  }
}
