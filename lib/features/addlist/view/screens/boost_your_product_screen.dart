import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/addlist/bloc/payment/addlist_payment_flow_bloc.dart';
import 'package:_96_sooq/features/addlist/view/screens/summary_screen.dart';
import 'package:_96_sooq/features/paymets/bloc/payment_bloc.dart';
import 'package:_96_sooq/features/paymets/data/payment_repository.dart';
import 'package:_96_sooq/features/addlist/model/listing_account_type.dart';
import 'package:_96_sooq/features/root/view/screens/root_view.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

enum BoostFlowSource { addList, myDeals }

class BoostYourProductScreen extends StatefulWidget {
  const BoostYourProductScreen({
    super.key,
    required this.source,
    this.postId,
    this.postTitle,
    this.postAmount,
    this.postImageUrl,
    this.postDetails,
    this.accountType,
  });

  final BoostFlowSource source;
  final String? postId;
  final String? postTitle;
  final String? postAmount;
  final String? postImageUrl;
  final String? postDetails;
  final ListingAccountType? accountType;

  @override
  State<BoostYourProductScreen> createState() => _BoostYourProductScreenState();
}

class _BoostYourProductScreenState extends State<BoostYourProductScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<AddlistPaymentFlowBloc>();
      if (bloc.state.adPrices.isEmpty) {
        bloc.add(
          AdPricesRequested(
            accountType:
                widget.accountType ??
                bloc.state.accountType ??
                ListingAccountType.individual,
          ),
        );
      }
    });
  }

  int? _selectedIndex;
  int _quantity = 1;

  String _formatAmount(double amount) => amount.toStringAsFixed(3);
  double? _parseAmount(String? amountText) {
    final raw = (amountText ?? '').trim();
    if (raw.isEmpty) return null;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  bool _isSubmitting = false;

  Future<void> _onProceed() async {
    final paymentFlowBloc = context.read<AddlistPaymentFlowBloc>();
    final previousState = paymentFlowBloc.state;
    final localeCode = Localizations.localeOf(context).languageCode;
    final options = previousState.adPrices;
    final selected = _selectedIndex == null || _selectedIndex! >= options.length
        ? null
        : options[_selectedIndex!];
    final shouldRequirePayment =
        previousState.initialRequiresPayment || selected != null;

    final totalDays = selected != null ? _quantity * selected.durationDays : 1;
    final boostAmount = selected != null ? selected.price * _quantity : null;

    paymentFlowBloc.add(
      BoostSelectionUpdated(
        boostTitle: selected?.displayName(localeCode),
        boostAmount: boostAmount,
        boostId: selected?.id,
        adDurationDays: totalDays,
      ),
    );

    if (widget.source == BoostFlowSource.myDeals) {
      final fallbackTitle = (widget.postTitle ?? '').trim().isEmpty
          ? 'Product'
          : widget.postTitle!.trim();
      paymentFlowBloc.add(
        ProductDetailsCaptured(
          productTitle: previousState.productTitle.trim().isNotEmpty
              ? previousState.productTitle
              : fallbackTitle,
          productPrice:
              previousState.productPrice ?? _parseAmount(widget.postAmount),
          photoPaths: previousState.photoPaths,
          categoryName: previousState.categoryName ?? '',
          subCategoryName: previousState.subCategoryName ?? '',
          description: previousState.description ?? widget.postDetails ?? '',
          condition: previousState.condition,
          city: previousState.city,
          place: previousState.place,
          subCategoryId: previousState.subCategoryId ?? '',
          subCategoryAttributesSchema:
              previousState.subCategoryAttributesSchema,
          dynamicAttributes: previousState.dynamicAttributes,
          governorateId: previousState.governorateId,
          wilayatId: previousState.wilayatId,
          postedListingId: previousState.postedListingId ?? widget.postId,
        ),
      );
    }

    if (shouldRequirePayment) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: paymentFlowBloc),
              BlocProvider(create: (_) => PaymentBloc()),
            ],
            child: const SummaryScreen(),
          ),
        ),
      );
      return;
    }

    // No promotion selected — if useExistingQuota, call checkout bundle API.
    if (previousState.useExistingQuota) {
      if (_isSubmitting) return;
      setState(() => _isSubmitting = true);

      final listingId = previousState.postedListingId ?? widget.postId ?? '';

      try {
        const paymentRepo = PaymentRepository();
        await paymentRepo.initiateCheckout(
          listingId: listingId,
          useExistingQuota: true,
          currency: 'OMR',
        );

        if (!mounted) return;

        final messenger = ScaffoldMessenger.of(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const RootScreen()),
          (_) => false,
        );
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Your listing has been submitted for review!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checkout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RootScreen()),
      (_) => false,
    );
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Your post has been set for review and will be posted successfully in next 30 minutes',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final flowState = context.watch<AddlistPaymentFlowBloc>().state;
    final baseAmount = flowState.basePlanAmount;
    final options = flowState.adPrices;
    final isLoading = flowState.adPricesStatus == ListingPricesStatus.loading;
    final currency = flowState.basePlanCurrency;

    final selectedOption =
        _selectedIndex != null && _selectedIndex! < options.length
        ? options[_selectedIndex!]
        : null;
    final planPrice = selectedOption?.price ?? 0.0;
    final planDays = selectedOption?.durationDays ?? 1;
    final totalDays = _quantity * planDays;
    final boostTotal = planPrice * _quantity;
    final totalAmount = baseAmount + boostTotal;
    final perDayRate = planDays > 0 ? planPrice / planDays : 0.0;

    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Days counter + Current Rate row
              if (selectedOption != null) ...[
                Row(
                  children: [
                    // — button
                    _DaysButton(
                      icon: Icons.remove,
                      onTap: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Days display
                    Column(
                      children: [
                        Text(
                          'DAYS',
                          style: AppThemes.f10w600.copyWith(
                            color: const Color(0xFF8FA0B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('$totalDays', style: AppThemes.f24w600),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // + button
                    _DaysButton(
                      icon: Icons.add,
                      onTap: () => setState(() => _quantity++),
                    ),
                    const Spacer(),
                    // Current Rate
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'CURRENT RATE',
                          style: AppThemes.f10w600.copyWith(
                            color: const Color(0xFF8FA0B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _formatAmount(perDayRate),
                              style: AppThemes.f20w700,
                            ),
                            Text(
                              '$currency/d',
                              style: AppThemes.f12w500.copyWith(
                                color: AppColors.productListingTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Total Promotion Days
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Promotion Days',
                      style: AppThemes.f14w400.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    Text('$totalDays Days', style: AppThemes.f14w600),
                  ],
                ),
                const SizedBox(height: 10),
                // Total Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL PRICE',
                      style: AppThemes.f12w600.copyWith(
                        color: const Color(0xFF8FA0B8),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatAmount(totalAmount),
                          style: AppThemes.f24w600.copyWith(
                            color: AppColors.brandBlack,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          currency,
                          style: AppThemes.f14w600.copyWith(
                            color: AppColors.productListingTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              // Proceed to Payment button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (flowState.initialRequiresPayment ||
                                _selectedIndex != null)
                            ? localizations.proceedToPayText
                            : localizations.continueText,
                        style: AppThemes.f16w600.copyWith(color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButtonWidget(ontap: () => Navigator.pop(context)),
                  Text(
                    localizations.boostListingTitle,
                    style: AppThemes.f18w600,
                  ),
                  SizedBox(width: 30),
                  // GestureDetector(
                  //   onTap: () {},
                  //   child: Container(
                  //     width: 36,
                  //     height: 36,
                  //     decoration: BoxDecoration(
                  //       shape: BoxShape.circle,
                  //       border: Border.all(
                  //         color: const Color(0xFFE5EBF4),
                  //         width: 1.5,
                  //       ),
                  //     ),
                  //     child: const Icon(
                  //       Icons.help_outline_rounded,
                  //       size: 20,
                  //       color: Color(0xFF4A7DFF),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Which promotion do you need for your product?",
                style: AppThemes.f18w600,
              ),
              const SizedBox(height: 6),
              Text(
                'Select the best option to increase views, clicks, and sales.',
                style: AppThemes.f14w500.copyWith(
                  color: AppColors.productListingTextColor,
                ),
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const _BoostLoadingWidget()
              else
                ListView.separated(
                  itemCount: options.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final selected = _selectedIndex == index;

                    String iconAsset = AppAssets.productListAdIc;
                    if (option.adSubType == 'offers') {
                      iconAsset = AppAssets.offerAdIc;
                    } else if (option.adSubType == 'chat_screen') {
                      iconAsset = AppAssets.chatAdIc;
                    }

                    return _BoostListingTypeCard(
                      title: option.displayName(localeCode),
                      description: option.cleanDescription,
                      iconAsset: iconAsset,
                      amountLabel: '${_formatAmount(option.price)} $currency',
                      durationDays: option.durationDays,
                      isSelected: selected,
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedIndex = null;
                          } else {
                            _selectedIndex = index;
                            _quantity = 1;
                          }
                        });
                      },
                    );
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoostLoadingWidget extends StatelessWidget {
  const _BoostLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFFE9EDF3),
          highlightColor: const Color(0xFFF8FAFC),
          child: Container(
            width: double.infinity,
            height: 157,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        );
      },
    );
  }
}

class _BoostListingTypeCard extends StatelessWidget {
  const _BoostListingTypeCard({
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.amountLabel,
    required this.durationDays,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final String iconAsset;
  final String amountLabel;
  final int durationDays;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final durationLabel = durationDays <= 1
        ? '/ PER DAY'
        : '/ for $durationDays days';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF101727)
                : const Color(0xFFE5EBF4),
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    iconAsset,
                    width: 99,
                    height: 125,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppThemes.f16w600),
                        const SizedBox(height: 12),
                        Text(description, style: AppThemes.f12w500),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SelectionCircle(isSelected: isSelected),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountLabel,
                    style: AppThemes.f14w600.copyWith(
                      color: AppColors.subTextBlue,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      durationLabel,
                      style: AppThemes.f12w500.copyWith(
                        color: AppColors.productListingTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionCircle extends StatelessWidget {
  const _SelectionCircle({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xFFCCD6E4) : const Color(0xFFC5D1E0),
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF121926),
                ),
              ),
            )
          : null,
    );
  }
}

class _DaysButton extends StatelessWidget {
  const _DaysButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDisabled ? const Color(0xFFF3F4F6) : Colors.black,
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDisabled ? const Color(0xFFBCC3CE) : Colors.white,
        ),
      ),
    );
  }
}
