import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

enum ContactMethod { whatsapp, email, inAppChat }

class ContactMethodSelector extends StatelessWidget {
  final ContactMethod selectedMethod;
  final ValueChanged<ContactMethod> onChanged;

  const ContactMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preferred contact method',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        _buildOption(
          context,
          method: ContactMethod.whatsapp,
          title: 'WhatsApp',
          subtitle: 'Fast, preferred option',
          icon: LucideIcons.messageCircle,
        ),
        const SizedBox(height: 10),
        _buildOption(
          context,
          method: ContactMethod.email,
          title: 'Email',
          subtitle: 'Send all details to your inbox',
          icon: LucideIcons.mail,
        ),
        const SizedBox(height: 10),
        _buildOption(
          context,
          method: ContactMethod.inAppChat,
          title: 'In-app chat',
          subtitle: 'We contact you inside the app',
          icon: LucideIcons.messageSquare,
        ),
      ],
    );
  }

  Widget _buildOption(BuildContext context,
      {required ContactMethod method,
      required String title,
      required String subtitle,
      required IconData icon}) {
    final selected = selectedMethod == method;

    return GestureDetector(
      onTap: () => onChanged(method),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.textMuted,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon,
                  color: selected ? Colors.white : AppColors.textSecondary,
                  size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          height: 1.4)),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.textMuted,
                    width: 1.5),
                color: selected ? AppColors.primary : Colors.transparent,
              ),
              child: selected
                  ? const Icon(LucideIcons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
