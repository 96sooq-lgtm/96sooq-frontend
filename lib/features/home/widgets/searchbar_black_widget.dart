import 'dart:io';

import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:_96_sooq/constants/app_themes.dart';

class SearchbarBlackWidget extends StatelessWidget {
  SearchbarBlackWidget({
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    this.hintStyle,
    super.key,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.suffixButton,
    this.maxLines = 1,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.readOnly = false,
    this.focusNode,
    this.onFieldSubmitted,
    this.isImageSearch = false,
  });

  final String labelText;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final TextEditingController controller;
  final bool enabled;
  final TextStyle? hintStyle;
  final AutovalidateMode? autovalidateMode;
  final IconButton? suffixButton;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final bool? isImageSearch;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      autovalidateMode: autovalidateMode,
      cursorColor: AppColors.white,
      enabled: enabled,
      style: AppThemes.f14w400.copyWith(color: AppColors.white),
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: labelText,
        prefixIcon: Image.asset(
          AppAssets.searchIconWhite,
          height: 24,
          width: 24,
        ),
        filled: true,
        fillColor: AppColors.white.withOpacity(0.10),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        hintStyle:
            hintStyle ?? AppThemes.f14w400.copyWith(color: AppColors.white),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(200)),
          borderSide: BorderSide.none,
        ),
        // enabledBorder: OutlineInputBorder(
        //   borderRadius: const BorderRadius.all(Radius.circular(10)),
        //   borderSide: BorderSide(color: AppColor.textFormFieldBorder),
        // ),
        // focusedBorder: OutlineInputBorder(
        //   borderRadius: const BorderRadius.all(Radius.circular(10)),
        //   borderSide: BorderSide(color: AppColor.textFormFieldBorder),
        // ),
        // errorBorder: const OutlineInputBorder(
        //   borderRadius: BorderRadius.all(Radius.circular(10)),
        //   borderSide: BorderSide(color: Colors.red),
        // ),
        // focusedErrorBorder: const OutlineInputBorder(
        //   borderRadius: BorderRadius.all(Radius.circular(10)),
        //   borderSide: BorderSide(color: Colors.red, width: 2.0),
        // ),
        suffixIcon: suffixButton,
      ),
      onChanged: onChanged,
      validator: validator,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      textInputAction: TextInputAction.search,
    );
  }
}
