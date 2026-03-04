class LocationItemModel {
  const LocationItemModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.type,
    required this.parentId,
    required this.isActive,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String type;
  final String? parentId;
  final bool isActive;

  factory LocationItemModel.fromJson(Map<String, dynamic> json) {
    return LocationItemModel(
      id: (json['id'] ?? '').toString(),
      nameEn: (json['name_en'] ?? '').toString(),
      nameAr: (json['name_ar'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      parentId: json['parent_id']?.toString(),
      isActive: json['is_active'] == true,
    );
  }

  String displayName(String languageCode) {
    if (languageCode == 'ar') {
      return nameAr.isNotEmpty ? nameAr : nameEn;
    }
    return nameEn.isNotEmpty ? nameEn : nameAr;
  }
}
