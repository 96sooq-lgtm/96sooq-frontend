import 'package:_96_sooq/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  final Function() ontap;
  final Color? backgroundcolor; // Add this parameter

  const BackButtonWidget({
    super.key,
    required this.ontap,
    this.backgroundcolor,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: ontap,
      child: Container(
        width: 43,
        height: 43,
        padding: EdgeInsetsDirectional.only(
          start: isRtl ? 6 : 0,
          end: isRtl ? 0 : 0,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFF7F7F7),
        ),
        child: Center(
          child: Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF1F2937)),
        ),
      ),
    );
  }
}
