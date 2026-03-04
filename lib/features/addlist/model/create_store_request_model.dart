class CreateStoreRequestModel {
  const CreateStoreRequestModel({
    required this.nameEn,
    required this.nameAr,
    required this.description,
    required this.governorateId,
    required this.wilayatId,
    required this.logo,
    required this.storeNumber,
    this.planId,
  });

  final String nameEn;
  final String nameAr;
  final String description;
  final String governorateId;
  final String wilayatId;
  final String logo;
  final String storeNumber;
  final String? planId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name_en': nameEn,
      'name_ar': nameAr,
      'description': description,
      'governorate_id': governorateId,
      'wilayat_id': wilayatId,
      'logo': logo,
      'plan_id': planId,
      'store_number': storeNumber,
    };
  }
}
