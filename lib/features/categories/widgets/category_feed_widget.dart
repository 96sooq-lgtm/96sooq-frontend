import 'package:_96_sooq/features/categories/bloc/category_feed_bloc/category_feed_bloc.dart';
import 'package:_96_sooq/features/categories/bloc/category_feed_bloc/category_feed_event.dart';
import 'package:_96_sooq/features/categories/bloc/category_feed_bloc/category_feed_state.dart';
import 'package:_96_sooq/features/categories/data/category_feed_api_service.dart';
import 'package:_96_sooq/features/categories/view/screens/category_feed_screen.dart';
import 'package:_96_sooq/features/home/widgets/product_card.dart';
import 'package:_96_sooq/features/home/widgets/product_detail_sheet.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_96_sooq/shared/global_widgets/section_header.dart';
import 'package:shimmer/shimmer.dart';

class CategoryFeedWidget extends StatefulWidget {
  final String categoryId;
  final String title;
  final String? governorate;

  const CategoryFeedWidget({
    Key? key,
    required this.categoryId,
    required this.title,
    this.governorate,
  }) : super(key: key);

  @override
  State<CategoryFeedWidget> createState() => _CategoryFeedWidgetState();
}

class _CategoryFeedWidgetState extends State<CategoryFeedWidget> {
  late CategoryFeedBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = CategoryFeedBloc(apiService: const CategoryFeedApiService());
    _bloc.add(
      FetchCategoryFeed(
        categoryId: widget.categoryId,
        governorate: widget.governorate,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant CategoryFeedWidget oldWidget) {
    if (oldWidget.governorate != widget.governorate) {
      _bloc.add(
        FetchCategoryFeed(
          categoryId: widget.categoryId,
          governorate: widget.governorate,
          isRefresh: true,
        ),
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<CategoryFeedBloc, CategoryFeedState>(
        builder: (context, state) {
          if (state.status == CategoryFeedStatus.initial ||
              (state.status == CategoryFeedStatus.loading &&
                  state.products.isEmpty)) {
            return _buildShimmer();
          }

          if (state.status == CategoryFeedStatus.failure &&
              state.products.isEmpty) {
            return const SizedBox.shrink(); // Hide if failed & empty
          }

          if (state.products.isEmpty) {
            return const SizedBox.shrink(); // Hide if empty
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: widget.title,
                action: localizations.seeAllText,
                onActionTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryFeedScreen(
                        categoryId: widget.categoryId,
                        categoryName: widget.title,
                        governorate: widget.governorate,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 250,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return SizedBox(
                      width: 160,
                      child: ProductCard(
                        product: product,
                        showFavoriteIcon: true,
                        showStatus: true,
                        showFeaturedOnlyStatus: true,
                        onTapProduct: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            useSafeArea: true,
                            builder: (context) =>
                                ProductDetailSheet(product: product),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(height: 20, width: 100, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 160,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
