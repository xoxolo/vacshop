import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/theme.dart';

class SocialAuthButton extends StatelessWidget {
  final String icon; // Path vers l'icône SVG
  final String label;
  final VoidCallback? onPressed;
  
  const SocialAuthButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône SVG (si disponible) ou fallback
          if (icon.endsWith('.svg'))
            SvgPicture.asset(
              icon,
              width: 20,
              height: 20,
            )
          else
            Icon(
              label.toLowerCase().contains('google')
                  ? Icons.g_mobiledata
                  : Icons.facebook,
              size: 20,
            ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
