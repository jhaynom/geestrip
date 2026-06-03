import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final current = LanguageService().currentLanguage;

    final languages = [
      {'code': 'en', 'name': 'English', 'native': 'English', 'flag': '🇬🇧'},
      {'code': 'fr', 'name': 'French', 'native': 'Français', 'flag': '🇫🇷'},
      {'code': 'pt', 'name': 'Portuguese', 'native': 'Português', 'flag': '🇵🇹'},
    ];

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  GestureDetector(onTap: () => context.pop(), child: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.bgWhite, borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.arrowLeft, size: 22, color: AppColors.textSecondary))),
                  const SizedBox(width: 14),
                  const Expanded(child: Text('Language', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...languages.map((lang) => GestureDetector(
              onTap: () {
                LanguageService().setLanguage(lang['code']!);
                context.pop();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: current == lang['code'] ? Border.all(color: AppColors.primary, width: 2) : null,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(lang['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)), Text(lang['native']!, style: const TextStyle(fontSize: 13, color: AppColors.textMuted))])),
                    if (current == lang['code']) Container(width: 24, height: 24, decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle), child: const Icon(LucideIcons.check, color: Colors.white, size: 14)),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}