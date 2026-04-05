import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/home/widgets/product_card.dart';
import 'package:_96_sooq/features/home/widgets/product_detail_sheet.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/features/deals/viewmodel/bloc/favorites_list_bloc/favorites_list_bloc.dart';
import 'package:_96_sooq/features/deals/viewmodel/bloc/favorites_list_bloc/favorites_list_event.dart';
import 'package:_96_sooq/features/deals/viewmodel/bloc/favorites_list_bloc/favorites_list_state.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FavoutireScreen extends StatefulWidget {
  const FavoutireScreen({super.key});

  @override
  State<FavoutireScreen> createState() => _FavoutireScreenState();
}

class _FavoutireScreenState extends State<FavoutireScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<FavoritesListBloc>().add(RefreshFavoritesListEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<FavoritesListBloc>().add(LoadFavoritesListEvent());
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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  BackButtonWidget(ontap: () => Navigator.pop(context)),
                  Expanded(
                    child: Text(
                      localizations.favoritesTitle,
                      textAlign: TextAlign.center,
                      style: AppThemes.f16w600,
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<FavoritesListBloc, FavoritesListState>(
                  builder: (context, state) {
                    if (state is FavoritesListInitial ||
                        (state is FavoritesListLoading && state.isFirstFetch)) {
                      return _buildShimmerGrid();
                    }
                    if (state is FavoritesListError) {
                      return Center(child: Text(state.message));
                    }

                    List<ProductModel> products = [];
                    bool hasReachedMax = false;

                    if (state is FavoritesListLoading) {
                      products = state.oldFavorites;
                    } else if (state is FavoritesListLoaded) {
                      products = state.favorites;
                      hasReachedMax = state.hasReachedMax;
                    }

                    if (products.isEmpty) {
                      return Center(child: Text(localizations.noFavoritesYet));
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<FavoritesListBloc>().add(
                          RefreshFavoritesListEvent(),
                        );
                      },
                      child: GridView.builder(
                        controller: _scrollController,
                        itemCount: products.length + (hasReachedMax ? 0 : 1),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.68,
                            ),
                        itemBuilder: (context, index) {
                          if (index >= products.length) {
                            return _buildShimmerGrid();
                          }
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            onTapProduct: () =>
                                _openProductDetailSheet(context, product),
                          );
                        },
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

  void _openProductDetailSheet(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ProductDetailSheet(product: product),
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
