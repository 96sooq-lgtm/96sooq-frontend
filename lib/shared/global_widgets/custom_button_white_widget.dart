import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:flutter/material.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomButtonWhiteWidget extends StatelessWidget {
  final String text;
  final bool isLoadingVisible;
  final VoidCallback onPressed;
  final bool isLoading;
  final TextStyle? textStyle;
  final double? fontSize;
  final Color color;

  const CustomButtonWhiteWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isLoadingVisible = true,
    this.textStyle,
    this.color = AppColors.white,
    this.fontSize, // Default font size
  });

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonWidth = constraints.maxWidth;
        double buttonHeight = 56;

        return GestureDetector(
          onTap: isLoading ? null : onPressed,
          child: Container(
            width: buttonWidth,
            height: buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFCFD6DF)),
              color: color,
            ),
            child: Center(
              child: (isLoading && isLoadingVisible)
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : isArabic
                  ? Text(
                      text,
                      style:
                          textStyle ??
                          AppThemes.f18w600.copyWith(
                            color: Colors.black,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      text,
                      style:
                          textStyle ??
                          AppThemes.f16w600.copyWith(
                            fontSize: fontSize,
                            fontWeight: isArabic
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
        );
      },
    );
  }
}
