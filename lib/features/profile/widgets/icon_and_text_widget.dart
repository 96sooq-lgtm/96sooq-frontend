import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IconAndTextWidget extends StatelessWidget {
  final String iconName;
  final String title;
  final void Function()? onTap;
  const IconAndTextWidget({
    super.key,
    required this.iconName,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withOpacity(0.03),
                ),
                child: Center(child: SvgPicture.asset(iconName)),
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: isArabic
                    ? AppThemes.f12w400.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      )
                    : AppThemes.f12w400,
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
