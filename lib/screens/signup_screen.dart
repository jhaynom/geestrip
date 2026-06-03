import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreed = false;
  bool _isLoading = false;
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password must be at least 6 characters'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Signup failed: ${e.toString().replaceAll('AuthException: ', '').replaceAll('AuthApiException: ', '')}',
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: _GridPainter()),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glass card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
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
                            // Back button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () => context.pop(),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.1)),
                                  ),
                                  child: const Icon(LucideIcons.arrowLeft,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ).animate().fadeIn(duration: 300.ms),

                            const SizedBox(height: 18),

                            // Logo
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF3B5CF6),
                                    Color(0xFF8B9CFE)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B5CF6)
                                        .withOpacity(0.5),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(LucideIcons.sparkles,
                                  color: Colors.white, size: 24),
                            )
                                .animate()
                                .scale(
                                    duration: 500.ms, curve: Curves.elasticOut)
                                .fadeIn(),

                            const SizedBox(height: 18),

                            const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 200.ms)
                                .moveY(begin: 8),

                            const SizedBox(height: 4),

                            Text(
                              "Join Africa's most trusted travel platform",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 300.ms)
                                .moveY(begin: 8),

                            const SizedBox(height: 24),

                            // Name
                            _GlassInput(
                              controller: _nameController,
                              hint: 'Full Name',
                              icon: LucideIcons.user,
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 400.ms)
                                .moveY(begin: 6),
                            const SizedBox(height: 10),

                            // Email
                            _GlassInput(
                              controller: _emailController,
                              hint: 'Email address',
                              icon: LucideIcons.mail,
                              keyboardType: TextInputType.emailAddress,
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 500.ms)
                                .moveY(begin: 6),
                            const SizedBox(height: 10),

                            // Phone
                            _GlassInput(
                              controller: _phoneController,
                              hint: 'Phone Number',
                              icon: LucideIcons.phone,
                              keyboardType: TextInputType.phone,
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 600.ms)
                                .moveY(begin: 6),
                            const SizedBox(height: 10),

                            // Password
                            _GlassInput(
                              controller: _passwordController,
                              hint: 'Password (min 6 characters)',
                              icon: LucideIcons.lock,
                              obscure: _obscurePassword,
                              suffix: GestureDetector(
                                onTap: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                child: Icon(
                                  _obscurePassword
                                      ? LucideIcons.eyeOff
                                      : LucideIcons.eye,
                                  color: Colors.white.withOpacity(0.35),
                                  size: 18,
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 700.ms)
                                .moveY(begin: 6),

                            const SizedBox(height: 16),

                            // Terms
                            GestureDetector(
                              onTap: () => setState(() => _agreed = !_agreed),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedContainer(
                                    duration: 200.ms,
                                    width: 18,
                                    height: 18,
                                    margin: const EdgeInsets.only(top: 1),
                                    decoration: BoxDecoration(
                                      color: _agreed
                                          ? const Color(0xFF3B5CF6)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: _agreed
                                            ? const Color(0xFF3B5CF6)
                                            : Colors.white.withOpacity(0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: _agreed
                                        ? const Icon(LucideIcons.check,
                                            color: Colors.white, size: 11)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'I agree to the ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.4),
                                        ),
                                        children: const [
                                          TextSpan(
                                            text: 'Terms of Service',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF8B9CFE),
                                            ),
                                          ),
                                          TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF8B9CFE),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 800.ms),

                            const SizedBox(height: 22),

                            // Sign Up Button
                            GestureDetector(
                              onTap: (_agreed && !_isLoading)
                                  ? _handleSignup
                                  : null,
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  gradient: (_agreed && !_isLoading)
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF3B5CF6),
                                            Color(0xFF6366F1)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: (_agreed && !_isLoading)
                                      ? null
                                      : Colors.white.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(15),
                                  border: (_agreed && !_isLoading)
                                      ? null
                                      : Border.all(
                                          color:
                                              Colors.white.withOpacity(0.08)),
                                  boxShadow: (_agreed && !_isLoading)
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF3B5CF6)
                                                .withOpacity(0.45),
                                            blurRadius: 18,
                                            offset: const Offset(0, 6),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Create Account',
                                              style: TextStyle(
                                                color: (_agreed && !_isLoading)
                                                    ? Colors.white
                                                    : Colors.white
                                                        .withOpacity(0.3),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              LucideIcons.arrowRight,
                                              color: (_agreed && !_isLoading)
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withOpacity(0.3),
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 900.ms)
                                .moveY(begin: 6),

                            const SizedBox(height: 14),

                            // Guest
                            GestureDetector(
                              onTap: () => context.go('/', extra: 'guest'),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.07)),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.user,
                                        color: Colors.white54, size: 16),
                                    SizedBox(width: 8),
                                    Text(
                                      'Continue as Guest',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 1000.ms),
                          ],
                        ),
                      ).animate().fadeIn(duration: 500.ms).moveY(begin: 20),

                      const SizedBox(height: 20),

                      // Sign in link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF8B9CFE),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms, delay: 1100.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType keyboardType;

  const _GlassInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
        cursorColor: const Color(0xFF8B9CFE),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.28),
              fontWeight: FontWeight.w400),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B5CF6).withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: const Color(0xFF8B9CFE), size: 16),
          ),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
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
