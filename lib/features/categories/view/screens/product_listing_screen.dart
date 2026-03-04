import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/home/widgets/offers_widget.dart';
import 'package:_96_sooq/features/home/widgets/product_card.dart';
import 'package:_96_sooq/features/home/widgets/product_detail_sheet.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:_96_sooq/features/offers/bloc/offers_bloc.dart';
import 'package:_96_sooq/features/offers/bloc/offers_state.dart';
import 'package:_96_sooq/features/categories/widgets/product_filter_bottom_sheet.dart';
import 'package:_96_sooq/features/categories/bloc/product_listing/product_listing_bloc.dart';
import 'package:_96_sooq/features/categories/bloc/product_listing/product_listing_event.dart';
import 'package:_96_sooq/features/categories/bloc/product_listing/product_listing_state.dart';
import 'package:_96_sooq/features/categories/data/product_listing_api_service.dart';
import 'package:_96_sooq/core/bloc/location/bloc/location_bloc.dart';

class ProductListingScreen extends StatelessWidget {
  const ProductListingScreen({
    super.key,
    required this.categoryId,
    this.searchQuery,
  });

  final String categoryId;
  final String? searchQuery;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductListingBloc(
        apiService: ProductListingApiService(),
        locationBloc: context.read<LocationBloc>(),
      )..add(FetchProducts(categoryId, searchQuery: searchQuery)),
      child: const _ProductListingView(),
    );
  }
}

class _ProductListingView extends StatefulWidget {
  const _ProductListingView();

  @override
  State<_ProductListingView> createState() => _ProductListingViewState();
}

class _ProductListingViewState extends State<_ProductListingView> {
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
    if (_isBottom) {
      context.read<ProductListingBloc>().add(LoadMoreProducts());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BackButtonWidget(ontap: () => Navigator.pop(context)),
                  const SizedBox(width: 16),
                  // Expanded(
                  //   child: BlocBuilder<ProductListingBloc, ProductListingState>(
                  //     buildWhen: (previous, current) =>
                  //         previous.category != current.category,
                  //     builder: (context, state) {
                  //       if (state.category == null)
                  //         return const SizedBox.shrink();
                  //       final localeCode = Localizations.localeOf(
                  //         context,
                  //       ).languageCode;
                  //       return Text(
                  //         state.category!.displayName(localeCode),
                  //         style: AppThemes.f18w600,
                  //         maxLines: 1,
                  //         overflow: TextOverflow.ellipsis,
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 16),
              // BlocBuilder<OffersBloc, OffersState>(
              //   builder: (context, state) {
              //     if (state.offers.isEmpty &&
              //         state.status != OffersStatus.loading) {
              //       return const SizedBox.shrink();
              //     }
              //     return const Column(
              //       children: [OffersWidget(), SizedBox(height: 20)],
              //     );
              //   },
              // ),
              Expanded(
                child: BlocBuilder<ProductListingBloc, ProductListingState>(
                  builder: (context, state) {
                    if (state.status == ProductListingStatus.initial ||
                        (state.status == ProductListingStatus.loading &&
                            state.products.isEmpty)) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _buildShimmerGrid(),
                      );
                    }

                    if (state.status == ProductListingStatus.failure &&
                        state.products.isEmpty) {
                      return _buildNoResultWidget();
                    }

                    if (state.products.isEmpty) {
                      return _buildNoResultWidget();
                    }

                    final leftColumnProducts = <ProductModel>[];
                    final rightColumnProducts = <ProductModel>[];

                    for (var i = 0; i < state.products.length; i++) {
                      if (i.isEven) {
                        leftColumnProducts.add(state.products[i]);
                      } else {
                        rightColumnProducts.add(state.products[i]);
                      }
                    }

                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _FilterButton(
                                  onTap: () async {
                                    final result =
                                        await showModalBottomSheet<
                                          Map<String, dynamic>
                                        >(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) =>
                                              ProductFilterBottomSheet(
                                                initialMinPrice: state.minPrice,
                                                initialMaxPrice: state.maxPrice,
                                                initialCondition:
                                                    state.condition,
                                                initialSellerType:
                                                    state.sellerType,
                                              ),
                                        );
                                    if (result != null && mounted) {
                                      context.read<ProductListingBloc>().add(
                                        ApplyFilters(
                                          minPrice: result['minPrice'],
                                          maxPrice: result['maxPrice'],
                                          condition: result['condition'],
                                          sellerType: result['sellerType'],
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 22),
                                for (final product in leftColumnProducts)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: ProductCard(
                                      product: product,
                                      onTapProduct: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          builder: (_) => ProductDetailSheet(
                                            product: product,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                if (!state.hasReachedMax &&
                                    leftColumnProducts.length >
                                        rightColumnProducts.length)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: CircularProgressIndicator(),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              children: [
                                for (final product in rightColumnProducts)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: ProductCard(
                                      product: product,
                                      onTapProduct: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.white,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          builder: (_) => ProductDetailSheet(
                                            product: product,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                if (!state.hasReachedMax &&
                                    rightColumnProducts.length >=
                                        leftColumnProducts.length)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AppAssets.noResultIc),
            const SizedBox(height: 28),
            Text(
              'No result Found !',
              style: AppThemes.f18w600.copyWith(color: const Color(0xFF6E7486)),
            ),
            const SizedBox(height: 10),
            Text(
              'There is no result for your search.\nCome on, try again!',
              textAlign: TextAlign.center,
              style: AppThemes.f14w400.copyWith(color: const Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.67,
      ),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: const Color(0xFFE6E6E6),
        highlightColor: const Color(0xFFF5F5F5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 190,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              localizations.searchFilterTitle,
              style: AppThemes.f16w600.copyWith(color: Colors.white),
            ),
            const Spacer(),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tune, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
