import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:flutter/material.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageSelectionWidget extends StatelessWidget {
  final String language;
  final bool isSelected;
  final void Function() onTap;
  final String assetPath;
  const LanguageSelectionWidget({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: isSelected ? const EdgeInsets.all(3.0) : const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFFFFDF00), // Golden yellow
                    Color(0xFFD4AF37), // Metallic gold
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 43, vertical: 24),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language,
                  style: (isArabic ? AppThemes.f16w600 : AppThemes.f14w400)
                      .copyWith(color: Colors.black),
                ),
                Image.asset(assetPath),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
