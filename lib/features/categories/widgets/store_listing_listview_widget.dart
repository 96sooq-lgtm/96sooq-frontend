import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/categories/model/store_list_item_model.dart';
import 'package:flutter/material.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';
import 'package:shimmer/shimmer.dart';

class StoresListingListviewWidget extends StatelessWidget {
  final List<StoreListItemModel> stores;
  final bool isInitialLoading;
  final bool isPaginating;
  final void Function(StoreListItemModel store)? onStoreTap;

  const StoresListingListviewWidget({
    super.key,
    required this.stores,
    this.isInitialLoading = false,
    this.isPaginating = false,
    this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final itemCount = isInitialLoading
        ? 6
        : stores.length + (isPaginating ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Store list (2 per row)
        GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20),
          primary: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            final showPaginationLoader =
                !isInitialLoading && isPaginating && index == stores.length;
            if (isInitialLoading || showPaginationLoader) {
              return _buildShimmerTile();
            }

            final item = stores[index];

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onStoreTap?.call(item),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        AppNetworkImage(
                          imageUrl: item.logo ?? '',
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(16),
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        if (item.averageRating > 0.0)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _buildReview(item.averageRating),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.displayName(localeCode),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppThemes.f14w500,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildShimmerTile() {
    return Column(
      children: [
        Expanded(
          child: Shimmer.fromColors(
            baseColor: const Color(0xFFE6E6E6),
            highlightColor: const Color(0xFFF5F5F5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: const Color(0xFFE6E6E6),
          highlightColor: const Color(0xFFF5F5F5),
          child: Container(height: 10, width: 90, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildReview(double rating) {
    if (rating == 0.0) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(Icons.star_outline, size: 14, color: Color(0xFFE9BD0E)),
        Text(rating.toStringAsFixed(1), style: AppThemes.f12w500),
      ],
    );
  }
}
