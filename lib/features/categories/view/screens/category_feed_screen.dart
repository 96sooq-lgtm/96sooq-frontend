import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/features/categories/bloc/category_feed_bloc/category_feed_bloc.dart';
import 'package:_96_sooq/features/categories/bloc/category_feed_bloc/category_feed_event.dart';
import 'package:_96_sooq/features/categories/bloc/category_feed_bloc/category_feed_state.dart';
import 'package:_96_sooq/features/categories/data/category_feed_api_service.dart';
import 'package:_96_sooq/features/home/widgets/product_card.dart';
import 'package:_96_sooq/features/home/widgets/product_detail_sheet.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryFeedScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String? governorate;

  const CategoryFeedScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    this.governorate,
  }) : super(key: key);

  @override
  State<CategoryFeedScreen> createState() => _CategoryFeedScreenState();
}

class _CategoryFeedScreenState extends State<CategoryFeedScreen> {
  late ScrollController _scrollController;
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
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_bloc.state.hasReachedMax &&
          _bloc.state.status != CategoryFeedStatus.loading) {
        _bloc.add(
          FetchCategoryFeed(
            categoryId: widget.categoryId,
            governorate: widget.governorate,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BackButtonWidget(ontap: () => Navigator.pop(context)),
          ),
          title: BlocBuilder<CategoryFeedBloc, CategoryFeedState>(
            builder: (context, state) {
              final title = state.category?.nameEn ?? widget.categoryName;
              return Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              );
            },
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<CategoryFeedBloc, CategoryFeedState>(
          builder: (context, state) {
            if (state.status == CategoryFeedStatus.initial ||
                (state.status == CategoryFeedStatus.loading &&
                    state.products.isEmpty)) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            }

            if (state.status == CategoryFeedStatus.failure &&
                state.products.isEmpty) {
              return Center(
                child: Text('Failed to load products: ${state.errorMessage}'),
              );
            }

            if (state.products.isEmpty) {
              return const Center(child: Text('No products found.'));
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 16.0,
                          childAspectRatio: 0.65,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = state.products[index];
                      return ProductCard(
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
                      );
                    }, childCount: state.products.length),
                  ),
                ),
                if (!state.hasReachedMax)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
