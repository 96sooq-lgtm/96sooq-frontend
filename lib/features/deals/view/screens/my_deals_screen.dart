import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/addlist/bloc/payment/addlist_payment_flow_bloc.dart';
import 'package:_96_sooq/features/addlist/model/listing_account_type.dart';
import 'package:_96_sooq/features/addlist/view/screens/boost_your_product_screen.dart';
import 'package:_96_sooq/features/addlist/view/screens/edit_listing_screen.dart';
import 'package:_96_sooq/features/addlist/view/screens/subscription_listing_screen.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/home/widgets/product_detail_sheet.dart';
import 'package:_96_sooq/features/deals/bloc/my_listings/my_listings_bloc.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_bloc.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum _DealsTab { active, sold }

class MyDealsScreen extends StatefulWidget {
  const MyDealsScreen({super.key});

  @override
  State<MyDealsScreen> createState() => _MyDealsScreenState();
}

class _MyDealsScreenState extends State<MyDealsScreen> {
  _DealsTab _selectedTab = _DealsTab.active;

  @override
  void initState() {
    super.initState();
    _fetchListings(_DealsTab.active);
  }

  void _fetchListings(_DealsTab tab) {
    final storeState = context.read<StoreProfileBloc>().state;
    final statusMap = {_DealsTab.active: 'active', _DealsTab.sold: 'sold'};

    context.read<MyListingsBloc>().add(
      MyListingsFetched(
        hasStore: storeState.hasStore,
        storeId: storeState.store?.id,
        status: statusMap[tab] ?? 'active',
        skip: 0,
        limit: 20,
      ),
    );
  }

  void _onTabChanged(_DealsTab tab) {
    if (_selectedTab == tab) return;
    setState(() => _selectedTab = tab);
    _fetchListings(tab);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
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
                      localizations.myDealsTitle,
                      textAlign: TextAlign.center,
                      style: AppThemes.f16w600,
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
              ),
              const SizedBox(height: 16),
              _SegmentedDealsSwitch(
                activeLabel: localizations.activeStatus,
                soldLabel: localizations.soldStatus,
                selectedTab: _selectedTab,
                onTabChanged: _onTabChanged,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: BlocConsumer<MyListingsBloc, MyListingsState>(
                  listener: (context, state) {
                    if (state.actionError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.actionError!)),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state.status == MyListingsStatus.loading ||
                        state.status == MyListingsStatus.initial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == MyListingsStatus.failure) {
                      return Center(
                        child: Text(
                          state.error ?? 'Error loading deals',
                          style: AppThemes.f14w500,
                        ),
                      );
                    }

                    if (state.products.isEmpty) {
                      return Center(
                        child: Text(
                          'No ${_selectedTab.name} deals found.',
                          style: AppThemes.f14w500,
                        ),
                      );
                    }

                    final storeState = context.read<StoreProfileBloc>().state;
                    final isStoreUser = storeState.hasStore;

                    return ListView.separated(
                      itemCount: state.products.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        final status = product.status?.toLowerCase() ?? '';

                        // For individual users: hide promote for rejected/pending
                        final showPromote =
                            isStoreUser ||
                            (status != 'rejected' && status != 'pending');

                        return _MyDealCard(
                          product: product,
                          editLabel: localizations.editText,
                          promoteLabel: localizations.promoteText,
                          showActions: _selectedTab == _DealsTab.active,
                          showPromote: showPromote,
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                surfaceTintColor: Colors.transparent,
                                backgroundColor: Colors.white,
                                title: const Text(
                                  'Delete Listing',
                                  style: AppThemes.f16w600,
                                ),
                                content: const Text(
                                  'Are you sure you want to delete this listing?',
                                  style: AppThemes.f14w500,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              context.read<MyListingsBloc>().add(
                                MyListingsDeleteRequested(product.id),
                              );
                            }
                          },
                          onEdit: () {
                            Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditListingScreen(product: product),
                              ),
                            ).then((updated) {
                              if (!mounted) return;
                              if (updated == true) {
                                setState(() {
                                  _selectedTab = _DealsTab.active;
                                });
                              }
                              _fetchListings(_selectedTab);
                            });
                          },
                          onPromote: () => _onPromoteTap(context, product),
                          onTap: () =>
                              _openProductDetailSheet(context, product),
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
    );
  }

  void _onPromoteTap(BuildContext context, ProductModel product) {
    final storeState = context.read<StoreProfileBloc>().state;
    final isStoreUser = storeState.hasStore;
    final storeStatus = storeState.store?.status ?? '';
    final status = product.status?.toLowerCase() ?? '';

    final imageUrl = product.imageUrl.isNotEmpty
        ? product.imageUrl
        : (product.images.isNotEmpty ? product.images.first : '');

    if (isStoreUser) {
      // Store user: same flow as postSelectionScreen
      final accountType = ListingAccountType.business;
      final useExistingQuota = storeStatus == 'active';

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
    const accountType = ListingAccountType.individual;

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

  void _openProductDetailSheet(BuildContext context, ProductModel product) {
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
}

class _SegmentedDealsSwitch extends StatelessWidget {
  const _SegmentedDealsSwitch({
    required this.activeLabel,
    required this.soldLabel,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final String activeLabel;
  final String soldLabel;
  final _DealsTab selectedTab;
  final ValueChanged<_DealsTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFF141414).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentItem(
              label: activeLabel,
              selected: selectedTab == _DealsTab.active,
              onTap: () => onTabChanged(_DealsTab.active),
            ),
          ),
          Expanded(
            child: _SegmentItem(
              label: soldLabel,
              selected: selectedTab == _DealsTab.sold,
              onTap: () => onTabChanged(_DealsTab.sold),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(200),
        ),
        child: Center(
          child: Text(
            label,
            style: selected
                ? AppThemes.f14w600
                : AppThemes.f14w500.copyWith(color: Color(0xFF475569)),
          ),
        ),
      ),
    );
  }
}

class _MyDealCard extends StatelessWidget {
  const _MyDealCard({
    required this.product,
    required this.editLabel,
    required this.promoteLabel,
    required this.showActions,
    required this.showPromote,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onPromote,
  });

  final ProductModel product;
  final String editLabel;
  final String promoteLabel;
  final bool showActions;
  final bool showPromote;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPromote;

  @override
  Widget build(BuildContext context) {
    String age = '';
    if (product.createdAt != null && product.createdAt!.isNotEmpty) {
      try {
        final date = DateTime.parse(product.createdAt!);
        final diff = DateTime.now().difference(date);
        if (diff.inDays > 0) {
          age = '${diff.inDays}d ago';
        } else if (diff.inHours > 0) {
          age = '${diff.inHours}h ago';
        } else {
          age = 'Just now';
        }
      } catch (_) {}
    }

    final imageUrl = product.imageUrl.isNotEmpty
        ? product.imageUrl
        : (product.images.isNotEmpty ? product.images.first : '');

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
                            Text(
                              age,
                              style: AppThemes.f12w400.copyWith(
                                color: AppColors.productListingTextColor,
                              ),
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
              const SizedBox(height: 10),
              if (showActions)
                Row(
                  children: [
                    _OutlinedIconButton(
                      svgAsset: AppAssets.deleteIc,
                      onTap: onDelete,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _OutlinedTextButton(
                        label: editLabel,
                        onTap: onEdit,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _OutlinedTextButton(
                        label: product.favoritesCount.toString(),
                        icon: Icons.favorite_border,
                        iconColor: AppColors.brandBlack,
                        onTap: () {},
                      ),
                    ),
                    if (showPromote) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _PromoteButton(
                          label: promoteLabel,
                          onTap: onPromote,
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlinedIconButton extends StatelessWidget {
  const _OutlinedIconButton({required this.svgAsset, required this.onTap});

  final String svgAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Center(
            child: SvgPicture.asset(svgAsset, width: 20, height: 20),
          ),
        ),
      ),
    );
  }
}

class _OutlinedTextButton extends StatelessWidget {
  const _OutlinedTextButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  final String label;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? const Color(0xFF111827),
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  style: AppThemes.f14w500,
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

class _PromoteButton extends StatelessWidget {
  const _PromoteButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.brandBlack,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Center(
            child: Text(
              label,
              style: AppThemes.f14w500.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
