import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class BadgePill extends StatelessWidget {
  final String text;

  const BadgePill({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.sageGreen;
    Color fg = AppColors.white;

    if (text == 'Special') {
      bg = AppColors.primaryDarkGreen;
      fg = AppColors.white;
    } else if (text == 'Signature') {
      bg = AppColors.coffeeBrown;
      fg = AppColors.white;
    } else if (text == 'Recommended') {
      bg = AppColors.sageGreen;
      fg = AppColors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
