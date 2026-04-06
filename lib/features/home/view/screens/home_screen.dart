import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/core/bloc/location/bloc/location_bloc.dart';
import 'package:_96_sooq/features/categories/bloc/store_bloc/store_bloc.dart';
import 'package:_96_sooq/features/deals/view/screens/favoutire_screen.dart';
import 'package:_96_sooq/features/home/data/featured_banner_api_service.dart';
import 'package:_96_sooq/features/categories/widgets/category_feed_widget.dart';
import 'package:_96_sooq/shared/global_widgets/section_header.dart';
import 'package:_96_sooq/features/home/model/featured_banner_model.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';

import 'package:_96_sooq/features/home/widgets/categories_widget.dart';
import 'package:_96_sooq/features/home/widgets/moving_dots_widget.dart';
import 'package:_96_sooq/features/home/widgets/offers_widget.dart';
import 'package:_96_sooq/features/home/widgets/product_detail_sheet.dart';
import 'package:_96_sooq/features/home/widgets/searchbar_black_widget.dart';
import 'package:_96_sooq/features/search/view/screens/search_screen.dart';
import 'package:_96_sooq/features/home/widgets/store_listing_widget.dart';
import 'package:_96_sooq/features/offers/bloc/offers_bloc.dart';
import 'package:_96_sooq/features/offers/bloc/offers_event.dart';
import 'package:_96_sooq/features/offers/bloc/offers_state.dart';
import 'package:_96_sooq/features/location/view/screens/governarate_list_screen.dart';
import 'package:_96_sooq/features/auth/domain/auth_session_repository.dart';
import 'package:_96_sooq/features/auth/screens/login_screen.dart';
import 'package:_96_sooq/features/profile/view/screens/store_details_screen.dart';
import 'package:_96_sooq/features/profile/view/screens/help_and_support_screen.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_event.dart';
import 'package:_96_sooq/features/root/bloc/root_bloc.dart';
import 'package:_96_sooq/features/root/bloc/root_event.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_96_sooq/features/categories/bloc/categories_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/notifications/view/screens/notifications_screen.dart';
import 'package:_96_sooq/features/notifications/bloc/notifications_bloc.dart';
import 'package:_96_sooq/features/notifications/bloc/notifications_event.dart';
import 'package:_96_sooq/features/notifications/bloc/notifications_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  TextEditingController searchController = .new();
  CarouselSliderController carouselController = .new();
  final FeaturedBannerApiService _featuredBannerApiService =
      const FeaturedBannerApiService();
  final AuthSessionRepository _authSessionRepository = AuthSessionRepository();
  int _currentIndex = 0;
  bool _requestedLocationOnStart = false;
  bool _isLocationDialogVisible = false;
  bool _retryLocationAfterSettings = false;
  bool _isBannerLoading = true;
  String? _bannerError;
  List<FeaturedBannerModel> _featuredBanners = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadFeaturedBanners();
    context.read<StoreBloc>().add(
      HomeStoresRequested(
        locationId: _resolvedLocationId(context.read<LocationBloc>().state),
      ),
    );
    _requestStoreProfileIfLoggedIn();
    _fetchNotificationUnreadCount();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _requestedLocationOnStart) return;
      _requestedLocationOnStart = true;
      context.read<LocationBloc>().add(LocationUseCurrentRequested());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.resumed && _retryLocationAfterSettings) {
      _retryLocationAfterSettings = false;
      context.read<LocationBloc>().add(LocationUseCurrentRequested());
    }
  }

  Future<void> _showLocationServicesDialog() async {
    if (_isLocationDialogVisible || !mounted) return;
    _isLocationDialogVisible = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(AppLocalizations.of(context)!.locationServicesOff),
          content: Text(
            AppLocalizations.of(context)!.locationServicesOffMessage,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppLocalizations.of(context)!.notNow),
            ),
            TextButton(
              onPressed: () async {
                _retryLocationAfterSettings = true;
                await Geolocator.openLocationSettings();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(AppLocalizations.of(context)!.openSettings),
            ),
          ],
        );
      },
    );
    _isLocationDialogVisible = false;
  }

  Future<void> _loadFeaturedBanners() async {
    setState(() {
      _isBannerLoading = true;
      _bannerError = null;
    });

    try {
      final banners = await _featuredBannerApiService.fetchFeaturedBanners();
      if (!mounted) return;
      setState(() {
        _featuredBanners = banners;
        _isBannerLoading = false;
        _currentIndex = _clampedIndex(
          currentIndex: _currentIndex,
          itemCount: _currentCarouselItemCount,
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _featuredBanners = [];
        _isBannerLoading = false;
        _bannerError = error.toString();
        _currentIndex = 0;
      });
      if (kDebugMode) {
        debugPrint('[HOME-BANNERS] load_failed error=$_bannerError');
      }
    }
  }

  Future<void> _onBannerTap() async {
    if (!_usesFeaturedBanners || _featuredBanners.isEmpty) return;
    if (_currentIndex < 0 || _currentIndex >= _featuredBanners.length) return;

    final banner = _featuredBanners[_currentIndex];
    if (!banner.hasValidLink) return;
    await _launchBannerUrl(banner.linkUrl);
  }

  Future<void> _launchBannerUrl(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || (!uri.hasScheme && uri.host.isEmpty)) {
      _showBannerLaunchFailedSnackBar();
      return;
    }

    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!didLaunch && mounted) {
      _showBannerLaunchFailedSnackBar();
    }
  }

  void _showBannerLaunchFailedSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.unableToOpenLink)));
  }

  bool get _usesFeaturedBanners => _featuredBanners.isNotEmpty;

  int get _currentCarouselItemCount => _featuredBanners.length;

  int _clampedIndex({required int currentIndex, required int itemCount}) {
    if (itemCount <= 0) return 0;
    if (currentIndex < 0) return 0;
    if (currentIndex > itemCount - 1) return itemCount - 1;
    return currentIndex;
  }

  String? _resolvedLocationId(LocationState state) {
    if (state.isCountryFallback) return null;
    return state.selectedState?.id;
  }

  Future<void> _requestStoreProfileIfLoggedIn() async {
    final isLoggedIn = await _authSessionRepository.isLoggedIn();
    if (!mounted || !isLoggedIn) return;
    context.read<StoreProfileBloc>().add(const StoreProfileCheckRequested());
  }

  Future<void> _fetchNotificationUnreadCount() async {
    final isLoggedIn = await _authSessionRepository.isLoggedIn();
    if (!mounted || !isLoggedIn) return;
    context
        .read<NotificationsBloc>()
        .add(const NotificationsUnreadCountRequested());
  }

  Future<void> _onRefresh() async {
    // Re-fetch location
    context.read<LocationBloc>().add(LocationUseCurrentRequested());
    // Re-fetch banners
    _loadFeaturedBanners();
    // Re-fetch categories
    context.read<CategoriesBloc>().add(CategoriesRequested());
    // Re-fetch offers
    context.read<OffersBloc>().add(
      FetchOffers(
        isRefresh: true,
        governorate: context.read<LocationBloc>().state.selectedState?.nameEn,
      ),
    );
    // Re-fetch stores
    context.read<StoreBloc>().add(
      HomeStoresRequested(
        locationId: _resolvedLocationId(context.read<LocationBloc>().state),
      ),
    );
    // Re-check store profile
    _requestStoreProfileIfLoggedIn();
    // Re-fetch notification unread count
    _fetchNotificationUnreadCount();
    // Small delay so the indicator shows
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final effectiveItemCount = _currentCarouselItemCount;
    final isSingleCarouselItem = effectiveItemCount <= 1;
    final effectiveIndex = _clampedIndex(
      currentIndex: _currentIndex,
      itemCount: effectiveItemCount,
    );

    return MultiBlocListener(
      listeners: [
        BlocListener<LocationBloc, LocationState>(
          listenWhen: (previous, current) =>
              previous.currentLocationStatus != current.currentLocationStatus ||
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.currentLocationStatus == LocationLoadStatus.failure &&
                (state.errorMessage?.isNotEmpty ?? false)) {
              if (state.failureType == LocationFailureType.servicesDisabled) {
                _showLocationServicesDialog();
                return;
              }
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
        ),
        BlocListener<LocationBloc, LocationState>(
          listenWhen: (previous, current) =>
              previous.selectedState?.id != current.selectedState?.id ||
              previous.isCountryFallback != current.isCountryFallback,
          listener: (context, state) {
            context.read<StoreBloc>().add(
              HomeStoresRequested(locationId: _resolvedLocationId(state)),
            );
            context.read<OffersBloc>().add(
              FetchOffers(
                isRefresh: true,
                governorate: state.selectedState?.nameEn,
              ),
            );
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF141414),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.white,
          backgroundColor: const Color(0xFF141414),
          child: CustomScrollView(
            slivers: [
              /// 🔹 HEADER
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Image.asset(AppAssets.logo, width: 36, height: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: isRtl
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: isRtl
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  "96 SOOQ",
                                  textAlign: TextAlign.start,
                                  style: AppThemes.f14w500.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const GovernarateListScreen(),
                                  ),
                                );
                              },
                              child: BlocBuilder<LocationBloc, LocationState>(
                                buildWhen: (previous, current) =>
                                    previous.selectedState !=
                                        current.selectedState ||
                                    previous.selectedCity !=
                                        current.selectedCity ||
                                    previous.selectedCountryLabel !=
                                        current.selectedCountryLabel ||
                                    previous.isCountryFallback !=
                                        current.isCountryFallback,
                                builder: (context, locationState) {
                                  final localeCode = Localizations.localeOf(
                                    context,
                                  ).languageCode;
                                  final hasExactSelection =
                                      locationState.selectedState != null &&
                                      locationState.selectedCity != null;
                                  final locationText = hasExactSelection
                                      ? '${locationState.selectedCity!.displayName(localeCode)}, ${locationState.selectedState!.displayName(localeCode)}'
                                      : (locationState.isCountryFallback &&
                                                (locationState
                                                        .selectedCountryLabel
                                                        ?.isNotEmpty ??
                                                    false)
                                            ? locationState
                                                .selectedCountryLabel!
                                            : localizations
                                                .selectLocationLabel);
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isRtl)
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          color: AppColors.white,
                                          size: 16,
                                        ),
                                      Flexible(
                                        child: Text(
                                          locationText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppThemes.f12w400.copyWith(
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                      if (!isRtl)
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          color: AppColors.white,
                                          size: 16,
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MaterialIconCircle(
                            Icons.help_outline_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HelpAndSupportScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 5),
                          _IconCircle(
                            AppAssets.favoritesIc,
                            onTap: () async {
                              final isLoggedIn = await _authSessionRepository
                                  .isLoggedIn();
                              if (!context.mounted) return;
                              if (!isLoggedIn) {
                                // Not logged in, redirect to login screen
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                                if (!context.mounted) return;

                                // If login was successful, open favorites directly
                                if (result == true) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const FavoutireScreen(),
                                    ),
                                  );
                                }
                                return;
                              }

                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const FavoutireScreen(),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 5),
                          BlocBuilder<NotificationsBloc, NotificationsState>(
                            buildWhen: (prev, curr) =>
                                prev.unreadCount != curr.unreadCount,
                            builder: (context, notifState) {
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _IconCircle(
                                    AppAssets.notificationIc,
                                    onTap: () async {
                                      final isLoggedIn =
                                          await _authSessionRepository
                                              .isLoggedIn();
                                      if (!context.mounted) return;
                                      if (!isLoggedIn) {
                                        final result =
                                            await Navigator.push<bool>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const LoginScreen(),
                                          ),
                                        );
                                        if (!context.mounted) return;
                                        if (result == true) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const NotificationsScreen(),
                                            ),
                                          );
                                        }
                                        return;
                                      }
                                      if (context.mounted) {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const NotificationsScreen(),
                                          ),
                                        );
                                        // Refresh unread count when returning
                                        if (context.mounted) {
                                          context
                                              .read<NotificationsBloc>()
                                              .add(
                                                const NotificationsUnreadCountRequested(),
                                              );
                                        }
                                      }
                                    },
                                  ),
                                  if (notifState.unreadCount > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE31D1C),
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
                                        ),
                                        child: Text(
                                          notifState.unreadCount > 99
                                              ? '99+'
                                              : '${notifState.unreadCount}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 21),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                    child: AbsorbPointer(
                      child: SearchbarBlackWidget(
                        labelText: "${localizations.search}...",
                        controller: searchController,
                        enabled: false,
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(37),
                      topRight: Radius.circular(37),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<CategoriesBloc, CategoriesState>(
                        builder: (context, state) {
                          final isArabic =
                              context
                                  .watch<LanguageBloc>()
                                  .state
                                  .locale
                                  .languageCode ==
                              'ar';

                          final header = SectionHeader(
                            title: localizations.categoriesTitle,
                            action: localizations.seeAllText,
                            isArabic: isArabic,
                            onActionTap: () {
                              context.read<RootBloc>().add(ChangeTabEvent(1));
                            },
                          );

                          if (state.categoriesStatus ==
                                  CategoriesStatus.loading ||
                              state.categoriesStatus ==
                                  CategoriesStatus.initial) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                header,
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    itemCount: 6,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 18,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: .center,
                                          children: [
                                            Shimmer.fromColors(
                                              baseColor: const Color(
                                                0xFFE6E6E6,
                                              ),
                                              highlightColor: const Color(
                                                0xFFF5F5F5,
                                              ),
                                              child: Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Shimmer.fromColors(
                                              baseColor: const Color(
                                                0xFFE6E6E6,
                                              ),
                                              highlightColor: const Color(
                                                0xFFF5F5F5,
                                              ),
                                              child: Container(
                                                width: 50,
                                                height: 10,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }

                          if (state.categoriesStatus ==
                              CategoriesStatus.error) {
                            return const SizedBox.shrink();
                          }

                          if (state.categories.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          final localeCode = Localizations.localeOf(
                            context,
                          ).languageCode;
                          final allCategories = state.categories;
                          final categoryNames = allCategories
                              .map((c) => c.displayName(localeCode))
                              .toList();
                          final categoryImages = allCategories
                              .map((c) => c.imageUrl)
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              header,
                              const SizedBox(height: 8),
                              CategoriesWidget(
                                categoryNames: categoryNames,
                                categoryImages: categoryImages,
                                onCategoryTap: (index) {
                                  final selectedCategory = allCategories[index];
                                  context.read<CategoriesBloc>().add(
                                    SubCategoriesRequested(selectedCategory.id),
                                  );
                                  context.read<RootBloc>().add(
                                    ChangeTabEvent(1),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),

                      /// Carousel
                      if (_isBannerLoading)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: SizedBox(
                            height: 170,
                            width: double.infinity,
                            child: Shimmer.fromColors(
                              baseColor: const Color(0xFFE6E6E6),
                              highlightColor: const Color(0xFFF5F5F5),
                              child: Container(color: Colors.white),
                            ),
                          ),
                        )
                      else if (_usesFeaturedBanners) ...[
                        GestureDetector(
                          onTap: _onBannerTap,
                          behavior: HitTestBehavior.opaque,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: CarouselSlider.builder(
                              carouselController: carouselController,
                              itemCount: _featuredBanners.length,
                              itemBuilder: (context, index, realIndex) {
                                final banner = _featuredBanners[index];
                                return SizedBox.expand(
                                  child: AppNetworkImage(
                                    imageUrl: banner.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                              options: CarouselOptions(
                                viewportFraction: 1,
                                autoPlay: !isSingleCarouselItem,
                                enableInfiniteScroll: !isSingleCarouselItem,
                                scrollPhysics: isSingleCarouselItem
                                    ? const NeverScrollableScrollPhysics()
                                    : null,
                                onPageChanged: (index, _) {
                                  setState(() => _currentIndex = index);
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        MovingDotsIndicator(
                          itemCount: effectiveItemCount,
                          currentIndex: effectiveIndex,
                        ),
                      ],
                      const SizedBox(height: 5),
                      BlocBuilder<OffersBloc, OffersState>(
                        builder: (context, state) {
                          if (state.offers.isEmpty &&
                              state.status != OffersStatus.loading) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.offersTitle,
                                style:
                                    (context
                                            .watch<LanguageBloc>()
                                            .state
                                            .locale
                                            .languageCode ==
                                        'ar')
                                    ? AppThemes.f16w600.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      )
                                    : AppThemes.f16w600,
                              ),
                              const OffersWidget(),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                      //Stores
                      BlocBuilder<StoreBloc, StoreState>(
                        buildWhen: (previous, current) =>
                            previous.homeStatus != current.homeStatus ||
                            previous.homeStores != current.homeStores ||
                            previous.isHomePaginating !=
                                current.isHomePaginating,
                        builder: (context, storeState) {
                          final visibleStores = storeState.homeStores;
                          final isLoading =
                              storeState.homeStatus == StoreLoadStatus.loading;

                          if (!isLoading && visibleStores.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            children: [
                              StoreListingWidget(
                                stores: visibleStores,
                                isLoading: isLoading,
                                isPaginating: storeState.isHomePaginating,
                                onLoadMore: () {
                                  context.read<StoreBloc>().add(
                                    const HomeStoresLoadMoreRequested(),
                                  );
                                },
                                onStoreTap: (store) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StoreDetailsScreen(
                                        isMyStore: false,
                                        storeId: store.id,
                                        storeName: store.name,
                                        storeNameAr: store.nameAr,
                                        storeDescription: store.description,
                                        storeLogoUrl: store.logo,
                                        storeLocation: store.wilayat,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),

                      /// Products - Category Feeds
                      BlocBuilder<LocationBloc, LocationState>(
                        builder: (context, locationState) {
                          String? governorateName =
                              locationState.selectedState?.nameEn;

                          return BlocBuilder<CategoriesBloc, CategoriesState>(
                            builder: (context, catState) {
                              final electronicsCat = catState.categories
                                  .where(
                                    (c) =>
                                        c.nameEn.toLowerCase().contains(
                                          'electronic',
                                        ) ||
                                        c.nameEn.toLowerCase().contains(
                                          'mobile',
                                        ),
                                  )
                                  .firstOrNull;

                              final vehiclesCat = catState.categories
                                  .where(
                                    (c) =>
                                        c.nameEn.toLowerCase().contains(
                                          'vehicle',
                                        ) ||
                                        c.nameEn.toLowerCase().contains(
                                          'auto',
                                        ) ||
                                        c.nameEn.toLowerCase().contains('car'),
                                  )
                                  .firstOrNull;

                              final localeCode = Localizations.localeOf(
                                context,
                              ).languageCode;
                              final electronicsTitle =
                                  electronicsCat?.displayName(localeCode) ??
                                  (localeCode == 'ar'
                                      ? 'الإلكترونيات'
                                      : 'Electronics');
                              final vehiclesTitle =
                                  vehiclesCat?.displayName(localeCode) ??
                                  (localeCode == 'ar'
                                      ? 'المركبات'
                                      : 'Vehicles');

                              return Column(
                                children: [
                                  CategoryFeedWidget(
                                    categoryId:
                                        electronicsCat?.id ??
                                        "047c4745-f354-4941-b4cf-995168d79b0e",
                                    title: electronicsTitle,
                                    governorate: governorateName,
                                  ),
                                  const SizedBox(height: 22),
                                  if (vehiclesCat != null) ...[
                                    CategoryFeedWidget(
                                      categoryId: vehiclesCat.id,
                                      title: vehiclesTitle,
                                      governorate: governorateName,
                                    ),
                                    const SizedBox(height: 22),
                                  ],
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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

class _IconCircle extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;

  const _IconCircle(this.icon, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white.withValues(alpha: 0.1),
        ),
        child: Center(child: Image.asset(icon)),
      ),
    );
  }
}

class _MaterialIconCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _MaterialIconCircle(this.icon, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white.withValues(alpha: 0.1),
        ),
        child: Center(child: Icon(icon, color: AppColors.white.withOpacity(0.8), size: 22)),
      ),
    );
  }
}
