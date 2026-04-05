class CategoryModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String imageUrl;
  final String? parentId;
  final List<CategoryAttributeSchemaModel> attributesSchema;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.imageUrl,
    required this.parentId,
    required this.attributesSchema,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] ?? '').toString(),
      nameEn: (json['name_en'] ?? '').toString(),
      nameAr: (json['name_ar'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      parentId: json['parent_id']?.toString(),
      attributesSchema: _parseAttributesSchema(json['attributes_schema']),
      isActive: json['is_active'] == true,
      createdAt: _tryParseDate(json['created_at']),
      updatedAt: _tryParseDate(json['updated_at']),
    );
  }

  String displayName(String localeCode) {
    if (localeCode.toLowerCase() == 'ar') {
      return nameAr.isNotEmpty ? nameAr : nameEn;
    }
    return nameEn.isNotEmpty ? nameEn : nameAr;
  }

  static List<CategoryAttributeSchemaModel> _parseAttributesSchema(
    dynamic value,
  ) {
    if (value is! List) return const <CategoryAttributeSchemaModel>[];
    return value
        .whereType<Map<String, dynamic>>()
        .map(CategoryAttributeSchemaModel.fromJson)
        .toList();
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}

class CategoryAttributeSchemaModel {
  final String name;
  final String type;
  final String labelEn;
  final String labelAr;
  final bool requiredField;
  final String? accept;
  final String? status;
  final List<String> options;
  final List<String> optionsAr;
  final bool multiple;

  const CategoryAttributeSchemaModel({
    required this.name,
    required this.type,
    required this.labelEn,
    required this.labelAr,
    required this.requiredField,
    required this.accept,
    required this.status,
    required this.options,
    required this.optionsAr,
    required this.multiple,
  });

  factory CategoryAttributeSchemaModel.fromJson(Map<String, dynamic> json) {
    return CategoryAttributeSchemaModel(
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      labelEn: (json['label_en'] ?? '').toString(),
      labelAr: (json['label_ar'] ?? '').toString(),
      requiredField: json['required'] == true,
      accept: json['accept']?.toString(),
      status: json['status']?.toString(),
      options: (json['options'] is List)
          ? (json['options'] as List)
                .map((item) => item.toString())
                .where((item) => item.trim().isNotEmpty)
                .toList()
          : const <String>[],
      optionsAr: (json['options_ar'] is List)
          ? (json['options_ar'] as List)
                .map((item) => item.toString())
                .where((item) => item.trim().isNotEmpty)
                .toList()
          : const <String>[],
      multiple: json['multiple'] == true,
    );
  }
}
