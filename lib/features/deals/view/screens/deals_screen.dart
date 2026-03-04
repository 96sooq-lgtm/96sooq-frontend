import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96_sooq/features/auth/bloc/auth_bloc.dart';
import 'package:_96_sooq/features/deals/bloc/chat_list/chat_list_bloc.dart';
import 'package:_96_sooq/features/deals/bloc/my_listings/my_listings_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_event.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_state.dart';
import 'package:_96_sooq/features/deals/view/screens/chats/chat_listing_screens.dart';
import 'package:_96_sooq/features/deals/view/screens/favoutire_screen.dart';
import 'package:_96_sooq/features/deals/view/screens/my_deals_screen.dart';
import 'package:_96_sooq/features/deals/view/screens/postSelectionScreen.dart';
import 'package:_96_sooq/features/deals/widgets/quick_action_widget.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/home/widgets/product_detail_sheet.dart';
import 'package:_96_sooq/features/home/widgets/product_listing_widget.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({super.key});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  late final MyListingsBloc _myListingsBloc;
  bool _didFetchInitialListings = false;
  bool? _lastFetchedHasStore;
  String? _lastFetchedStoreId;

  @override
  void initState() {
    super.initState();
    _myListingsBloc = MyListingsBloc();

    final storeBloc = context.read<StoreProfileBloc>();
    final storeState = storeBloc.state;

    if (storeState.status == StoreProfileLoadStatus.initial ||
        storeState.status == StoreProfileLoadStatus.loading) {
      if (storeState.status == StoreProfileLoadStatus.initial) {
        storeBloc.add(const StoreProfileCheckRequested());
      }
      // The listener in build() will trigger MyListingsFetched when done
    } else {
      _fetchListingsIfNeeded(
        hasStore: storeState.hasStore,
        storeId: storeState.store?.id,
      );
    }
  }

  @override
  void dispose() {
    _myListingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _myListingsBloc,
      child: MultiBlocListener(
        listeners: [
          // When auth completes, re-trigger store check → listings fetch
          BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              if (authState is AuthAuthenticated) {
                // Reset so listings are fetched with the new auth token
                _didFetchInitialListings = false;
                _lastFetchedHasStore = null;
                _lastFetchedStoreId = null;
                context.read<StoreProfileBloc>().add(
                  const StoreProfileCheckRequested(),
                );
              }
            },
          ),
          // When store check completes, fetch listings
          BlocListener<StoreProfileBloc, StoreProfileState>(
            listener: (context, state) {
              if (state.status == StoreProfileLoadStatus.success ||
                  state.status == StoreProfileLoadStatus.failure) {
                _fetchListingsIfNeeded(
                  hasStore: state.hasStore,
                  storeId: state.store?.id,
                );
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── My Deals section ──
                  BlocBuilder<MyListingsBloc, MyListingsState>(
                    builder: (context, state) {
                      if (state.status == MyListingsStatus.loading) {
                        return _buildMyDealsSection(
                          context: context,
                          localizations: localizations,
                          isArabic: isArabic,
                          child: SizedBox(
                            height: 245,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              separatorBuilder: (_, index) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (_, index) => Container(
                                width: 173,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      if (state.status == MyListingsStatus.failure ||
                          state.products.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return ProductListingWidget(
                        category: localizations.myDealsTitle,
                        showFavoriteIcon: false,

                        showStatus: true,
                        onProductTap: (product) {
                          showProductDetailSheet(
                            context: context,
                            product: product,
                          );
                        },
                        products: state.products,
                        onSeeAllTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => MyListingsBloc(),
                                child: const MyDealsScreen(),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 25),
                  Text(
                    localizations.quickActionTitle,
                    style: isArabic
                        ? AppThemes.f16w600.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          )
                        : AppThemes.f16w600,
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionWidget(
                          iconBg: const Color(
                            0xFFE79718,
                          ).withValues(alpha: 0.2),
                          icon: AppAssets.businessPlaceholderIc,
                          name: localizations.myAdsTitle,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PostSelectionScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: QuickActionWidget(
                          iconBg: const Color(
                            0xFFE31D1C,
                          ).withValues(alpha: 0.2),
                          icon: AppAssets.favoriteIc,
                          name: localizations.favoritesTitle,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FavoutireScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  QuickActionWidget(
                    iconBg: const Color(0xFF25D366).withValues(alpha: 0.2),
                    icon: AppAssets.recentChats,
                    name: localizations.recentChatTitle,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) =>
                                ChatListBloc()..add(const ChatListFetched()),
                            child: const Scaffold(
                              backgroundColor: AppColors.white,
                              body: SafeArea(child: ChatListingScreen()),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyDealsSection({
    required BuildContext context,
    required AppLocalizations localizations,
    required bool isArabic,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations.myDealsTitle,
              style: isArabic
                  ? AppThemes.f16w600.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    )
                  : AppThemes.f16w600,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => MyListingsBloc(),
                        child: const MyDealsScreen(),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
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
                      const Icon(
                        Icons.arrow_right,
                        color: AppColors.subTextBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
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
      builder: (_) => ProductDetailSheet(product: product, hideActions: true),
    );
  }

  void _fetchListingsIfNeeded({required bool hasStore, String? storeId}) {
    final hasChanged =
        _lastFetchedHasStore != hasStore || _lastFetchedStoreId != storeId;
    if (_didFetchInitialListings && !hasChanged) {
      return;
    }

    _didFetchInitialListings = true;
    _lastFetchedHasStore = hasStore;
    _lastFetchedStoreId = storeId;
    _myListingsBloc.add(
      MyListingsFetched(
        hasStore: hasStore,
        storeId: storeId,
        fetchAllStatuses: true,
      ),
    );
  }
}
