import 'package:flutter/material.dart';

/// A small chip that displays the listing status with color-coded background.
///
/// Colors:
///   draft → blue, pending_approval → yellow/amber, active → green,
///   rejected → red, sold → black (primary), expired → grey.
class ProductStatusChip extends StatelessWidget {
  const ProductStatusChip({
    super.key,
    required this.status,
    this.isFeatured = false,
    this.fontSize = 10,
    this.topEndRadius = 16,
    this.bottomStartRadius = 16,
  });

  final String status;
  final bool isFeatured;
  final double fontSize;
  final double topEndRadius;
  final double bottomStartRadius;

  static Color _bgColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.blue;
      case 'pending_approval':
      case 'pending':
        return const Color(0xFFE2B400);
      case 'active':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'sold':
        return Colors.black;
      case 'expired':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  static String _label(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'pending_approval':
      case 'pending':
        return 'Pending';
      case 'active':
        return 'Active';
      case 'rejected':
        return 'Rejected';
      case 'sold':
        return 'Sold';
      case 'expired':
        return 'Expired';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = isFeatured ? Colors.black : _bgColor(status);
    final label = isFeatured ? '96 PROMOTED' : _label(status).toUpperCase();
    final textColor = isFeatured ? const Color(0xFFFFD700) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isFeatured ? bg : bg.withValues(alpha: 0.75),
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(topEndRadius),
          bottomStart: Radius.circular(bottomStartRadius),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
