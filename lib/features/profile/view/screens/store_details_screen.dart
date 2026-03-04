import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/core/s3_upload/s3_upload_service.dart';
import 'package:_96_sooq/features/addlist/bloc/store_creation/store_creation_bloc.dart';
import 'package:_96_sooq/features/addlist/view/screens/create_your_store_screen.dart';
import 'package:_96_sooq/features/auth/screens/login_screen.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/home/widgets/product_card.dart';
import 'package:_96_sooq/features/home/widgets/product_detail_sheet.dart';
import 'package:_96_sooq/features/profile/bloc/store_details/store_details_cubit.dart';
import 'package:_96_sooq/features/profile/bloc/store_details/store_details_state.dart';
import 'package:_96_sooq/features/profile/bloc/profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/profile_state.dart';
import 'package:_96_sooq/features/profile/model/store_check_response_model.dart';
import 'package:_96_sooq/features/profile/model/store_review_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class StoreDetailsScreen extends StatelessWidget {
  const StoreDetailsScreen({
    super.key,
    this.isMyStore = false,
    this.storeId,
    this.storeName,
    this.storeNameAr,
    this.storeDescription,
    this.storeLogoUrl,
    this.storeLocation,
  });

  final bool isMyStore;
  final String? storeId;
  final String? storeName;
  final String? storeNameAr;
  final String? storeDescription;
  final String? storeLogoUrl;
  final String? storeLocation;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StoreDetailsCubit(),
      child: _StoreDetailsScreenView(
        isMyStore: isMyStore,
        storeId: storeId,
        storeName: storeName,
        storeNameAr: storeNameAr,
        storeDescription: storeDescription,
        storeLogoUrl: storeLogoUrl,
        storeLocation: storeLocation,
      ),
    );
  }
}

class _StoreDetailsScreenView extends StatefulWidget {
  const _StoreDetailsScreenView({
    required this.isMyStore,
    this.storeId,
    this.storeName,
    this.storeNameAr,
    this.storeDescription,
    this.storeLogoUrl,
    this.storeLocation,
  });

  final bool isMyStore;
  final String? storeId;
  final String? storeName;
  final String? storeNameAr;
  final String? storeDescription;
  final String? storeLogoUrl;
  final String? storeLocation;

  @override
  State<_StoreDetailsScreenView> createState() =>
      _StoreDetailsScreenViewState();
}

enum _StoreDetailsTab { posts, reviews }

class _StoreDetailsScreenViewState extends State<_StoreDetailsScreenView> {
  _StoreDetailsTab _selectedTab = _StoreDetailsTab.posts;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<StoreDetailsCubit>().fetchStoreDetails(
      storeId: widget.storeId,
      isMyStore: widget.isMyStore,
    );
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
      final storeId = widget.storeId;
      if (storeId == null || storeId.isEmpty) return;
      if (_selectedTab == _StoreDetailsTab.posts) {
        context.read<StoreDetailsCubit>().loadMoreListings(storeId: storeId);
      } else {
        context.read<StoreDetailsCubit>().loadMoreReviews(storeId: storeId);
      }
    }
  }

  static const String _fallbackStoreName = '';
  static const String _fallbackStoreLocation = '';
  static const String _fallbackStoreDescription = '';

  Future<void> _navigateToEditStore(StoreProfileModel store) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => StoreCreationBloc(
            s3UploadService: S3UploadService(DioServices.client),
          ),
          child: CreateYourStoreScreen(existingStore: store),
        ),
      ),
    );
    if (result == true && mounted) {
      final cubit = context.read<StoreDetailsCubit>();
      cubit.fetchStoreDetails(storeId: store.id);
      cubit.fetchStoreReviews(storeId: store.id);
    }
  }

  void _openStartReviewSheet() async {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is! ProfileAuthorized) {
      final loggedIn = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true || !mounted) return;
      // Re-read profile status after login
      final newProfileState = context.read<ProfileBloc>().state;
      if (newProfileState is! ProfileAuthorized) return;
    }

    final cubit = context.read<StoreDetailsCubit>();
    final storeId = widget.storeId;
    if (storeId == null || storeId.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _ReviewFormSheet(
          onSubmit: (rating, comment) async {
            await cubit.submitReview(
              storeId: storeId,
              rating: rating,
              comment: comment,
            );
          },
        );
      },
    );
  }

  Widget _buildStars({required double rating, double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (index) {
        if (rating >= index + 1) {
          return Icon(
            Icons.star_rounded,
            color: const Color(0xFFE2B400),
            size: size,
          );
        }
        if (rating > index) {
          return Icon(
            Icons.star_half_rounded,
            color: const Color(0xFFE2B400),
            size: size,
          );
        }
        return Icon(
          Icons.star_border_rounded,
          color: const Color(0xFFE2B400),
          size: size,
        );
      }),
    );
  }

  Widget _buildTabItem({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.only(top: 14, bottom: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.brandBlack : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: selected
                ? AppThemes.f16w600
                : AppThemes.f16w400.copyWith(color: AppColors.brandBlack),
          ),
        ),
      ),
    );
  }

  // ─── Posts Tab ──────────────────────────────────────────

  Widget _buildPostsContent(StoreDetailsState state, bool isOwnStore) {
    if (state.listingsStatus == StoreDetailsLoadStatus.loading &&
        state.listings.isEmpty) {
      return _buildPostsShimmer();
    }

    if (state.listings.isEmpty &&
        state.listingsStatus == StoreDetailsLoadStatus.success) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Center(child: Text('No listings yet', style: AppThemes.f14w400)),
      );
    }

    final itemCount =
        state.listings.length + (state.isListingsPaginating ? 2 : 0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.67,
      ),
      itemBuilder: (context, index) {
        if (index >= state.listings.length) {
          return _buildPostShimmerTile();
        }
        final product = state.listings[index];
        return ProductCard(
          product: product,
          showFavoriteIcon: !isOwnStore,
          showStatus: isOwnStore,
          onTapProduct: () => _openProductDetailSheet(product, isOwnStore),
        );
      },
    );
  }

  Widget _buildPostsShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.67,
      ),
      itemBuilder: (context, index) => _buildPostShimmerTile(),
    );
  }

  Widget _buildPostShimmerTile() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE6E6E6),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  void _openProductDetailSheet(ProductModel product, bool isOwnStore) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          ProductDetailSheet(product: product, hideActions: isOwnStore),
    );
  }

  // ─── Reviews Tab ───────────────────────────────────────

  Widget _buildReviewsContent(
    StoreDetailsState state,
    double avgRating,
    int totalReviews,
    bool isOwnStore,
  ) {
    // Show shimmer while first load
    if (state.reviewsStatus == StoreDetailsLoadStatus.loading &&
        state.reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            Text('Reviews', style: AppThemes.f14w600),
            const SizedBox(height: 14),
            _buildReviewsShimmer(),
          ],
        ),
      );
    }

    // No reviews at all
    if (totalReviews == 0 &&
        state.reviewsStatus == StoreDetailsLoadStatus.success) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOwnStore) ...[
              const SizedBox(height: 14),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0F1F4),
                    foregroundColor: AppColors.brandBlack,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _openStartReviewSheet,
                  child: Center(
                    child: Text('Start a Review', style: AppThemes.f14w500),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 100),
            Center(
              child: Text(
                'There are no reviews for this\nbusiness as of now',
                style: AppThemes.f14w400.copyWith(
                  color: AppColors.brandBlack.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    // Has reviews — show stats + list
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOwnStore) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0F1F4),
                  foregroundColor: AppColors.brandBlack,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _openStartReviewSheet,
                child: Center(
                  child: Text('Start a Review', style: AppThemes.f14w500),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Text('Reviews', style: AppThemes.f14w600),
          const SizedBox(height: 8),
          Text(avgRating.toStringAsFixed(1), style: AppThemes.f40w700),
          const SizedBox(height: 8),
          _buildStars(rating: avgRating, size: 38 / 2),
          const SizedBox(height: 8),
          Text(
            '($totalReviews ${totalReviews == 1 ? 'Review' : 'Reviews'})',
            style: AppThemes.f14w400.copyWith(color: AppColors.brandBlack),
          ),
          const SizedBox(height: 18),
          _buildRatingBreakdown(state.reviewsRatingBreakdown, totalReviews),
          const SizedBox(height: 18),
          _buildReviewsList(state),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown(Map<int, int> breakdown, int total) {
    return Column(
      children: List.generate(5, (index) {
        final star = 5 - index;
        final count = breakdown[star] ?? 0;
        final fraction = total > 0 ? count / total : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  '$star ${star == 1 ? 'star' : 'stars'}',
                  style: AppThemes.f12w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE8E8E8),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFE2B400),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 30,
                child: Text(
                  '$count',
                  textAlign: TextAlign.right,
                  style: AppThemes.f12w500,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReviewsList(StoreDetailsState state) {
    if (state.reviewsStatus == StoreDetailsLoadStatus.loading &&
        state.reviews.isEmpty) {
      return _buildReviewsShimmer();
    }

    if (state.reviews.isEmpty &&
        state.reviewsStatus == StoreDetailsLoadStatus.success) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('No reviews yet', style: AppThemes.f14w400)),
      );
    }

    final itemCount =
        state.reviews.length + (state.isReviewsPaginating ? 1 : 0);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        if (index >= state.reviews.length) {
          return _buildReviewShimmerTile();
        }
        final review = state.reviews[index];
        return _StoreReviewCard(
          review: review,
          starsWidget: _buildStars(rating: review.rating.toDouble(), size: 16),
        );
      },
    );
  }

  Widget _buildReviewsShimmer() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: _buildReviewShimmerTile(),
        ),
      ),
    );
  }

  Widget _buildReviewShimmerTile() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE6E6E6),
      highlightColor: const Color(0xFFF5F5F5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreDetailsCubit, StoreDetailsState>(
      builder: (context, state) {
        if (state.status == StoreDetailsLoadStatus.loading ||
            state.status == StoreDetailsLoadStatus.initial) {
          return const Scaffold(
            backgroundColor: AppColors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }

        if (state.status == StoreDetailsLoadStatus.failure) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(elevation: 0, backgroundColor: AppColors.white),
            body: Center(
              child: Text(
                state.error ?? 'Something went wrong',
                style: AppThemes.f14w400,
              ),
            ),
          );
        }

        final store = state.store;

        final localeCode = Localizations.localeOf(context).languageCode;
        final resolvedStoreName = store != null
            ? (localeCode == 'ar' && store.nameAr.isNotEmpty
                  ? store.nameAr
                  : store.name)
            : _resolveStoreName(localeCode);
        final resolvedStoreLocation = store != null
            ? (localeCode == 'ar'
                  ? '${store.governorateAr.isNotEmpty ? store.governorateAr : store.governorateId}, ${store.wilayatAr.isNotEmpty ? store.wilayatAr : store.wilayat}'
                  : '${store.governorateEn.isNotEmpty ? store.governorateEn : store.governorateId}, ${store.wilayatEn.isNotEmpty ? store.wilayatEn : store.wilayat}')
            : _resolveOrFallback(widget.storeLocation, _fallbackStoreLocation);
        final resolvedStoreDescription = store != null
            ? store.description
            : _resolveOrFallback(
                widget.storeDescription,
                _fallbackStoreDescription,
              );
        final resolvedStoreLogo = store != null && store.logo.isNotEmpty
            ? store.logo
            : (widget.storeLogoUrl ?? '');
        final headerAvgRating = store?.averageRating ?? 0.0;
        final headerTotalReviews = store?.totalReviews ?? 0;
        final avgRating = state.reviewsAvgRating;
        final totalReviews = state.reviewsTotalCount;
        final isLoggedIn =
            context.read<ProfileBloc>().state is ProfileAuthorized;
        final isOwnStore =
            isLoggedIn && (store?.isOwnStore ?? widget.isMyStore);

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BackButtonWidget(
                          ontap: () {
                            Navigator.pop(context);
                          },
                        ),
                        if (isOwnStore && store != null)
                          GestureDetector(
                            onTap: () => _navigateToEditStore(store),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F1F4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: AppColors.brandBlack,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: AppNetworkImage(
                        imageUrl: resolvedStoreLogo,
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                        fallbackWidget: Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/store_unselected_ic.svg',
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                            width: 48,
                            height: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    resolvedStoreName.isNotEmpty
                        ? resolvedStoreName
                        : _fallbackStoreName,
                    style: AppThemes.f20w600,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F3),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 19,
                          color: Color(0xFF8793A9),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            resolvedStoreLocation.isNotEmpty
                                ? resolvedStoreLocation
                                : _fallbackStoreLocation,
                            style: AppThemes.f14w400,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (headerAvgRating > 0.0 || headerTotalReviews > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_outline,
                          color: Color(0xFFE2B400),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${headerAvgRating.toStringAsFixed(1)} ($headerTotalReviews)',
                          style: AppThemes.f12w400,
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      resolvedStoreDescription.isNotEmpty
                          ? resolvedStoreDescription
                          : _fallbackStoreDescription,
                      textAlign: TextAlign.center,
                      style: AppThemes.f14w400,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildTabItem(
                        label: 'Posts',
                        selected: _selectedTab == _StoreDetailsTab.posts,
                        onTap: () => setState(
                          () => _selectedTab = _StoreDetailsTab.posts,
                        ),
                      ),
                      _buildTabItem(
                        label: 'Reviews',
                        selected: _selectedTab == _StoreDetailsTab.reviews,
                        onTap: () => setState(
                          () => _selectedTab = _StoreDetailsTab.reviews,
                        ),
                      ),
                    ],
                  ),
                  Container(height: 1, color: const Color(0xFFE8E8EA)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _selectedTab == _StoreDetailsTab.posts
                        ? _buildPostsContent(state, isOwnStore)
                        : _buildReviewsContent(
                            state,
                            avgRating,
                            totalReviews,
                            isOwnStore,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _resolveStoreName(String localeCode) {
    final arName = widget.storeNameAr?.trim() ?? '';
    final enName = widget.storeName?.trim() ?? '';
    if (localeCode == 'ar' && arName.isNotEmpty) return arName;
    if (enName.isNotEmpty) return enName;
    if (arName.isNotEmpty) return arName;
    return _fallbackStoreName;
  }

  String _resolveOrFallback(String? value, String fallback) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return fallback;
    return normalized;
  }
}

class _StoreReviewCard extends StatelessWidget {
  const _StoreReviewCard({required this.review, required this.starsWidget});

  final StoreReviewModel review;
  final Widget starsWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE8E8E8),
              backgroundImage: review.avatarUrl.isNotEmpty
                  ? NetworkImage(review.avatarUrl)
                  : null,
              child: review.avatarUrl.isEmpty
                  ? Text(
                      review.userName.isNotEmpty
                          ? review.userName[0].toUpperCase()
                          : '?',
                      style: AppThemes.f14w600,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(review.userName, style: AppThemes.f14w500),
                      ),
                      Text(
                        review.timeAgoLabel,
                        style: AppThemes.f12w500.copyWith(
                          color: const Color(0xFF8F9BB3),
                        ),
                      ),
                    ],
                  ),
                  starsWidget,
                  const SizedBox(height: 10),
                  Text(review.comment, style: AppThemes.f12w400),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(height: 1, color: const Color(0xFFEDEDED)),
      ],
    );
  }
}

class _ReviewFormSheet extends StatefulWidget {
  const _ReviewFormSheet({required this.onSubmit});

  final Future<void> Function(int rating, String comment) onSubmit;

  @override
  State<_ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<_ReviewFormSheet> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_selectedRating == 0) return;
    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(_selectedRating, _commentController.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit review: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.of(context).viewInsets.bottom + 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Write a Review', style: AppThemes.f18w600),
            const SizedBox(height: 6),
            Text(
              'How would you rate this business?',
              style: AppThemes.f14w400.copyWith(
                color: AppColors.brandBlack.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRating = starIndex),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      _selectedRating >= starIndex
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFE2B400),
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)',
                hintStyle: AppThemes.f14w400.copyWith(
                  color: AppColors.brandBlack.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: AppThemes.f14w400,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _selectedRating > 0
                      ? AppColors.primaryColor
                      : const Color(0xFFD0D0D0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _selectedRating > 0 && !_isSubmitting
                    ? _handleSubmit
                    : null,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          // strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Submit Review',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
