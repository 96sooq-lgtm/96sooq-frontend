import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/features/categories/bloc/categories_bloc.dart';
import 'package:_96_sooq/features/categories/model/store_list_item_model.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96_sooq/features/root/bloc/root_bloc.dart';
import 'package:_96_sooq/features/root/bloc/root_event.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';
import 'package:shimmer/shimmer.dart';

class StoreListingWidget extends StatefulWidget {
  final List<StoreListItemModel> stores;
  final bool isLoading;
  final bool isPaginating;
  final void Function(StoreListItemModel store)? onStoreTap;
  final VoidCallback? onLoadMore;
  const StoreListingWidget({
    super.key,
    required this.stores,
    this.isLoading = false,
    this.isPaginating = false,
    this.onStoreTap,
    this.onLoadMore,
  });

  @override
  State<StoreListingWidget> createState() => _StoreListingWidgetState();
}

class _StoreListingWidgetState extends State<StoreListingWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations.storesTitle,
              style: isArabic
                  ? AppThemes.f16w600.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    )
                  : AppThemes.f16w600,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.read<CategoriesBloc>().add(StoresViewRequested());
                context.read<RootBloc>().add(ChangeTabEvent(1));
              },
              child: Row(
                children: [
                  Text(
                    localizations.seeAllText,
                    style: isArabic
                        ? AppThemes.f12w500.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.subTextBlue,
                          )
                        : AppThemes.f12w500.copyWith(
                            color: AppColors.subTextBlue,
                          ),
                  ),
                  const Icon(Icons.arrow_right, color: AppColors.subTextBlue),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: widget.isLoading && widget.stores.isEmpty
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Shimmer.fromColors(
                          baseColor: const Color(0xFFE6E6E6),
                          highlightColor: const Color(0xFFF5F5F5),
                          child: Container(
                            height: 102,
                            width: 102,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Shimmer.fromColors(
                          baseColor: const Color(0xFFE6E6E6),
                          highlightColor: const Color(0xFFF5F5F5),
                          child: Container(
                            height: 10,
                            width: 74,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                )
              : ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      widget.stores.length + (widget.isPaginating ? 2 : 0),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index >= widget.stores.length) {
                      return Column(
                        children: [
                          Shimmer.fromColors(
                            baseColor: const Color(0xFFE6E6E6),
                            highlightColor: const Color(0xFFF5F5F5),
                            child: Container(
                              height: 102,
                              width: 102,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Shimmer.fromColors(
                            baseColor: const Color(0xFFE6E6E6),
                            highlightColor: const Color(0xFFF5F5F5),
                            child: Container(
                              height: 10,
                              width: 74,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    }
                    final item = widget.stores[index];
                    return SizedBox(
                      width: 130,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onStoreTap?.call(item),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                AppNetworkImage(
                                  imageUrl: item.logo ?? '',
                                  height: 120,
                                  width: 120,
                                  borderRadius: BorderRadius.circular(16),
                                  fit: BoxFit.contain,
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
                            const SizedBox(height: 8),
                            Text(
                              item.displayName(
                                Localizations.localeOf(context).languageCode,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppThemes.f14w500,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
