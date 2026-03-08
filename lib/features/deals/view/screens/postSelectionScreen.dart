import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/addlist/bloc/payment/addlist_payment_flow_bloc.dart';
import 'package:_96_sooq/features/addlist/model/listing_account_type.dart';
import 'package:_96_sooq/features/addlist/view/screens/boost_your_product_screen.dart';
import 'package:_96_sooq/features/addlist/view/screens/subscription_listing_screen.dart';
import 'package:_96_sooq/features/deals/bloc/my_listings/my_listings_bloc.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/home/widgets/product_detail_sheet.dart';
import 'package:_96_sooq/features/home/widgets/product_status_chip.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_event.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_state.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostSelectionScreen extends StatefulWidget {
  const PostSelectionScreen({super.key});

  @override
  State<PostSelectionScreen> createState() => _PostSelectionScreenState();
}

class _PostSelectionScreenState extends State<PostSelectionScreen> {
  late final MyListingsBloc _myListingsBloc;
  final ScrollController _scrollController = ScrollController();
  bool _didFetch = false;

  @override
  void initState() {
    super.initState();
    _myListingsBloc = MyListingsBloc();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _myListingsBloc.add(const MyListingsLoadMore());
      }
    });

    // Check store state and fetch listings accordingly
    final storeBloc = context.read<StoreProfileBloc>();
    final storeState = storeBloc.state;

    if (storeState.status == StoreProfileLoadStatus.initial ||
        storeState.status == StoreProfileLoadStatus.loading) {
      if (storeState.status == StoreProfileLoadStatus.initial) {
        storeBloc.add(const StoreProfileCheckRequested());
      }
      // Listener in build() will trigger fetch when store check completes
    } else {
      _fetchListings(
        hasStore: storeState.hasStore,
        storeId: storeState.store?.id,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _myListingsBloc.close();
    super.dispose();
  }

  void _fetchListings({required bool hasStore, String? storeId}) {
    if (_didFetch) return;
    _didFetch = true;
    _myListingsBloc.add(
      MyListingsFetched(
        hasStore: hasStore,
        storeId: storeId,
        skip: 0,
        limit: 20,
      ),
    );
  }

  void _onPromoteTap(BuildContext context, ProductModel product) {
    final hasStore = context.read<StoreProfileBloc>().state.hasStore;
    final storeStatus =
        context.read<StoreProfileBloc>().state.store?.status ?? '';
    final accountType = hasStore
        ? ListingAccountType.business
        : ListingAccountType.individual;
    final useExistingQuota = hasStore && storeStatus == 'active';
    final status = product.status?.toLowerCase() ?? '';

    final imageUrl = product.imageUrl.isNotEmpty
        ? product.imageUrl
        : (product.images.isNotEmpty ? product.images.first : '');

    if (hasStore) {
      // Store/business user: keep existing logic unchanged
      if (!useExistingQuota) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => AddlistPaymentFlowBloc(),
              child: SubscriptionListingScreen(
                disclaimerSubtext:
                    'Business account gets 1 listing free per month.',
                accountType: accountType,
                promoteProduct: product,
              ),
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              lazy: false,
              create: (_) => AddlistPaymentFlowBloc()
                ..add(
                  FlowInitialized(
                    accountType: accountType,
                    requiresPayment: false,
                    planTitle: 'Post Promotion',
                    planAmount: 0.0,
                    currency: 'OMR',
                    useExistingQuota: useExistingQuota,
                  ),
                ),
              child: BoostYourProductScreen(
                source: BoostFlowSource.myDeals,
                postId: product.id,
                postTitle: product.title,
                postAmount: product.amount,
                postImageUrl: imageUrl,
                postDetails: product.details,
                accountType: accountType,
              ),
            ),
          ),
        );
      }
      return;
    }

    // Individual user — NEVER show subscription for active listings
    if (status == 'draft') {
      // Draft only: go through subscription screen to pay listing amount
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => AddlistPaymentFlowBloc(),
            child: SubscriptionListingScreen(
              disclaimerSubtext:
                  'Individual account gets 1 listing free per month.',
              accountType: accountType,
              promoteProduct: product,
            ),
          ),
        ),
      );
    } else {
      // Active or any other status: go DIRECTLY to boost screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            lazy: false,
            create: (_) => AddlistPaymentFlowBloc()
              ..add(
                FlowInitialized(
                  accountType: accountType,
                  requiresPayment: false,
                  planTitle: 'Post Promotion',
                  planId: null,
                  planAmount: 0.0,
                  currency: 'OMR',
                  useExistingQuota: false,
                ),
              ),
            child: BoostYourProductScreen(
              source: BoostFlowSource.myDeals,
              postId: product.id,
              postTitle: product.title,
              postAmount: product.amount,
              postImageUrl: imageUrl,
              postDetails: product.details,
              accountType: accountType,
            ),
          ),
        ),
      );
    }
  }

  void _openProductDetailSheet(ProductModel product) {
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _myListingsBloc,
      child: BlocListener<StoreProfileBloc, StoreProfileState>(
        listener: (context, state) {
          if (state.status == StoreProfileLoadStatus.success ||
              state.status == StoreProfileLoadStatus.failure) {
            _fetchListings(hasStore: state.hasStore, storeId: state.store?.id);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BackButtonWidget(ontap: () => Navigator.pop(context)),
                      Expanded(
                        child: Text(
                          localizations.myAdsTitle,
                          textAlign: TextAlign.center,
                          style: AppThemes.f16w600,
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: BlocBuilder<MyListingsBloc, MyListingsState>(
                      builder: (context, state) {
                        if (state.status == MyListingsStatus.loading ||
                            state.status == MyListingsStatus.initial) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state.status == MyListingsStatus.failure) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.error ?? 'Error loading ads',
                                  style: AppThemes.f14w500,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () {
                                    _didFetch = false;
                                    final s = context
                                        .read<StoreProfileBloc>()
                                        .state;
                                    _fetchListings(
                                      hasStore: s.hasStore,
                                      storeId: s.store?.id,
                                    );
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state.products.isEmpty) {
                          return Center(
                            child: Text(
                              'No ads found.',
                              style: AppThemes.f14w500,
                            ),
                          );
                        }

                        return ListView.separated(
                          controller: _scrollController,
                          itemCount:
                              state.products.length +
                              (state.hasReachedMax ? 0 : 1),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            if (index >= state.products.length) {
                              // Loading-more indicator
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final product = state.products[index];
                            final status = product.status?.toLowerCase() ?? '';
                            final isPending =
                                status == 'pending_approval' ||
                                status == 'pending';
                            final isRejected = status == 'rejected';
                            // Hide promote for rejected/pending for all users
                            final showPromote = !isPending && !isRejected;
                            return _PostSelectionCard(
                              product: product,
                              promoteLabel: localizations.promoteText,
                              showPromote: showPromote,
                              onTap: () => _openProductDetailSheet(product),
                              onPromoteTap: () =>
                                  _onPromoteTap(context, product),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PostSelectionCard extends StatelessWidget {
  const _PostSelectionCard({
    required this.product,
    required this.promoteLabel,
    required this.onTap,
    required this.onPromoteTap,
    this.showPromote = true,
  });

  final ProductModel product;
  final String promoteLabel;
  final bool showPromote;
  final VoidCallback onTap;
  final VoidCallback onPromoteTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl.isNotEmpty
        ? product.imageUrl
        : (product.images.isNotEmpty ? product.images.first : '');

    final status = product.status;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AppNetworkImage(
                      imageUrl: imageUrl,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.amount,
                                style: AppThemes.f16w600,
                              ),
                            ),
                            if (status != null && status.isNotEmpty)
                              ProductStatusChip(
                                status: status,
                                isFeatured: product.isPromoted == true,
                                fontSize: 9,
                                topEndRadius: 10,
                                bottomStartRadius: 10,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.title,
                          style: AppThemes.f14w600,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          product.details,
                          style: AppThemes.f14w500.copyWith(
                            color: AppColors.productListingTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showPromote) ...[
                const SizedBox(height: 10),
                _PromoteButton(label: promoteLabel, onTap: onPromoteTap),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoteButton extends StatelessWidget {
  const _PromoteButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.trending_up, color: Color(0xFF00B69B), size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppThemes.f16w600.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
