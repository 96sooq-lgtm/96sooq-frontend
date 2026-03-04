import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickActionWidget extends StatelessWidget {
  final Color iconBg;
  final String icon;
  final String name;
  final VoidCallback? onTap;
  const QuickActionWidget({
    super.key,
    required this.iconBg,
    required this.icon,
    required this.name,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          height: 158,
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: Color(0xFFF9F9F9),
          ),
          child: Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: .center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: iconBg,
                child: SvgPicture.asset(icon),
              ),
              SizedBox(height: 5),
              Text(
                name,
                style: isArabic
                    ? AppThemes.f14w500.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )
                    : AppThemes.f14w500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
