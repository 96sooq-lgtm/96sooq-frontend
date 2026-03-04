part of 'addlist_payment_flow_bloc.dart';

sealed class AddlistPaymentFlowEvent {
  const AddlistPaymentFlowEvent();
}

class FlowInitialized extends AddlistPaymentFlowEvent {
  const FlowInitialized({
    required this.accountType,
    required this.requiresPayment,
    required this.planTitle,
    required this.planAmount,
    this.planId,
    this.currency = 'OMR',
    this.useExistingQuota = false,
    this.vatAmount = 0.0,
    this.flowMode = ListFlowMode.add,
    this.editingProduct,
  });

  final ListingAccountType accountType;
  final bool requiresPayment;
  final String planTitle;
  final String? planId;
  final double planAmount;
  final String currency;
  final bool useExistingQuota;
  final double vatAmount;
  final ListFlowMode flowMode;
  final ProductModel? editingProduct;
}

class ProductDetailsCaptured extends AddlistPaymentFlowEvent {
  const ProductDetailsCaptured({
    required this.productTitle,
    this.productPrice,
    this.photoPaths = const <String>[],
    this.networkPhotos = const <String>[],
    this.categoryName,
    required this.subCategoryName,
    required this.subCategoryId,
    required this.subCategoryAttributesSchema,
    required this.dynamicAttributes,
    required this.description,
    this.condition,
    this.city,
    this.place,
    this.governorateId,
    this.wilayatId,
    this.postedListingId,
    this.postedProduct,
  });

  final String productTitle;
  final double? productPrice;
  final List<String> photoPaths;
  final List<String> networkPhotos;
  final String? categoryName;
  final String subCategoryName;
  final String description;
  final String? condition;
  final String? city;
  final String? place;
  final String subCategoryId;
  final List<CategoryAttributeSchemaModel>? subCategoryAttributesSchema;
  final Map<String, dynamic>? dynamicAttributes;
  final String? governorateId;
  final String? wilayatId;
  final String? postedListingId;
  final ProductModel? postedProduct;
}

class VatUpdated extends AddlistPaymentFlowEvent {
  const VatUpdated(this.vatAmount);

  final double? vatAmount;
}

class BoostSelectionUpdated extends AddlistPaymentFlowEvent {
  const BoostSelectionUpdated({
    this.boostTitle,
    this.boostAmount,
    this.boostId,
    this.adDurationDays = 1,
  });

  final String? boostTitle;
  final double? boostAmount;
  final String? boostId;
  final int adDurationDays;
}

class ListingPricesRequested extends AddlistPaymentFlowEvent {
  const ListingPricesRequested({required this.accountType});

  final ListingAccountType accountType;
}

class AdPricesRequested extends AddlistPaymentFlowEvent {
  const AdPricesRequested({required this.accountType});

  final ListingAccountType accountType;
}

class FlowReset extends AddlistPaymentFlowEvent {
  const FlowReset();
}
