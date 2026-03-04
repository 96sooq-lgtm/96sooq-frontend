import 'package:_96_sooq/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:_96_sooq/constants/app_themes.dart';

class CustomIconButton extends StatelessWidget {
  final String text;
  final String icon;
  final bool isLoadingVisible;
  final VoidCallback onPressed;
  final bool isLoading;
  final TextStyle? textStyle;
  final double fontSize;
  final Color color;

  const CustomIconButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.isLoadingVisible = true,
    this.textStyle,
    this.color = AppColors.primaryColor,
    this.fontSize = 16, // Default font size
  });

  @override
  Widget build(BuildContext context) {
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
              borderRadius: BorderRadius.circular(14),
              color: color,
            ),
            child: Center(
              child: (isLoading && isLoadingVisible)
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(icon),
                        const SizedBox(width: 10),
                        Text(
                          text,
                          style:
                              textStyle ??
                              AppThemes.f18w500.copyWith(
                                color: Colors.white,
                                fontSize: fontSize,
                              ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
