class ListingQuotaStatusModel {
  const ListingQuotaStatusModel({
    required this.canCreateFree,
    required this.canCreatePaid,
    required this.usage,
    required this.paidRemaining,
  });

  final bool canCreateFree;
  final bool canCreatePaid;
  final int usage;
  final int paidRemaining;

  factory ListingQuotaStatusModel.fromJson(Map<String, dynamic> json) {
    return ListingQuotaStatusModel(
      canCreateFree: _toBool(json['can_create_free']),
      canCreatePaid: _toBool(json['can_create_paid']),
      usage: _toInt(json['usage']),
      paidRemaining: _toInt(json['paid_remaining']),
    );
  }
}

class ListingPlanModel {
  const ListingPlanModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.adSubType,
    required this.type,
    required this.price,
    required this.durationDays,
    required this.description,
    required this.quota,
    required this.targetAudience,
    required this.isBestValue,
    required this.isActive,
    this.createdAt,
    required this.features,
    required this.raw,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final String? adSubType;
  final String type;
  final double price;
  final int durationDays;
  final String description;
  final int quota;
  final String targetAudience;
  final bool isBestValue;
  final bool isActive;
  final DateTime? createdAt;
  final Map<String, dynamic> features;
  final Map<String, dynamic> raw;

  factory ListingPlanModel.fromJson(Map<String, dynamic> json) {
    return ListingPlanModel(
      id: (json['id'] ?? '').toString(),
      nameEn: (json['name_en'] ?? '').toString(),
      nameAr: (json['name_ar'] ?? '').toString(),
      adSubType: json['ad_sub_type']?.toString(),
      type: (json['type'] ?? '').toString(),
      price: _toDouble(json['price']),
      durationDays: _toInt(json['duration_days']),
      description: (json['description'] ?? '').toString(),
      quota: _toInt(json['quota']),
      targetAudience: (json['target_audience'] ?? '').toString(),
      isBestValue: _toBool(json['is_best_value']),
      isActive: _toBool(json['is_active']),
      createdAt: _toDateTime(json['created_at']),
      features: json['features'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['features'] as Map<String, dynamic>)
          : const <String, dynamic>{},
      raw: Map<String, dynamic>.from(json),
    );
  }

  String displayName(String localeCode) {
    if (localeCode == 'ar' && nameAr.trim().isNotEmpty) return nameAr.trim();
    if (nameEn.trim().isNotEmpty) return nameEn.trim();
    if (nameAr.trim().isNotEmpty) return nameAr.trim();
    return 'Plan';
  }

  List<String> get featureLines {
    return description
        .split('\n')
        .map((line) => line.trim())
        .map((line) => line.replaceFirst(RegExp(r'^\d+[\).\-\s:]+'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
  }

  String get cleanDescription {
    return featureLines.join('\n');
  }
}

class ListingPricesResponseModel {
  const ListingPricesResponseModel({this.quotaStatus, required this.plans});

  final ListingQuotaStatusModel? quotaStatus;
  final List<ListingPlanModel> plans;

  factory ListingPricesResponseModel.fromJson(Map<String, dynamic> json) {
    final quotaRaw = json['quota_status'];
    final plansRaw = json['plans'];

    if (plansRaw is! List) {
      throw Exception('Unexpected listing prices response: plans is missing');
    }

    return ListingPricesResponseModel(
      quotaStatus: quotaRaw is Map<String, dynamic>
          ? ListingQuotaStatusModel.fromJson(quotaRaw)
          : quotaRaw is Map
          ? ListingQuotaStatusModel.fromJson(
              Map<String, dynamic>.from(quotaRaw),
            )
          : null,
      plans: plansRaw
          .whereType<Map>()
          .map(
            (item) =>
                ListingPlanModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  final normalized = value?.toString().toLowerCase().trim();
  return normalized == 'true' || normalized == '1';
}

DateTime? _toDateTime(dynamic value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}
