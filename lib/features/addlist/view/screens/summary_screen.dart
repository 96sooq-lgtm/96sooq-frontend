import 'dart:developer' as developer;

import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/addlist/bloc/payment/addlist_payment_flow_bloc.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/home/widgets/product_detail_sheet.dart';
import 'package:_96_sooq/features/paymets/bloc/payment_bloc.dart';
import 'package:_96_sooq/features/paymets/view/screens/payment_status_screen.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:_96_sooq/shared/global_widgets/custom_button_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  ProductModel? _fetchedProduct;
  bool _isLoadingProduct = true;

  String _formatAmount(double amount, {int decimals = 3}) {
    return amount.toStringAsFixed(decimals);
  }

  @override
  void initState() {
    super.initState();
    _fetchListing();
  }

  Future<void> _fetchListing() async {
    final state = context.read<AddlistPaymentFlowBloc>().state;
    final listingId = state.postedListingId;
    if (listingId == null || listingId.isEmpty) {
      if (mounted) setState(() => _isLoadingProduct = false);
      return;
    }

    try {
      final response = await DioServices.client.get(
        ApiEndpoints.listingDetail(listingId),
      );
      final data = response.data;
      if (data is Map<String, dynamic> && mounted) {
        setState(() {
          _fetchedProduct = ProductModel.fromJson(data);
          _isLoadingProduct = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingProduct = false);
      }
    } catch (e) {
      debugPrint('[SummaryScreen] Failed to fetch listing: $e');
      if (mounted) setState(() => _isLoadingProduct = false);
    }
  }

  void _openProductDetailSheet() {
    if (_fetchedProduct == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          ProductDetailSheet(product: _fetchedProduct!, hideActions: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, payState) async {
        // When checkout succeeds → open Paymob URL then go to status screen
        if (payState is PaymentCheckoutSuccess) {
          final uri = Uri.tryParse(payState.paymentUrl);
          if (uri != null) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }

          if (!context.mounted) return;
          // Navigate to PaymentStatusScreen, passing the transaction ID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: context.read<AddlistPaymentFlowBloc>(),
                  ),
                  BlocProvider.value(value: context.read<PaymentBloc>()),
                ],
                child: PaymentStatusScreen(
                  transactionId: payState.transactionId,
                ),
              ),
            ),
          );
        } else if (payState is PaymentCheckoutFailure) {
          // Show inline error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(payState.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AddlistPaymentFlowBloc, AddlistPaymentFlowState>(
        builder: (context, state) {
          final subtotal = state.subtotalAmount;
          final platformFee = subtotal * 0.02;
          final displayTotal = subtotal + platformFee;
          final currency = state.selectedPlanCurrency;

          // Determine product display info from API data or fallback to state
          final productTitle = _fetchedProduct?.title.isNotEmpty == true
              ? _fetchedProduct!.title
              : (state.productTitle.trim().isEmpty
                    ? AppLocalizations.of(context)!.productFallback
                    : state.productTitle.trim());
          final productDescription = _fetchedProduct?.details.isNotEmpty == true
              ? _fetchedProduct!.details
              : (state.description?.trim().isNotEmpty == true
                    ? state.description!.trim()
                    : AppLocalizations.of(context)!.noDescriptionText);
          final productImageUrl = _fetchedProduct?.imageUrl.isNotEmpty == true
              ? _fetchedProduct!.imageUrl
              : (_fetchedProduct?.images.isNotEmpty == true
                    ? _fetchedProduct!.images.first
                    : null);

          return Scaffold(
            backgroundColor: AppColors.white,
            bottomNavigationBar: SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: BlocBuilder<PaymentBloc, PaymentState>(
                  builder: (context, payState) {
                    final isLoading = payState is PaymentCheckoutLoading;
                    return CustomButton(
                      text: AppLocalizations.of(context)!.payAndConfirmTotal(
                        _formatAmount(displayTotal),
                        currency,
                      ),
                      isLoading: isLoading,
                      onPressed: () {
                        if (isLoading) return;
                        developer.log(
                          '\n╔══════════════════════════════════════════════════════════════╗\n'
                          '║ 🟠 PAY & CONFIRM TAPPED (SummaryScreen)                     ║\n'
                          '╠══════════════════════════════════════════════════════════════╣\n'
                          '║ ── FROM FLOW STATE ─────────────────────────────────────────\n'
                          '║ basePlanId         : ${state.basePlanId}\n'
                          '║ basePlanTitle      : ${state.basePlanTitle}\n'
                          '║ basePlanAmount     : ${state.basePlanAmount}\n'
                          '║ selectedBoostId    : ${state.selectedBoostId}\n'
                          '║ selectedBoostTitle : ${state.selectedBoostTitle}\n'
                          '║ selectedBoostAmount: ${state.selectedBoostAmount}\n'
                          '║ postedListingId    : ${state.postedListingId}\n'
                          '║ useExistingQuota   : ${state.useExistingQuota}\n'
                          '║ adDurationDays     : ${state.adDurationDays}\n'
                          '║ ── DISPLAY AMOUNTS ─────────────────────────────────────────\n'
                          '║ subtotalAmount     : ${state.subtotalAmount}\n'
                          '║ vatAmount          : ${state.effectiveVatAmount}\n'
                          '║ totalAmount        : ${state.totalAmount}\n'
                          '║ platformFee(2%)    : $platformFee\n'
                          '║ displayTotal       : $displayTotal\n'
                          '║ currency           : ${state.selectedPlanCurrency}\n'
                          '║ accountType        : ${state.accountType}\n'
                          '╚══════════════════════════════════════════════════════════════╝',
                          name: 'SummaryScreen',
                        );
                        context.read<PaymentBloc>().add(
                          PaymentCheckoutRequested(
                            listingPlanId: state.basePlanId,
                            adPlanId: state.selectedBoostId,
                            listingId: state.postedListingId,
                            useExistingQuota: state.useExistingQuota,
                            adDurationDays: state.adDurationDays,
                            currency: state.selectedPlanCurrency,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BackButtonWidget(ontap: () => Navigator.pop(context)),
                        Text(
                          AppLocalizations.of(context)!.paymentSummaryTitle,
                          style: AppThemes.f18w600,
                        ),
                        const SizedBox(width: 43),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _ProductSummaryCard(
                      productTitle: productTitle,
                      productDescription: productDescription,
                      networkImageUrl: productImageUrl,
                      isLoading: _isLoadingProduct,
                      onViewItemTap: _openProductDetailSheet,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.selectedPlanTitleSection,
                      style: AppThemes.f14w600.copyWith(
                        color: AppColors.productListingTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SelectedPlanCard(
                      planTitle: state.selectedPlanTitle.trim().isEmpty
                          ? AppLocalizations.of(context)!.productListingAdOption
                          : state.selectedPlanTitle.trim(),
                      planAmountText: '${_formatAmount(subtotal)} $currency',
                      currency: currency,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.orderDetailsTitleSection,
                      style: AppThemes.f14w600.copyWith(
                        color: AppColors.productListingTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _OrderDetailsCard(
                      subtotalText: '${_formatAmount(subtotal)} $currency',
                      platformFeeText:
                          '${_formatAmount(platformFee)} $currency',
                      totalText: '${_formatAmount(displayTotal)} $currency',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductSummaryCard extends StatelessWidget {
  const _ProductSummaryCard({
    required this.productTitle,
    required this.productDescription,
    required this.onViewItemTap,
    this.networkImageUrl,
    this.isLoading = false,
  });

  final String productTitle;
  final String productDescription;
  final String? networkImageUrl;
  final bool isLoading;
  final VoidCallback onViewItemTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = (networkImageUrl ?? '').trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 87,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 87,
                    height: 87,
                    child: hasImage
                        ? AppNetworkImage(
                            imageUrl: networkImageUrl!,
                            width: 87,
                            height: 87,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: const Color(0xFFD8DDE5),
                            child: const Icon(
                              Icons.phone_android_rounded,
                              color: Color(0xFF8A93A3),
                              size: 44,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(productTitle, style: AppThemes.f14w600),
                      const SizedBox(height: 2),
                      Text(
                        productDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppThemes.f12w500.copyWith(
                          color: AppColors.productListingTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onViewItemTap,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFC8D1DC)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context)!.viewItemButton,
                        style: AppThemes.f14w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SelectedPlanCard extends StatelessWidget {
  const _SelectedPlanCard({
    required this.planTitle,
    required this.planAmountText,
    required this.currency,
  });

  final String planTitle;
  final String planAmountText;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1111D4).withValues(alpha: 0.10),
            ),
            child: const Icon(
              Icons.ads_click_outlined,
              color: Color(0xFF1111D4),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(planTitle, style: AppThemes.f16w600),
                Text(
                  AppLocalizations.of(context)!.billedMonthlyText,
                  style: AppThemes.f16w400.copyWith(
                    color: AppColors.productListingTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                planAmountText,
                style: AppThemes.f16w600.copyWith(color: AppColors.subTextBlue),
              ),
              Text(
                currency,
                style: AppThemes.f12w500.copyWith(
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderDetailsCard extends StatelessWidget {
  const _OrderDetailsCard({
    required this.subtotalText,
    required this.platformFeeText,
    required this.totalText,
  });

  final String subtotalText;
  final String platformFeeText;
  final String totalText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6E8EC)),
      ),
      child: Column(
        children: [
          _AmountRow(
            label: AppLocalizations.of(context)!.subtotalLabel,
            value: subtotalText,
          ),
          const SizedBox(height: 12),
          _AmountRow(
            label: AppLocalizations.of(context)!.platformFeeLabel,
            value: platformFeeText,
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFDCE1E8), height: 1),
          const SizedBox(height: 14),
          _AmountRow(
            label: AppLocalizations.of(context)!.totalAmountLabel,
            value: totalText,
            isEmphasized: true,
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final labelStyle = isEmphasized
        ? AppThemes.f20w700
        : AppThemes.f16w500.copyWith(color: AppColors.productListingTextColor);
    final valueStyle = isEmphasized ? AppThemes.f20w600 : AppThemes.f16w500;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}

// class _PaymentMethodCard extends StatelessWidget {
//   const _PaymentMethodCard();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8F9FA),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFFE6E8EC)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 54,
//             height: 36,
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: const Color(0xFFE4E8EF)),
//             ),
//             alignment: Alignment.center,
//             child: Text(
//               'VISA',
//               style: AppThemes.f20w700.copyWith(
//                 color: const Color(0xFF1C42C7),
//                 fontStyle: FontStyle.italic,
//                 fontSize: 36 / 2,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Visa ending in 1234',
//                   style: AppThemes.f24w600.copyWith(fontSize: 39 / 2),
//                 ),
//                 Text(
//                   'EXP 09/27',
//                   style: AppThemes.f18w500.copyWith(
//                     color: const Color(0xFF94A3B8),
//                     fontSize: 30 / 2,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Icon(
//             Icons.chevron_right_rounded,
//             color: Color(0xFFBEC8D6),
//             size: 30,
//           ),
//         ],
//       ),
//     );
//   }
// }
