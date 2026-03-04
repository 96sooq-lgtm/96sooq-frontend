import 'package:_96_sooq/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:_96_sooq/constants/app_themes.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    required this.labelText,
    required this.controller,
    this.obscureText = false,
    this.hintStyle,
    this.style,
    super.key,
    this.enabled = true,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.suffixIcon,
    this.maxLines = 1,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.prefixIcon,
    this.inputFormatters,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final String labelText;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final TextEditingController controller;
  final bool enabled;
  final TextStyle? hintStyle;
  final TextStyle? style;
  final AutovalidateMode? autovalidateMode;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? AppThemes.f14w500;
    return TextFormField(
      readOnly: readOnly,
      maxLines: maxLines,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      onTap: onTap,
      autovalidateMode: autovalidateMode,
      cursorColor: AppColors.primaryColor,
      enabled: enabled,
      style: effectiveStyle,
      controller: controller,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.03),
        hintText: labelText,
        hintStyle:
            hintStyle ?? AppThemes.f14w400.copyWith(color: Color(0xFF465569)),
        prefixIcon: prefixIcon,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xF0F0F0F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xF0F0F0F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Color(0xF0F0F0F0)),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
        helperText: '',
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 18,
        ),
        suffixIcon: suffixIcon, // Use suffixButton here
      ),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
    );
  }
}
