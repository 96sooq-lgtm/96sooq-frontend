import 'dart:developer' as developer;

import 'package:_96_sooq/features/addlist/data/addlist_subscription_api_service.dart';
import 'package:_96_sooq/features/addlist/model/listing_account_type.dart';
import 'package:_96_sooq/features/addlist/model/listing_prices_response_model.dart';
import 'package:_96_sooq/features/categories/model/category_model.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'addlist_payment_flow_event.dart';
part 'addlist_payment_flow_state.dart';

enum ListFlowMode { add, edit }

class AddlistPaymentFlowBloc
    extends Bloc<AddlistPaymentFlowEvent, AddlistPaymentFlowState> {
  AddlistPaymentFlowBloc({
    AddlistSubscriptionApiService? subscriptionApiService,
  }) : _subscriptionApiService =
           subscriptionApiService ?? const AddlistSubscriptionApiService(),
       super(const AddlistPaymentFlowState()) {
    on<FlowInitialized>(_onFlowInitialized);
    on<ProductDetailsCaptured>(_onProductDetailsCaptured);
    on<VatUpdated>(_onVatUpdated);
    on<BoostSelectionUpdated>(_onBoostSelectionUpdated);
    on<ListingPricesRequested>(_onListingPricesRequested);
    on<AdPricesRequested>(_onAdPricesRequested);
    on<FlowReset>(_onFlowReset);
  }

  final AddlistSubscriptionApiService _subscriptionApiService;

  void _onFlowInitialized(
    FlowInitialized event,
    Emitter<AddlistPaymentFlowState> emit,
  ) {
    developer.log(
      '\n╔══════════════════════════════════════════════════════════════╗\n'
      '║ 🟢 FLOW INITIALIZED                                        ║\n'
      '╠══════════════════════════════════════════════════════════════╣\n'
      '║ accountType       : ${event.accountType}\n'
      '║ requiresPayment   : ${event.requiresPayment}\n'
      '║ flowMode          : ${event.flowMode}\n'
      '║ planTitle          : ${event.planTitle}\n'
      '║ planId             : ${event.planId}\n'
      '║ planAmount         : ${event.planAmount}\n'
      '║ currency           : ${event.currency}\n'
      '║ useExistingQuota   : ${event.useExistingQuota}\n'
      '║ vatAmount          : ${event.vatAmount}\n'
      '╚══════════════════════════════════════════════════════════════╝',
      name: 'PaymentFlow',
    );
    emit(
      state.copyWith(
        accountType: event.accountType,
        requiresPayment: event.requiresPayment,
        initialRequiresPayment: event.requiresPayment,
        flowMode: event.flowMode,
        editingProduct: event.editingProduct,
        basePlanTitle: event.planTitle,
        basePlanAmount: event.planAmount,
        basePlanCurrency: event.currency,
        basePlanId: event.planId,
        useExistingQuota: event.useExistingQuota,
        selectedBoostTitle: null,
        selectedBoostAmount: null,
        selectedPlanTitle: event.planTitle,
        selectedPlanAmount: event.planAmount,
        selectedPlanCurrency: event.currency,
        vatAmount: event.vatAmount,
      ),
    );
  }

  void _onProductDetailsCaptured(
    ProductDetailsCaptured event,
    Emitter<AddlistPaymentFlowState> emit,
  ) {
    emit(
      state.copyWith(
        productTitle: event.productTitle,
        productPrice: event.productPrice,
        photoPaths: event.photoPaths,
        networkPhotos: event.networkPhotos,
        categoryName: event.categoryName,
        subCategoryName: event.subCategoryName,
        description: event.description,
        condition: event.condition,
        city: event.city,
        place: event.place,
        subCategoryId: event.subCategoryId,
        subCategoryAttributesSchema: event.subCategoryAttributesSchema,
        dynamicAttributes: event.dynamicAttributes,
        governorateId: event.governorateId,
        wilayatId: event.wilayatId,
        postedListingId: event.postedListingId,
        postedProduct: event.postedProduct,
      ),
    );
  }

  void _onVatUpdated(VatUpdated event, Emitter<AddlistPaymentFlowState> emit) {
    emit(state.copyWith(vatAmount: event.vatAmount));
  }

  void _onBoostSelectionUpdated(
    BoostSelectionUpdated event,
    Emitter<AddlistPaymentFlowState> emit,
  ) {
    final hasBoost =
        (event.boostTitle?.trim().isNotEmpty ?? false) &&
        event.boostAmount != null;
    final boostAmount = hasBoost ? event.boostAmount! : 0.0;
    final effectiveTitle = hasBoost
        ? '${state.basePlanTitle} + ${event.boostTitle!.trim()}'
        : state.basePlanTitle;

    final newTotal = state.basePlanAmount + boostAmount;
    developer.log(
      '\n╔══════════════════════════════════════════════════════════════╗\n'
      '║ 🔵 BOOST SELECTION UPDATED                                  ║\n'
      '╠══════════════════════════════════════════════════════════════╣\n'
      '║ hasBoost           : $hasBoost\n'
      '║ boostTitle         : ${event.boostTitle}\n'
      '║ boostId            : ${event.boostId}\n'
      '║ boostAmount        : ${event.boostAmount}\n'
      '║ adDurationDays     : ${event.adDurationDays}\n'
      '║ ── CALCULATED ────────────────────────────────────────────\n'
      '║ basePlanAmount     : ${state.basePlanAmount}\n'
      '║ basePlanId         : ${state.basePlanId}\n'
      '║ + boostAmount      : $boostAmount\n'
      '║ = TOTAL (plan+boost): $newTotal\n'
      '║ effectiveTitle     : $effectiveTitle\n'
      '║ requiresPayment    : ${state.initialRequiresPayment || hasBoost}\n'
      '╚══════════════════════════════════════════════════════════════╝',
      name: 'PaymentFlow',
    );

    emit(
      state.copyWith(
        requiresPayment: state.initialRequiresPayment || hasBoost,
        selectedBoostTitle: hasBoost ? event.boostTitle!.trim() : null,
        selectedBoostAmount: hasBoost ? event.boostAmount : null,
        selectedBoostId: hasBoost ? event.boostId : null,
        adDurationDays: hasBoost ? event.adDurationDays : 1,
        selectedPlanTitle: effectiveTitle,
        selectedPlanAmount: state.basePlanAmount + boostAmount,
        selectedPlanCurrency: state.basePlanCurrency,
      ),
    );
  }

  void _onFlowReset(FlowReset event, Emitter<AddlistPaymentFlowState> emit) {
    emit(const AddlistPaymentFlowState());
  }

  Future<void> _onListingPricesRequested(
    ListingPricesRequested event,
    Emitter<AddlistPaymentFlowState> emit,
  ) async {
    emit(
      state.copyWith(
        listingPricesStatus: ListingPricesStatus.loading,
        listingPricesForAccountType: event.accountType,
        listingQuotaStatus: null,
        listingPricesError: null,
      ),
    );

    final isStore = event.accountType == ListingAccountType.business;
    try {
      final listingPrices = await _subscriptionApiService.fetchListingPrices(
        isStore: isStore,
      );
      emit(
        state.copyWith(
          listingPricesStatus: ListingPricesStatus.success,
          listingPrices: listingPrices.plans,
          listingQuotaStatus: listingPrices.quotaStatus,
          listingPricesForAccountType: event.accountType,
          listingPricesError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          listingPricesStatus: ListingPricesStatus.failure,
          listingPrices: const <ListingPlanModel>[],
          listingQuotaStatus: null,
          listingPricesForAccountType: event.accountType,
          listingPricesError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAdPricesRequested(
    AdPricesRequested event,
    Emitter<AddlistPaymentFlowState> emit,
  ) async {
    emit(
      state.copyWith(
        adPricesStatus: ListingPricesStatus.loading,
        adPricesError: null,
      ),
    );

    final isStore = event.accountType == ListingAccountType.business;
    try {
      final adPrices = await _subscriptionApiService.fetchAdPrices(
        isStore: isStore,
      );
      emit(
        state.copyWith(
          adPricesStatus: ListingPricesStatus.success,
          adPrices: adPrices,
          adPricesError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          adPricesStatus: ListingPricesStatus.failure,
          adPrices: const <ListingPlanModel>[],
          adPricesError: e.toString(),
        ),
      );
    }
  }
}
