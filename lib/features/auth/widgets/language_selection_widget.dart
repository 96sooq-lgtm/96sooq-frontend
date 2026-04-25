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
        padding: EdgeInsets.symmetric(horizontal: 43, vertical: 24),
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.white,
          border: isSelected
              ? Border.all(color: AppColors.subTextBlue, width: 3.0)
              : Border.all(color: Colors.transparent, width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(17)),
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
    );
  }
}
