part of 'addlist_payment_flow_bloc.dart';

enum ListingPricesStatus { initial, loading, success, failure }

class AddlistPaymentFlowState extends Equatable {
  const AddlistPaymentFlowState({
    this.accountType = ListingAccountType.individual,
    this.flowMode = ListFlowMode.add,
    this.editingProduct,
    this.requiresPayment = false,
    this.initialRequiresPayment = false,
    this.basePlanTitle = '',
    this.basePlanAmount = 0.0,
    this.basePlanCurrency = 'OMR',
    this.basePlanId,
    this.selectedBoostTitle,
    this.selectedBoostAmount,
    this.selectedBoostId,
    this.selectedPlanTitle = '',
    this.selectedPlanAmount = 0.0,
    this.selectedPlanCurrency = 'OMR',
    this.productTitle = '',
    this.productPrice,
    this.photoPaths = const <String>[],
    this.networkPhotos = const <String>[],
    this.categoryName,
    this.subCategoryName,
    this.description,
    this.condition,
    this.city,
    this.place,
    this.subCategoryId,
    this.subCategoryAttributesSchema = const <CategoryAttributeSchemaModel>[],
    this.dynamicAttributes = const <String, dynamic>{},
    this.governorateId,
    this.wilayatId,
    this.vatAmount,
    this.listingPricesStatus = ListingPricesStatus.initial,
    this.listingPrices = const <ListingPlanModel>[],
    this.listingQuotaStatus,
    this.listingPricesError,
    this.listingPricesForAccountType,
    this.adPricesStatus = ListingPricesStatus.initial,
    this.adPrices = const <ListingPlanModel>[],
    this.adPricesError,
    this.useExistingQuota = false,
    this.adDurationDays = 1,
    this.isPosting = false,
    this.postingError,
    this.postedListingId,
    this.postedProduct,
  });

  final ListingAccountType accountType;
  final ListFlowMode flowMode;
  final ProductModel? editingProduct;
  final bool requiresPayment;
  final bool initialRequiresPayment;
  final String basePlanTitle;
  final double basePlanAmount;
  final String basePlanCurrency;
  final String? basePlanId;
  final String? selectedBoostTitle;
  final double? selectedBoostAmount;
  final String? selectedBoostId;
  final String selectedPlanTitle;
  final double selectedPlanAmount;
  final String selectedPlanCurrency;
  final String productTitle;
  final double? productPrice;
  final List<String> photoPaths;
  final List<String> networkPhotos;
  final String? categoryName;
  final String? subCategoryName;
  final String? description;
  final String? condition;
  final String? city;
  final String? place;
  final String? subCategoryId;
  final List<CategoryAttributeSchemaModel> subCategoryAttributesSchema;
  final Map<String, dynamic> dynamicAttributes;
  final String? governorateId;
  final String? wilayatId;
  final double? vatAmount;
  final ListingPricesStatus listingPricesStatus;
  final List<ListingPlanModel> listingPrices;
  final ListingQuotaStatusModel? listingQuotaStatus;
  final String? listingPricesError;
  final ListingAccountType? listingPricesForAccountType;
  final ListingPricesStatus adPricesStatus;
  final List<ListingPlanModel> adPrices;
  final String? adPricesError;
  final bool useExistingQuota;
  final int adDurationDays;
  final bool isPosting;
  final String? postingError;
  final String? postedListingId;
  final ProductModel? postedProduct;

  bool get canProceedToSummary => requiresPayment;
  bool get hasProductPreview => productTitle.trim().isNotEmpty;
  double get subtotalAmount => selectedPlanAmount;
  double get effectiveVatAmount => vatAmount ?? 0.0;
  double get totalAmount => subtotalAmount + effectiveVatAmount;

  static const Object _unset = Object();

  AddlistPaymentFlowState copyWith({
    ListingAccountType? accountType,
    ListFlowMode? flowMode,
    ProductModel? editingProduct,
    bool? requiresPayment,
    bool? initialRequiresPayment,
    String? basePlanTitle,
    double? basePlanAmount,
    String? basePlanCurrency,
    Object? basePlanId = _unset,
    Object? selectedBoostTitle = _unset,
    Object? selectedBoostAmount = _unset,
    Object? selectedBoostId = _unset,
    String? selectedPlanTitle,
    double? selectedPlanAmount,
    String? selectedPlanCurrency,
    String? productTitle,
    Object? productPrice = _unset,
    List<String>? photoPaths,
    List<String>? networkPhotos,
    Object? categoryName = _unset,
    Object? subCategoryName = _unset,
    Object? description = _unset,
    Object? condition = _unset,
    Object? city = _unset,
    Object? place = _unset,
    Object? subCategoryId = _unset,
    List<CategoryAttributeSchemaModel>? subCategoryAttributesSchema,
    Map<String, dynamic>? dynamicAttributes,
    Object? governorateId = _unset,
    Object? wilayatId = _unset,
    Object? vatAmount = _unset,
    ListingPricesStatus? listingPricesStatus,
    List<ListingPlanModel>? listingPrices,
    Object? listingQuotaStatus = _unset,
    Object? listingPricesError = _unset,
    Object? listingPricesForAccountType = _unset,
    ListingPricesStatus? adPricesStatus,
    List<ListingPlanModel>? adPrices,
    Object? adPricesError = _unset,
    bool? useExistingQuota,
    int? adDurationDays,
    bool? isPosting,
    Object? postingError = _unset,
    Object? postedListingId = _unset,
    Object? postedProduct = _unset,
  }) {
    return AddlistPaymentFlowState(
      accountType: accountType ?? this.accountType,
      flowMode: flowMode ?? this.flowMode,
      editingProduct: editingProduct ?? this.editingProduct,
      requiresPayment: requiresPayment ?? this.requiresPayment,
      initialRequiresPayment:
          initialRequiresPayment ?? this.initialRequiresPayment,
      basePlanTitle: basePlanTitle ?? this.basePlanTitle,
      basePlanAmount: basePlanAmount ?? this.basePlanAmount,
      basePlanCurrency: basePlanCurrency ?? this.basePlanCurrency,
      basePlanId: identical(basePlanId, _unset)
          ? this.basePlanId
          : basePlanId as String?,
      selectedBoostTitle: identical(selectedBoostTitle, _unset)
          ? this.selectedBoostTitle
          : selectedBoostTitle as String?,
      selectedBoostAmount: identical(selectedBoostAmount, _unset)
          ? this.selectedBoostAmount
          : selectedBoostAmount as double?,
      selectedBoostId: identical(selectedBoostId, _unset)
          ? this.selectedBoostId
          : selectedBoostId as String?,
      selectedPlanTitle: selectedPlanTitle ?? this.selectedPlanTitle,
      selectedPlanAmount: selectedPlanAmount ?? this.selectedPlanAmount,
      selectedPlanCurrency: selectedPlanCurrency ?? this.selectedPlanCurrency,
      productTitle: productTitle ?? this.productTitle,
      productPrice: identical(productPrice, _unset)
          ? this.productPrice
          : productPrice as double?,
      photoPaths: photoPaths ?? this.photoPaths,
      networkPhotos: networkPhotos ?? this.networkPhotos,
      categoryName: identical(categoryName, _unset)
          ? this.categoryName
          : categoryName as String?,
      subCategoryName: identical(subCategoryName, _unset)
          ? this.subCategoryName
          : subCategoryName as String?,
      description: identical(description, _unset)
          ? this.description
          : description as String?,
      condition: identical(condition, _unset)
          ? this.condition
          : condition as String?,
      city: identical(city, _unset) ? this.city : city as String?,
      place: identical(place, _unset) ? this.place : place as String?,
      subCategoryId: identical(subCategoryId, _unset)
          ? this.subCategoryId
          : subCategoryId as String?,
      subCategoryAttributesSchema:
          subCategoryAttributesSchema ?? this.subCategoryAttributesSchema,
      dynamicAttributes: dynamicAttributes ?? this.dynamicAttributes,
      governorateId: identical(governorateId, _unset)
          ? this.governorateId
          : governorateId as String?,
      wilayatId: identical(wilayatId, _unset)
          ? this.wilayatId
          : wilayatId as String?,
      vatAmount: identical(vatAmount, _unset)
          ? this.vatAmount
          : vatAmount as double?,
      listingPricesStatus: listingPricesStatus ?? this.listingPricesStatus,
      listingPrices: listingPrices ?? this.listingPrices,
      listingQuotaStatus: identical(listingQuotaStatus, _unset)
          ? this.listingQuotaStatus
          : listingQuotaStatus as ListingQuotaStatusModel?,
      listingPricesError: identical(listingPricesError, _unset)
          ? this.listingPricesError
          : listingPricesError as String?,
      listingPricesForAccountType:
          identical(listingPricesForAccountType, _unset)
          ? this.listingPricesForAccountType
          : listingPricesForAccountType as ListingAccountType?,
      adPricesStatus: adPricesStatus ?? this.adPricesStatus,
      adPrices: adPrices ?? this.adPrices,
      adPricesError: identical(adPricesError, _unset)
          ? this.adPricesError
          : adPricesError as String?,
      useExistingQuota: useExistingQuota ?? this.useExistingQuota,
      adDurationDays: adDurationDays ?? this.adDurationDays,
      isPosting: isPosting ?? this.isPosting,
      postingError: identical(postingError, _unset)
          ? this.postingError
          : postingError as String?,
      postedListingId: identical(postedListingId, _unset)
          ? this.postedListingId
          : postedListingId as String?,
      postedProduct: identical(postedProduct, _unset)
          ? this.postedProduct
          : postedProduct as ProductModel?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    accountType,
    flowMode,
    editingProduct,
    requiresPayment,
    initialRequiresPayment,
    basePlanTitle,
    basePlanAmount,
    basePlanCurrency,
    basePlanId,
    selectedBoostTitle,
    selectedBoostAmount,
    selectedBoostId,
    selectedPlanTitle,
    selectedPlanAmount,
    selectedPlanCurrency,
    productTitle,
    productPrice,
    photoPaths,
    networkPhotos,
    categoryName,
    subCategoryName,
    description,
    condition,
    city,
    place,
    subCategoryId,
    subCategoryAttributesSchema,
    dynamicAttributes,
    governorateId,
    wilayatId,
    vatAmount,
    listingPricesStatus,
    listingPrices,
    listingQuotaStatus,
    listingPricesError,
    listingPricesForAccountType,
    adPricesStatus,
    adPrices,
    adPricesError,
    useExistingQuota,
    adDurationDays,
    isPosting,
    postingError,
    postedListingId,
    postedProduct,
  ];
}
