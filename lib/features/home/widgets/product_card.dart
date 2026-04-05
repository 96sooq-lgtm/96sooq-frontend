import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/home/viewmodel/bloc/favorite_bloc/bloc/favorite_bloc.dart';
import 'package:_96_sooq/features/home/viewmodel/bloc/favorite_bloc/bloc/favorite_event.dart';
import 'package:_96_sooq/features/home/viewmodel/bloc/favorite_bloc/bloc/favorite_state.dart';
import 'package:_96_sooq/features/home/widgets/product_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_96_sooq/features/auth/bloc/auth_bloc.dart';
import 'package:_96_sooq/features/auth/screens/login_screen.dart';
import 'package:_96_sooq/features/root/bloc/root_bloc.dart';
import 'package:_96_sooq/features/root/bloc/root_event.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';
import 'package:flutter/services.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTapProduct,
    this.showFavoriteIcon = true,
    this.showStatus = false,
    this.showOwnerStatuses = false,
    this.showFeaturedOnlyStatus = false,
    this.onRejectedStatusTap,
  });

  final ProductModel product;
  final VoidCallback onTapProduct;
  final bool showFavoriteIcon;
  final bool showStatus;
  final bool showOwnerStatuses;
  final bool showFeaturedOnlyStatus;
  final VoidCallback? onRejectedStatusTap;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _favoriteAnimationController;
  late Animation<double> _favoriteScaleAnimation;

  String _formatPrice(String amount, String? currency) {
    final trimmedAmount = amount.trim();
    final parsedAmount = double.tryParse(trimmedAmount);
    final formattedAmount = parsedAmount != null
        ? parsedAmount.toStringAsFixed(3)
        : trimmedAmount;
    final currencyKey =
        (currency != null && currency.trim().isNotEmpty) ? currency.trim() : 'OMR';
    return '$formattedAmount $currencyKey';
  }

  @override
  void initState() {
    super.initState();
    _favoriteAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _favoriteScaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _favoriteAnimationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _favoriteAnimationController.dispose();
    super.dispose();
  }

  bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.product.status;
    final isPromoted = widget.product.isPromoted == true;
    final hasRegularStatus = status != null && status.isNotEmpty;
    final allowRegularStatuses =
        widget.showOwnerStatuses && !widget.showFeaturedOnlyStatus;
    final shouldShowStatusChip =
        widget.showStatus &&
        (isPromoted || (allowRegularStatuses && hasRegularStatus));
    return GestureDetector(
      onTap: widget.onTapProduct,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox.expand(
                      child: widget.product.imageUrl.isEmpty
                          ? Container(
                              color: const Color(0xFFE8E8E8),
                              child: const Center(
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 40,
                                  color: Color(0xFFBDBDBD),
                                ),
                              ),
                            )
                          : _isNetworkUrl(widget.product.imageUrl)
                          ? AppNetworkImage(
                              imageUrl: widget.product.imageUrl,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              widget.product.imageUrl,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  // Status chip — top right (directional end)
                  if (shouldShowStatusChip)
                    PositionedDirectional(
                      top: 0,
                      end: 0,
                      child:
                          status == 'rejected' &&
                              widget.onRejectedStatusTap != null
                          ? GestureDetector(
                              onTap: widget.onRejectedStatusTap,
                              child: ProductStatusChip(
                                status: status ?? '',
                                isFeatured: isPromoted,
                                fontSize: 9,
                                topEndRadius: 16,
                                bottomStartRadius: 16,
                              ),
                            )
                          : ProductStatusChip(
                              status: status ?? '',
                              isFeatured: isPromoted,
                              fontSize: 9,
                              topEndRadius: 16,
                              bottomStartRadius: 16,
                            ),
                    ),
                  if (widget.showFavoriteIcon)
                    PositionedDirectional(
                      top: 10,
                      start: 10,
                      child: BlocBuilder<FavoriteBloc, FavoriteState>(
                        builder: (context, state) {
                          final isFavoriteLocal = state.favorites.contains(
                            widget.product.id,
                          );
                          final isUnfavoriteLocal = state.unfavorites.contains(
                            widget.product.id,
                          );
                          final isFavorite =
                              isFavoriteLocal ||
                              (widget.product.isFavorite && !isUnfavoriteLocal);

                          return GestureDetector(
                            onTap: () async {
                              HapticFeedback.lightImpact();

                              final authState = context.read<AuthBloc>().state;
                              if (authState is! AuthAuthenticated) {
                                // Not logged in, redirect to login screen
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );

                                // If login was successful, change tab to Deals (index 2)
                                if (result == true && context.mounted) {
                                  context.read<RootBloc>().add(
                                    ChangeTabEvent(2),
                                  );
                                }
                                return;
                              }

                              _favoriteAnimationController.forward(from: 0.0);
                              context.read<FavoriteBloc>().add(
                                ToggleFavoriteEvent(
                                  widget.product.id,
                                  initialFavoriteState: isFavorite,
                                ),
                              );
                            },
                            child: AnimatedBuilder(
                              animation: _favoriteScaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _favoriteScaleAnimation.value,
                                  child: child,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 18,
                                  color: isFavorite
                                      ? AppColors.favoriteRed
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _formatPrice(widget.product.amount, widget.product.currency),
              style: AppThemes.f14w600,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              widget.product.title,
              style: AppThemes.f12w500,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.product.details,
              style: AppThemes.f12w400.copyWith(color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
