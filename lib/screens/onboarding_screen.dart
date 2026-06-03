import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': LucideIcons.globe,
      'title': 'Discover Africa\nLike Never Before',
      'subtitle':
          'Premium stays, curated experiences, and 24/7 concierge service across 12 African countries.',
      'stat': '150+',
      'statLabel': 'Verified Hotels',
    },
    {
      'icon': LucideIcons.shieldCheck,
      'title': 'Travel With\nComplete Peace of Mind',
      'subtitle':
          'Trip Guardian™ protects you 24/7 with emergency support, instant relocation, and full dispute resolution.',
      'stat': '24/7',
      'statLabel': 'Protection',
    },
    {
      'icon': LucideIcons.star,
      'title': "Join Africa's Most\nLoved Travel Platform",
      'subtitle':
          '2,400+ guests rate us 4.8 stars. Every service verified, every stay guaranteed.',
      'stat': '4.8',
      'statLabel': 'Star Rating',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _gradientController,
            builder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0A0E21),
                      const Color(0xFF1A1F3A)
                          .withOpacity(0.8 + (_gradientController.value * 0.2)),
                      const Color(0xFF1F3BB3)
                          .withOpacity(0.3 + (_gradientController.value * 0.3)),
                      const Color(0xFF0A0E21),
                    ],
                  ),
                ),
              );
            },
          ),

          // Grid overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: _GridPainter()),
            ),
          ),

          // Layout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // ─── TOP: Logo + Skip ───
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B5CF6), Color(0xFF8B9CFE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B5CF6).withOpacity(0.5),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(LucideIcons.sparkles,
                              color: Colors.white, size: 20),
                        ),
                        // Skip
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.12)),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── CENTER: Glass Card (takes all available space) ───
                  Expanded(
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: const Color(0xFF3B5CF6).withOpacity(0.15),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B5CF6).withOpacity(0.06),
                              blurRadius: 30,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // PageView content
                            SizedBox(
                              height: 310,
                              child: PageView.builder(
                                controller: _controller,
                                onPageChanged: (index) =>
                                    setState(() => _currentPage = index),
                                itemCount: _pages.length,
                                itemBuilder: (context, index) {
                                  final page = _pages[index];
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Icon
                                      Container(
                                        width: 76,
                                        height: 76,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF3B5CF6)
                                                  .withOpacity(0.2),
                                              const Color(0xFF8B9CFE)
                                                  .withOpacity(0.05),
                                            ],
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFF3B5CF6)
                                                .withOpacity(0.25),
                                          ),
                                        ),
                                        child: Icon(
                                          page['icon'] as IconData,
                                          color: const Color(0xFF8B9CFE),
                                          size: 32,
                                        ),
                                      )
                                          .animate()
                                          .scale(
                                              duration: 550.ms,
                                              curve: Curves.elasticOut)
                                          .fadeIn(),

                                      const SizedBox(height: 22),

                                      // Title
                                      Text(
                                        page['title'] as String,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          height: 1.2,
                                          letterSpacing: -0.5,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // Subtitle
                                      Text(
                                        page['subtitle'] as String,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.45),
                                          fontSize: 13,
                                          height: 1.6,
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      // Stat badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.04),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.06),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              page['stat'] as String,
                                              style: const TextStyle(
                                                color: Color(0xFF8B9CFE),
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              page['statLabel'] as String,
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.45),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _pages.length,
                                (i) => AnimatedContainer(
                                  duration: 300.ms,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentPage == i ? 22 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _currentPage == i
                                        ? const Color(0xFF3B5CF6)
                                        : Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms).moveY(begin: 20),
                    ),
                  ),

                  // ─── BOTTOM: CTA + Login link ───
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        // CTA Button
                        GestureDetector(
                          onTap: () {
                            if (_currentPage < _pages.length - 1) {
                              _controller.nextPage(
                                duration: 500.ms,
                                curve: Curves.easeInOutCubic,
                              );
                            } else {
                              context.go('/login');
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B5CF6), Color(0xFF6366F1)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF3B5CF6).withOpacity(0.45),
                                  blurRadius: 22,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _pages.length - 1
                                      ? 'Start Exploring'
                                      : 'Continue',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                if (_currentPage == _pages.length - 1) ...[
                                  const SizedBox(width: 8),
                                  const Icon(LucideIcons.arrowRight,
                                      color: Colors.white, size: 20),
                                ],
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                        const SizedBox(height: 14),

                        // Login link
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'Already have an account? Log in',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 0.5;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
