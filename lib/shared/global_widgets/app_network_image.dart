import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:_96_sooq/shared/global_widgets/network_image_shimmer.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.fallbackIcon,
    this.fallbackWidget,
    this.backgroundColor,
    this.showErrorIcon = true,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final IconData? fallbackIcon;
  final Widget? fallbackWidget;
  final Color? backgroundColor;
  final bool showErrorIcon;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl.trim();
    if (trimmedUrl.isEmpty) {
      return _buildFallback();
    }

    final networkImage = CachedNetworkImage(
      imageUrl: trimmedUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 120),
      placeholder: (context, url) => NetworkImageShimmer(
        width: width,
        height: height,
        borderRadius: borderRadius,
        shape: shape,
      ),
      errorWidget: (context, url, error) => _buildFallback(),
    );

    if (shape == BoxShape.circle) {
      return ClipOval(child: networkImage);
    }
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: networkImage);
    }
    return networkImage;
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        color: backgroundColor ?? const Color(0xFFE5E7EB),
      ),
      child:
          fallbackWidget ??
          (showErrorIcon
              ? Icon(
                  fallbackIcon ?? Icons.image_not_supported_outlined,
                  color: const Color(0xFF9CA3AF),
                )
              : null),
    );
  }
}
