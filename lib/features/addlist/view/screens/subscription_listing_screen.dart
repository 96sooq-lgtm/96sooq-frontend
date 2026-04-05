import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/core/s3_upload/s3_upload_service.dart';
import 'package:_96_sooq/features/addlist/bloc/payment/addlist_payment_flow_bloc.dart';
import 'package:_96_sooq/features/addlist/bloc/store_creation/store_creation_bloc.dart';
import 'package:_96_sooq/features/addlist/model/listing_account_type.dart';
import 'package:_96_sooq/features/addlist/model/listing_prices_response_model.dart';
import 'package:_96_sooq/features/addlist/view/screens/create_your_store_screen.dart';
import 'package:_96_sooq/features/addlist/view/screens/list_your_product_screen.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_event.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_state.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:_96_sooq/shared/global_widgets/custom_button_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:translator/translator.dart';

import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/addlist/view/screens/boost_your_product_screen.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';

class SubscriptionListingScreen extends StatefulWidget {
  static const String routeName = '/subscription-listing';

  const SubscriptionListingScreen({
    super.key,
    required this.accountType,
    this.promoteProduct,
  });

  final ListingAccountType accountType;
  final ProductModel? promoteProduct;

  @override
  State<SubscriptionListingScreen> createState() =>
      _SubscriptionListingScreenState();
}

class _SubscriptionListingScreenState extends State<SubscriptionListingScreen> {
  int _selectedPlanIndex = 0;
  final GoogleTranslator _translator = GoogleTranslator();
  Map<String, List<String>> _translatedFeaturesByPlanId =
      <String, List<String>>{};
  bool _isTranslatingFeatures = false;
  final Set<String> _translatingPlanIds = <String>{};
  String? _lastTranslationSignature;
  String? _lastLocaleCodeForFeatures;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AddlistPaymentFlowBloc>().add(
        ListingPricesRequested(accountType: widget.accountType),
      );
      if (widget.accountType == ListingAccountType.business) {
        context.read<StoreProfileBloc>().add(
          const StoreProfileCheckRequested(),
        );
      }
    });
  }

  _HeroContent _heroContent(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return widget.accountType == ListingAccountType.business
        ? _HeroContent(
            title: loc.forBusinessesTitle,
            subtitle: loc.forBusinessesSubtitle,
            icon: Icons.business_outlined,
          )
        : _HeroContent(
            title: loc.chooseYourPlanTitle,
            subtitle: loc.chooseYourPlanSubtitle,
            icon: Icons.person_outline_rounded,
          );
  }

  void _handleRetry() {
    context.read<AddlistPaymentFlowBloc>().add(
      ListingPricesRequested(accountType: widget.accountType),
    );
  }

  void _handleContinue(List<ListingPlanModel> plans, String localeCode) {
    if (plans.isEmpty || _selectedPlanIndex >= plans.length) return;

    final selectedPlan = plans[_selectedPlanIndex];
    final requiresPayment = selectedPlan.price > 0;
    final paymentFlowBloc = context.read<AddlistPaymentFlowBloc>();

    paymentFlowBloc.add(
      FlowInitialized(
        accountType: widget.accountType,
        requiresPayment: requiresPayment,
        planTitle: selectedPlan.displayName(localeCode),
        planId: selectedPlan.id,
        planAmount: selectedPlan.price,
        currency: 'OMR',
      ),
    );

    final storeProfileState = context.read<StoreProfileBloc>().state;
    final hasStore =
        storeProfileState.status == StoreProfileLoadStatus.success &&
        storeProfileState.hasStore;

    final Widget destination;
    if (widget.promoteProduct != null) {
      destination = BlocProvider.value(
        value: paymentFlowBloc,
        child: BoostYourProductScreen(
          source: BoostFlowSource.myDeals,
          postId: widget.promoteProduct!.id,
          postTitle: widget.promoteProduct!.title,
          postAmount: widget.promoteProduct!.amount,
          postImageUrl: widget.promoteProduct!.imageUrl.isNotEmpty
              ? widget.promoteProduct!.imageUrl
              : (widget.promoteProduct!.images.isNotEmpty
                    ? widget.promoteProduct!.images.first
                    : ''),
          postDetails: widget.promoteProduct!.details,
          accountType: widget.accountType,
        ),
      );
    } else if (widget.accountType == ListingAccountType.business && !hasStore) {
      destination = MultiBlocProvider(
        providers: [
          BlocProvider.value(value: paymentFlowBloc),
          BlocProvider(
            create: (_) => StoreCreationBloc(
              s3UploadService: S3UploadService(DioServices.client),
            ),
          ),
        ],
        child: CreateYourStoreScreen(requiresPayment: requiresPayment),
      );
    } else {
      destination = BlocProvider.value(
        value: paymentFlowBloc,
        child: ListYourProductScreen(requiresPayment: requiresPayment),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  String _buildPlansSignature(List<ListingPlanModel> plans) {
    final normalized =
        plans
            .map((plan) => '${plan.id}|${plan.description.trim()}')
            .toList(growable: false)
          ..sort();
    return normalized.join('||');
  }

  Future<void> _ensureFeatureTranslations({
    required List<ListingPlanModel> plans,
    required String localeCode,
    required BuildContext context,
  }) async {
    if (localeCode != 'ar') {
      if (!mounted) return;
      if (_translatedFeaturesByPlanId.isNotEmpty ||
          _isTranslatingFeatures ||
          _lastTranslationSignature != null ||
          _lastLocaleCodeForFeatures != null ||
          _translatingPlanIds.isNotEmpty) {
        setState(() {
          _translatedFeaturesByPlanId = <String, List<String>>{};
          _isTranslatingFeatures = false;
          _translatingPlanIds.clear();
          _lastTranslationSignature = null;
          _lastLocaleCodeForFeatures = null;
        });
      }
      return;
    }

    final signature = _buildPlansSignature(plans);
    final alreadyTranslatedForSignature =
        _lastTranslationSignature == signature &&
        _lastLocaleCodeForFeatures == localeCode &&
        _translatedFeaturesByPlanId.isNotEmpty;

    if (_isTranslatingFeatures || alreadyTranslatedForSignature) return;

    if (mounted) {
      setState(() {
        _isTranslatingFeatures = true;
        _translatingPlanIds.clear();
      });
    }

    final translated = <String, List<String>>{};

    for (final plan in plans) {
      if (mounted) {
        setState(() => _translatingPlanIds.add(plan.id));
      }

      final sourceLines = plan.featureLines.isNotEmpty
          ? plan.featureLines
          : <String>[
              AppLocalizations.of(
                context,
              )!.daysListingDuration(plan.durationDays.toString()),
            ];

      final translatedLines = <String>[];
      for (final line in sourceLines) {
        try {
          final value = await _translator.translate(line, from: 'en', to: 'ar');
          translatedLines.add(value.text);
        } catch (_) {
          translatedLines.add(line);
        }
      }

      translated[plan.id] = translatedLines;
      if (mounted) {
        setState(() => _translatingPlanIds.remove(plan.id));
      }
    }

    if (!mounted) return;
    setState(() {
      _translatedFeaturesByPlanId = translated;
      _isTranslatingFeatures = false;
      _translatingPlanIds.clear();
      _lastTranslationSignature = signature;
      _lastLocaleCodeForFeatures = localeCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final heroContent = _heroContent(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return BlocBuilder<AddlistPaymentFlowBloc, AddlistPaymentFlowState>(
      builder: (context, state) {
        final plans = state.listingPrices;
        final isLoading =
            state.listingPricesStatus == ListingPricesStatus.loading;
        final hasLoaded =
            state.listingPricesStatus == ListingPricesStatus.success;
        final hasFailed =
            state.listingPricesStatus == ListingPricesStatus.failure;

        if (_selectedPlanIndex >= plans.length && plans.isNotEmpty) {
          _selectedPlanIndex = 0;
        }

        if (hasLoaded && plans.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _ensureFeatureTranslations(
              plans: plans,
              localeCode: localeCode,
              context: context,
            );
          });
        }

        final canContinue = hasLoaded && plans.isNotEmpty;

        return Scaffold(
          backgroundColor: AppColors.white,
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: CustomButton(
                text: AppLocalizations.of(context)!.continueWithSelection,
                color: canContinue
                    ? AppColors.primaryColor
                    : AppColors.primaryColor.withValues(alpha: 0.45),
                onPressed: canContinue
                    ? () => _handleContinue(plans, localeCode)
                    : () {},
              ),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BackButtonWidget(ontap: () => Navigator.pop(context)),
                        Text(
                          AppLocalizations.of(context)!.subscriptionPlansTitle,
                          style: AppThemes.f16w600,
                        ),
                        const SizedBox(width: 30),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor,
                      ),
                      child: Icon(
                        heroContent.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      heroContent.title,
                      textAlign: TextAlign.center,
                      style: AppThemes.f24w600,
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 16),
                    if (isLoading) const _PlansLoadingWidget(),
                    if (hasFailed)
                      _PlansErrorWidget(
                        message: state.listingPricesError,
                        onRetry: _handleRetry,
                      ),
                    if (hasLoaded && plans.isEmpty) const _PlansEmptyWidget(),
                    if (hasLoaded && plans.isNotEmpty)
                      ListView.separated(
                        itemCount: plans.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final plan = plans[index];
                          final sourceFeatures = plan.featureLines.isNotEmpty
                              ? plan.featureLines
                              : <String>[
                                  AppLocalizations.of(
                                    context,
                                  )!.daysListingDuration(
                                    plan.durationDays.toString(),
                                  ),
                                ];
                          final hasArabicFeatureTranslations =
                              localeCode == 'ar' &&
                              _translatedFeaturesByPlanId[plan.id] != null;
                          final features = hasArabicFeatureTranslations
                              ? _translatedFeaturesByPlanId[plan.id]!
                              : sourceFeatures;
                          final showFeatureShimmer =
                              localeCode == 'ar' &&
                              (hasArabicFeatureTranslations == false) &&
                              (_isTranslatingFeatures ||
                                  _translatingPlanIds.contains(plan.id));

                          return _SubscriptionPlanCard(
                            title: plan.displayName(localeCode),
                            subtitle: _buildSubtitle(context, plan),
                            price: plan.price.toStringAsFixed(3),
                            currency: 'OMR',
                            features: features,
                            showFeatureShimmer: showFeatureShimmer,
                            isBestValue: plan.isBestValue,
                            isSelected: _selectedPlanIndex == index,
                            onTap: () =>
                                setState(() => _selectedPlanIndex = index),
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F2FD),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xFFE0E0FF),
                            ),
                            child: const Icon(Icons.rocket_launch_rounded),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.whyUpgradeTitle,
                                  style: AppThemes.f14w600.copyWith(
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(context)!.whyUpgradeDesc,
                                  style: AppThemes.f14w400.copyWith(
                                    color: AppColors.productListingTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _buildSubtitle(BuildContext context, ListingPlanModel plan) {
    return AppLocalizations.of(
      context,
    )!.daysLabel(plan.durationDays.toString());
  }
}

class _PlansLoadingWidget extends StatelessWidget {
  const _PlansLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: const Color(0xFFE9EDF3),
        highlightColor: const Color(0xFFF8FAFC),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFDCE2EC), width: 1.2),
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerLine(width: 120, height: 18),
                        const SizedBox(height: 8),
                        _shimmerLine(width: 160, height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _shimmerLine(width: 62, height: 20),
                      const SizedBox(height: 6),
                      _shimmerLine(width: 38, height: 14),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _shimmerFeatureRow(),
              const SizedBox(height: 10),
              _shimmerFeatureRow(),
              const SizedBox(height: 10),
              _shimmerFeatureRow(width: 180),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _shimmerFeatureRow({double width = 220}) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        _shimmerLine(width: width, height: 13),
      ],
    );
  }

  static Widget _shimmerLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _PlansErrorWidget extends StatelessWidget {
  const _PlansErrorWidget({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD7D7)),
      ),
      child: Column(
        children: [
          Text(
            message ?? AppLocalizations.of(context)!.failedToLoadPlans,
            textAlign: TextAlign.center,
            style: AppThemes.f14w500.copyWith(color: const Color(0xFF9D1C1C)),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.primaryColor,
              ),
              child: Text(
                AppLocalizations.of(context)!.retryText,
                style: AppThemes.f14w600.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlansEmptyWidget extends StatelessWidget {
  const _PlansEmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE2EC)),
      ),
      child: Text(
        AppLocalizations.of(context)!.noSubscriptionPlans,
        textAlign: TextAlign.center,
        style: AppThemes.f14w500,
      ),
    );
  }
}

class _HeroContent {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HeroContent({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _SubscriptionPlanCard extends StatelessWidget {
  const _SubscriptionPlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.currency,
    required this.features,
    required this.showFeatureShimmer,
    required this.isBestValue,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String price;
  final String currency;
  final List<String> features;
  final bool showFeatureShimmer;
  final bool isBestValue;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFFDCE2EC),
            width: isSelected ? 2 : 1.4,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x1F94A3B8),
                    blurRadius: 0,
                    spreadRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            if (isBestValue)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadiusDirectional.only(
                      topEnd: Radius.circular(22),
                      bottomStart: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.bestValueBadge,
                    style: AppThemes.f12w700.copyWith(
                      color: AppColors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(18, isBestValue ? 38 : 18, 18, 18),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppThemes.f18w600),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: AppThemes.f14w400.copyWith(
                                color: AppColors.productListingTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(price, style: AppThemes.f20w600),
                          Text(
                            currency,
                            style: AppThemes.f16w600.copyWith(
                              color: const Color(0xFF7A8DA6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (showFeatureShimmer)
                    const Column(
                      children: [
                        _FeatureShimmerRow(),
                        SizedBox(height: 10),
                        _FeatureShimmerRow(),
                        SizedBox(height: 10),
                        _FeatureShimmerRow(width: 180),
                      ],
                    )
                  else
                    Column(
                      children: features
                          .map(
                            (feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF316FF6),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: AppThemes.f14w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFCED5FF),
                        width: 1.4,
                      ),
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

class _FeatureShimmerRow extends StatelessWidget {
  const _FeatureShimmerRow({this.width = 220});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE9EDF3),
      highlightColor: const Color(0xFFF8FAFC),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              width: width,
              height: 13,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
