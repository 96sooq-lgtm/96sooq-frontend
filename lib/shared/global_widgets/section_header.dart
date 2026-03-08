import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback? onActionTap;
  final bool isArabic;

  const SectionHeader({
    super.key,
    required this.title,
    required this.action,
    this.onActionTap,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isArabic
              ? AppThemes.f16w600.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                )
              : AppThemes.f16w600,
        ),
        GestureDetector(
          onTap: onActionTap,
          child: Row(
            children: [
              Text(
                action,
                style: isArabic
                    ? AppThemes.f12w500.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.subTextBlue,
                      )
                    : AppThemes.f12w500.copyWith(color: AppColors.subTextBlue),
              ),
              const Icon(Icons.arrow_right, color: AppColors.subTextBlue),
            ],
          ),
        ),
      ],
    );
  }
}
