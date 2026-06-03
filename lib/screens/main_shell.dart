import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _bounceController;
  late AnimationController _navController;
  late Animation<Offset> _navOffset;
  bool _navVisible = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _navController = AnimationController(
      duration: const Duration(milliseconds: 360),
      vsync: this,
    );

    _navOffset = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _navController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = GoRouterState.of(context).uri.toString();
      if (location == '/my-bookings') setState(() => _currentIndex = 1);
      if (location == '/explore') setState(() => _currentIndex = 2);
      if (location == '/profile') setState(() => _currentIndex = 3);
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _navController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (index == 2) {
      // TripBuddy center button
      _bounceController.forward().then((_) => _bounceController.reverse());
      _showTripBuddyModal();
      return;
    }
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/my-bookings');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  void _showBottomNav() {
    if (!_navVisible) {
      setState(() {
        _navVisible = true;
      });
      _navController.forward();
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical &&
        notification is ScrollUpdateNotification) {
      if (notification.scrollDelta != null &&
          notification.scrollDelta!.abs() > 3) {
        _showBottomNav();
      }
    }
    return false;
  }

  void _showTripBuddyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 14),
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B5CF6).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(LucideIcons.sparkles,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TripBuddy AI',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Your personal travel concierge',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, indent: 24, endIndent: 24),
            const SizedBox(height: 20),
            // Quick actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What can I help with?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _QuickTile(
                        icon: LucideIcons.building,
                        label: 'Hotels',
                        color: const Color(0xFFFF6B6B),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/concierge', extra: 'stay');
                        },
                      ),
                      const SizedBox(width: 10),
                      _QuickTile(
                        icon: LucideIcons.car,
                        label: 'Shuttle',
                        color: const Color(0xFF4ECDC4),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/services', extra: 'shuttle');
                        },
                      ),
                      const SizedBox(width: 10),
                      _QuickTile(
                        icon: LucideIcons.plane,
                        label: 'Flights',
                        color: const Color(0xFFFFD93D),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/services', extra: 'flights');
                        },
                      ),
                      const SizedBox(width: 10),
                      _QuickTile(
                        icon: LucideIcons.utensils,
                        label: 'Dining',
                        color: const Color(0xFF6C5CE7),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/services', extra: 'dining');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, indent: 24, endIndent: 24),
            const Spacer(),
            // Input bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Ask me anything...',
                          hintStyle:
                              TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.arrowUp,
                          color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: widget.child,
      ),
      bottomNavigationBar: _navVisible
          ? SlideTransition(
              position: _navOffset,
              child: FadeTransition(
                opacity: _navController,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.82),
                        borderRadius: BorderRadius.circular(34),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.65)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.14),
                            blurRadius: 26,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(34),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _NavPill(
                                icon: LucideIcons.home,
                                label: 'Home',
                                isActive: _currentIndex == 0,
                                onTap: () => _onTap(0),
                              ),
                              _NavPill(
                                icon: LucideIcons.calendarCheck,
                                label: 'Bookings',
                                isActive: _currentIndex == 1,
                                onTap: () => _onTap(1),
                              ),
                              // Center TripBuddy
                              ScaleTransition(
                                scale: Tween<double>(begin: 1.0, end: 0.85)
                                    .animate(
                                  CurvedAnimation(
                                      parent: _bounceController,
                                      curve: Curves.easeOut),
                                ),
                                child: GestureDetector(
                                  onTap: () => _onTap(2),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF1F3BB3),
                                          Color(0xFF5B6FF6)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF3B5CF6)
                                              .withOpacity(0.32),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      LucideIcons.sparkles,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                              _NavPill(
                                icon: LucideIcons.compass,
                                label: 'Explore',
                                isActive: _currentIndex == 2,
                                onTap: () => _onTap(2),
                              ),
                              _NavPill(
                                icon: LucideIcons.user,
                                label: 'Profile',
                                isActive: _currentIndex == 3,
                                onTap: () => _onTap(3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _NavPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavPill({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 300.ms,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF3B5CF6).withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isActive ? 23 : 21,
              color:
                  isActive ? const Color(0xFF3B5CF6) : const Color(0xFFB0B0B0),
            ).animate(target: isActive ? 1 : 0).scale(
                  duration: 300.ms,
                  begin: const Offset(1, 1),
                  end: const Offset(1.12, 1.12),
                ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? const Color(0xFF3B5CF6)
                    : const Color(0xFFB0B0B0),
                letterSpacing: isActive ? -0.2 : 0,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B5CF6),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
