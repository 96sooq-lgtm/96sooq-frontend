import 'package:_96_sooq/core/bloc/location/bloc/location_bloc.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96_sooq/features/categories/bloc/categories_bloc.dart';
import 'package:_96_sooq/features/categories/bloc/store_bloc/store_bloc.dart';
import 'package:_96_sooq/features/categories/model/category_model.dart';
import 'package:_96_sooq/features/categories/view/screens/product_listing_screen.dart';
import 'package:_96_sooq/features/categories/widgets/store_listing_listview_widget.dart';
import 'package:_96_sooq/features/categories/widgets/store_filter_dialog.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/home/widgets/product_detail_sheet.dart';
import 'package:_96_sooq/features/profile/view/screens/store_details_screen.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/features/search/view/screens/search_screen.dart';
import 'package:_96_sooq/shared/global_widgets/search_white_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int selectedCategoryIndex = 0;
  bool _isStoresSelectionLocked = false;
  final TextEditingController searchController = TextEditingController();
  final ScrollController _storesScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _storesScrollController.addListener(_onStoresScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _requestInitialStores();
    });
  }

  List<String> _buildCategoryLabels(
    List<CategoryModel> categories,
    String localeCode,
    String storesLabel,
  ) {
    final labels = <String>[storesLabel];
    labels.addAll(categories.map((c) => c.displayName(localeCode)));
    return labels;
  }

  @override
  void dispose() {
    _storesScrollController.removeListener(_onStoresScroll);
    _storesScrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _onStoresScroll() {
    if (selectedCategoryIndex != 0) return;
    if (!_storesScrollController.hasClients) return;

    final position = _storesScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<StoreBloc>().add(const CategoryStoresLoadMoreRequested());
    }
  }

  String? _resolvedLocationId(LocationState state) {
    if (state.isCountryFallback) return null;
    return state.selectedState?.id;
  }

  void _requestInitialStores() {
    final locationId = _resolvedLocationId(context.read<LocationBloc>().state);
    context.read<StoreBloc>().add(
      CategoryStoresInitialRequested(locationId: locationId),
    );
  }

  void _onCategoryTapped(
    BuildContext context,
    int index,
    List<CategoryModel> categories,
  ) {
    if (index == selectedCategoryIndex) {
      return;
    }

    setState(() {
      selectedCategoryIndex = index;
      _isStoresSelectionLocked = index == 0;
    });

    if (index == 0) {
      _requestInitialStores();
      return;
    }

    final parentIndex = index - 1;
    if (parentIndex < 0 || parentIndex >= categories.length) {
      return;
    }

    context.read<CategoriesBloc>().add(
      SubCategoriesRequested(categories[parentIndex].id),
    );
  }

  Widget _buildSubCategorySection({
    required BuildContext context,
    required CategoriesState state,
    required bool isArabic,
    required String localeCode,
  }) {
    switch (state.subCategoriesStatus) {
      case SubCategoriesStatus.initial:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.selectCategoryPrompt,
              style: AppThemes.f12w500,
              textAlign: TextAlign.center,
            ),
          ),
        );
      case SubCategoriesStatus.loading:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: _buildSubCategoryLoadingGrid(isArabic: isArabic),
        );
      case SubCategoriesStatus.error:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: _SubCategoryErrorWidget(
            message: state.subCategoriesError ?? AppLocalizations.of(context)!.failedToLoadSubcategories,
            onRetry: () {
              final parentId = state.selectedParentId;
              if (parentId == null || parentId.isEmpty) {
                return;
              }
              context.read<CategoriesBloc>().add(
                SubCategoriesRequested(parentId),
              );
            },
          ),
        );
      case SubCategoriesStatus.loaded:
        if (state.subCategories.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.noSubcategoriesFound,
                style: AppThemes.f12w500,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return _buildSubCategoryGrid(
          subCategories: state.subCategories,
          isArabic: isArabic,
          localeCode: localeCode,
        );
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<StoreBloc>(),
        child: const StoreFilterDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<CategoriesBloc, CategoriesState>(
            listenWhen: (previous, current) =>
                previous.storesViewRequestVersion !=
                current.storesViewRequestVersion,
            listener: (context, state) {
              if (!mounted) return;
              setState(() {
                selectedCategoryIndex = 0;
                _isStoresSelectionLocked = true;
              });
              _requestInitialStores();
            },
          ),
          BlocListener<LocationBloc, LocationState>(
            listenWhen: (previous, current) =>
                previous.selectedState?.id != current.selectedState?.id ||
                previous.isCountryFallback != current.isCountryFallback,
            listener: (context, state) {
              if (selectedCategoryIndex == 0) {
                _requestInitialStores();
              }
            },
          ),
        ],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
                        );
                      },
                      child: AbsorbPointer(
                        child: SearchbarWhiteWidget(
                          labelText: "${localizations.search}...",
                          controller: searchController,
                          enabled: false,
                        ),
                      ),
                    ),
                  ),
                  if (selectedCategoryIndex == 0) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _showFilterDialog,
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.black.withValues(alpha: 0.03),
                        child: Center(
                          child: Icon(Icons.tune, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Divider(color: Color(0xFFD9D9D9), height: 1),
            Expanded(
              child: BlocBuilder<CategoriesBloc, CategoriesState>(
                builder: (context, state) {
                  if (state.categoriesStatus == CategoriesStatus.loading &&
                      state.categories.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.categoriesStatus == CategoriesStatus.error &&
                      state.categories.isEmpty) {
                    return _RootCategoriesErrorWidget(
                      message:
                          state.categoriesError ?? localizations.failedToLoadCategories,
                      onRetry: () {
                        context.read<CategoriesBloc>().add(
                          CategoriesRequested(),
                        );
                      },
                    );
                  }

                  final localeCode = Localizations.localeOf(
                    context,
                  ).languageCode;
                  final apiCategories = state.categories;
                  final categoryLabels = _buildCategoryLabels(
                    apiCategories,
                    localeCode,
                    localizations.storesTitle,
                  );

                  final selectedParentId = state.selectedParentId;
                  if (!_isStoresSelectionLocked &&
                      selectedParentId != null &&
                      selectedParentId.isNotEmpty) {
                    final parentIndex = apiCategories.indexWhere(
                      (category) => category.id == selectedParentId,
                    );
                    if (parentIndex >= 0) {
                      selectedCategoryIndex = parentIndex + 1;
                    }
                  }

                  final safeSelectedIndex = selectedCategoryIndex
                      .clamp(
                        0,
                        categoryLabels.isEmpty ? 0 : categoryLabels.length - 1,
                      )
                      .toInt();
                  if (safeSelectedIndex != selectedCategoryIndex) {
                    selectedCategoryIndex = safeSelectedIndex;
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSidebar(
                        categoryLabels: categoryLabels,
                        selectedIndex: selectedCategoryIndex,
                        isArabic: isArabic,
                        onCategoryTap: (index) {
                          _onCategoryTapped(context, index, apiCategories);
                        },
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _storesScrollController,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedCategoryIndex == 0) ...[
                                BlocBuilder<StoreBloc, StoreState>(
                                  buildWhen: (previous, current) =>
                                      previous.categoryStatus !=
                                          current.categoryStatus ||
                                      previous.categoryStores !=
                                          current.categoryStores ||
                                      previous.isPaginating !=
                                          current.isPaginating ||
                                      previous.categoryError !=
                                          current.categoryError,
                                  builder: (context, storeState) {
                                    if (storeState.categoryStatus ==
                                            StoreLoadStatus.failure &&
                                        storeState.categoryStores.isEmpty) {
                                      return _RootCategoriesErrorWidget(
                                        message:
                                            storeState.categoryError ??
                                            localizations.failedToLoadStores,
                                        onRetry: _requestInitialStores,
                                      );
                                    }

                                    return StoresListingListviewWidget(
                                      stores: storeState.categoryStores,
                                      isInitialLoading:
                                          storeState.categoryStatus ==
                                              StoreLoadStatus.loading &&
                                          storeState.categoryStores.isEmpty,
                                      isPaginating: storeState.isPaginating,
                                      onStoreTap: (store) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => StoreDetailsScreen(
                                              isMyStore: false,
                                              storeId: store.id,
                                              storeName: store.name,
                                              storeNameAr: store.nameAr,
                                              storeDescription:
                                                  store.description,
                                              storeLogoUrl: store.logo,
                                              storeLocation: store.wilayat,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ] else ...[
                                _buildSubCategorySection(
                                  context: context,
                                  state: state,
                                  isArabic: isArabic,
                                  localeCode: localeCode,
                                ),
                                // const SizedBox(height: 24),
                                // ProductListingWidget(
                                //   category: localizations.latestPicksTitle,
                                //   onProductTap: (product) {
                                //     showProductDetailSheet(
                                //       context: context,
                                //       product: product,
                                //     );
                                //   },
                                //   products: [
                                //     ProductModel(
                                //       id: '1',
                                //       title: 'Samsung Galaxy',
                                //       details: 'S24 256 GB',
                                //       amount: '125 OMR',
                                //       imageUrl:
                                //           'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=900&q=80',
                                //     ),
                                //     ProductModel(
                                //       id: '2',
                                //       title: 'iPhone 15',
                                //       details: '128 GB',
                                //       amount: '320 OMR',
                                //       imageUrl:
                                //           'https://images.unsplash.com/photo-1580910051074-3eb694886505?w=900&q=80',
                                //     ),
                                //     ProductModel(
                                //       id: '3',
                                //       title: 'MacBook Air',
                                //       details: 'M2 16GB',
                                //       amount: '540 OMR',
                                //       imageUrl:
                                //           'https://images.unsplash.com/photo-1605236453806-6ff36851218e?w=900&q=80',
                                //     ),
                                //     ProductModel(
                                //       id: '4',
                                //       title: 'Sony Headphones',
                                //       details: 'WH-1000XM5',
                                //       amount: '90 OMR',
                                //       imageUrl:
                                //           'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=900&q=80',
                                //     ),
                                //   ],
                                //   onSeeAllTap: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) => ProductListingScreen(
                                //           categoryId: selectedCategoryIndex > 0
                                //               ? apiCategories[selectedCategoryIndex -
                                //                         1]
                                //                     .id
                                //               : '',
                                //         ),
                                //       ),
                                //     );
                                //   },
                                // ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar({
    required List<String> categoryLabels,
    required int selectedIndex,
    required bool isArabic,
    required ValueChanged<int> onCategoryTap,
  }) {
    return Container(
      width: 110,
      decoration: const BoxDecoration(
        border: BorderDirectional(end: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemCount: categoryLabels.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () => onCategoryTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: isSelected ? BorderRadius.circular(20) : null,
              ),
              child: Column(
                children: [
                  if (index == 0) ...[
                    SvgPicture.asset(
                      isSelected
                          ? 'assets/icons/store_selected_ic.svg'
                          : 'assets/icons/store_unselected_ic.svg',
                      width: 20,
                      height: 20,
                      colorFilter: isSelected
                          ? const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            )
                          : null,
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    categoryLabels[index],
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: isSelected
                        ? (isArabic
                              ? AppThemes.f12w600.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                )
                              : AppThemes.f12w600.copyWith(color: Colors.white))
                        : (isArabic
                              ? AppThemes.f12w500.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                )
                              : AppThemes.f12w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void showProductDetailSheet({
    required BuildContext context,
    required ProductModel product,
  }) {
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
}

class _RootCategoriesErrorWidget extends StatelessWidget {
  const _RootCategoriesErrorWidget({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppThemes.f12w500,
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.retryText)),
          ],
        ),
      ),
    );
  }
}

class _SubCategoryErrorWidget extends StatelessWidget {
  const _SubCategoryErrorWidget({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E7E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: AppThemes.f12w500),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.retryText)),
          ),
        ],
      ),
    );
  }
}

Widget _buildSubCategoryGrid({
  required List<CategoryModel> subCategories,
  required bool isArabic,
  required String localeCode,
}) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(vertical: 20),
    itemCount: subCategories.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 0.7,
      crossAxisSpacing: 10,
      mainAxisSpacing: 16,
    ),
    itemBuilder: (context, index) {
      final subCategory = subCategories[index];
      final imageUrl = subCategory.imageUrl;

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductListingScreen(categoryId: subCategory.id),
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFFD9D9D9),
              child: ClipOval(
                child: imageUrl.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl: imageUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        shape: BoxShape.circle,
                        fallbackIcon: Icons.image_outlined,
                      )
                    : _buildSubCategoryImageFallback(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subCategory.displayName(localeCode),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: isArabic
                  ? AppThemes.f10w400.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    )
                  : AppThemes.f10w400,
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildSubCategoryImageFallback() {
  return const SizedBox(
    width: 64,
    height: 64,
    child: Icon(Icons.image_outlined, color: Color(0xFF8A8A8A), size: 24),
  );
}

Widget _buildSubCategoryLoadingGrid({required bool isArabic}) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(vertical: 20),
    itemCount: 9,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 0.7,
      crossAxisSpacing: 10,
      mainAxisSpacing: 16,
    ),
    itemBuilder: (context, index) {
      return Column(
        children: [
          Shimmer.fromColors(
            baseColor: const Color(0xFFE6E6E6),
            highlightColor: const Color(0xFFF5F5F5),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD9D9D9)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: const Color(0xFFE6E6E6),
            highlightColor: const Color(0xFFF5F5F5),
            child: Container(
              width: isArabic ? 68 : 60,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Shimmer.fromColors(
            baseColor: const Color(0xFFE6E6E6),
            highlightColor: const Color(0xFFF5F5F5),
            child: Container(
              width: isArabic ? 52 : 46,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      );
    },
  );
}
