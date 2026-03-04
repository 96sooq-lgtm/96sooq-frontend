import 'package:flutter/material.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';

class Textfieldlabeltext extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  static TextStyle get defaultStyle =>
      AppThemes.f12w400.copyWith(color: AppColors.productListingTextColor);

  const Textfieldlabeltext({
    super.key,
    required this.text,
    this.textStyle,
    this.padding = const EdgeInsetsDirectional.only(start: 30),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(text, style: textStyle ?? defaultStyle),
    );
  }
}
