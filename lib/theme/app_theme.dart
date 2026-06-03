import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF1F3BB3);
  static const Color primaryDark = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF3B5CF6);
  static const Color primarySurface = Color(0xFFEEF1FF);

  static const Color accentGreen = Color(0xFF31C46C);
  static const Color accentGreenLight = Color(0xFFE8F8EF);
  static const Color accentBlue = Color(0xFFAFC4FF);
  static const Color accentBlueLight = Color(0xFFF0F3FF);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentGoldLight = Color(0xFFFFFBEB);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentPinkLight = Color(0xFFFDF2F8);

  static const Color bgPrimary = Color(0xFFF5F6FA);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFF121820);
  static const Color bgCard = Color(0xFF1F2937);
  static const Color bgCardLight = Color(0xFF374151);
  static const Color border = Color(0xFFCBD5E1);
  static const List<Color> gradientBalance = [
    Color(0xFF31C46C),
    Color(0xFF10B981),
  ];

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF3A3A4A);
  static const Color textMuted = Color(0xFF8E8EA0);
  static const Color textPlaceholder = Color(0xFFB0B7C3);

  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B);

  static const Color tabActive = Color(0xFF1F3BB3);
  static const Color tabInactive = Color(0xFFF1F5F9);
  static const Color tabInactiveText = Color(0xFF64748B);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accentGreen,
        surface: AppColors.bgWhite,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 42,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
          color: Colors.white,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          color: AppColors.textPrimary,
          height: 1.2,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 18,
          color: AppColors.textSecondary,
          height: 1.6,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.textMuted,
          height: 1.5,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.bgWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }
}

class PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  const PulseDot({super.key, this.color = AppColors.success, this.size = 10});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4 * _controller.value),
                blurRadius: 8 * _controller.value,
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
