import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/addlist/bloc/payment/addlist_payment_flow_bloc.dart';
import 'package:_96_sooq/features/addlist/model/listing_account_type.dart';
import 'package:_96_sooq/features/addlist/view/screens/list_your_product_screen.dart';
import 'package:_96_sooq/features/addlist/view/screens/subscription_listing_screen.dart';
import 'package:_96_sooq/features/addlist/widgets/account_type_widget.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_state.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:_96_sooq/shared/global_widgets/custom_button_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddlistScreen extends StatefulWidget {
  static const String routeName = '/addlist';

  const AddlistScreen({super.key});

  @override
  State<AddlistScreen> createState() => _AddlistScreenState();
}

class _AddlistScreenState extends State<AddlistScreen> {
  ListingAccountType _selectedType = ListingAccountType.individual;

  TextStyle _withArabicHeavierWeight(TextStyle style, bool isArabic) {
    if (!isArabic) return style;
    final currentWeight = style.fontWeight?.value ?? FontWeight.w400.value;
    final bumpedWeight = (currentWeight + 100).clamp(100, 900);
    final matchedWeight = FontWeight.values.firstWhere(
      (weight) => weight.value == bumpedWeight,
      orElse: () => FontWeight.w900,
    );
    return style.copyWith(fontWeight: matchedWeight);
  }

  ListingAccountType _effectiveAccountType({required bool showOnlyBusiness}) {
    return showOnlyBusiness ? ListingAccountType.business : _selectedType;
  }

  void _handleContinue(ListingAccountType accountType) {
    final storeState = context.read<StoreProfileBloc>().state;
    final hasActiveStore =
        storeState.hasStore &&
        storeState.status == StoreProfileLoadStatus.success &&
        (storeState.store?.status ?? '') == 'active';

    // Active store owners skip the subscription plan page entirely
    if (accountType == ListingAccountType.business && hasActiveStore) {
      final paymentFlowBloc = AddlistPaymentFlowBloc();
      paymentFlowBloc.add(
        FlowInitialized(
          accountType: accountType,
          requiresPayment: false,
          planTitle: 'Existing Store Plan',
          planAmount: 0.0,
          currency: 'OMR',
          useExistingQuota: true,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: paymentFlowBloc,
            child: const ListYourProductScreen(requiresPayment: false),
          ),
        ),
      );
      return;
    }

    final destination = BlocProvider(
      create: (_) => AddlistPaymentFlowBloc(),
      child: SubscriptionListingScreen(accountType: accountType),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(
          name: SubscriptionListingScreen.routeName,
        ),
        builder: (context) => destination,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return BlocBuilder<StoreProfileBloc, StoreProfileState>(
      builder: (context, storeState) {
        final storeExists =
            storeState.hasStore &&
            storeState.status == StoreProfileLoadStatus.success;
        final showOnlyBusiness = storeExists;
        final effectiveType = _effectiveAccountType(
          showOnlyBusiness: showOnlyBusiness,
        );
        final selectedAccountLabel =
            effectiveType == ListingAccountType.individual
            ? localizations.individualShortLabel
            : localizations.businessShortLabel;

        return Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: CustomButton(
                text: localizations.continueWithAccountType(
                  selectedAccountLabel,
                ),
                onPressed: () => _handleContinue(effectiveType),
              ),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        BackButtonWidget(ontap: () => Navigator.pop(context)),
                        Text(
                          localizations.chooseAccountTypeTitle,
                          style: _withArabicHeavierWeight(
                            AppThemes.f14w600,
                            isArabic,
                          ),
                        ),
                        const SizedBox(width: 30),
                      ],
                    ),
                    Center(
                      child: Text(
                        localizations.selectRoleSubtitle,
                        textAlign: TextAlign.center,
                        style: _withArabicHeavierWeight(
                          AppThemes.f10w400,
                          isArabic,
                        ).copyWith(color: AppColors.productListingTextColor),
                      ),
                    ),
                    const SizedBox(height: 13),
                    if (!showOnlyBusiness) ...[
                      AccountTypeCard(
                        icon: AppAssets.personPlaceholder,
                        iconBg: const Color(0xFFE6EDFF),
                        title: localizations.individualAccountType,
                        advantages: [
                          localizations.individualAdvantage1,
                          localizations.individualAdvantage2,
                          localizations.individualAdvantage3,
                        ],
                        isSelected:
                            _selectedType == ListingAccountType.individual,
                        onTap: () => setState(
                          () => _selectedType = ListingAccountType.individual,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    AccountTypeCard(
                      icon: AppAssets.businessPlaceholderIc,
                      iconBg: const Color(0xFFFFE9C9),
                      title: localizations.businessAccountType,
                      advantages: [
                        localizations.businessAdvantage1,
                        localizations.businessAdvantage2,
                        localizations.businessAdvantage3,
                      ],
                      isSelected: showOnlyBusiness
                          ? true
                          : _selectedType == ListingAccountType.business,
                      onTap: showOnlyBusiness
                          ? () {}
                          : () => setState(
                              () => _selectedType = ListingAccountType.business,
                            ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
