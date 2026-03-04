class ListingPriceModel {
  const ListingPriceModel({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.isStore,
    required this.raw,
  });

  final String id;
  final String title;
  final double price;
  final String currency;
  final bool isStore;
  final Map<String, dynamic> raw;

  factory ListingPriceModel.fromJson(Map<String, dynamic> json) {
    final title =
        (json['title'] ??
                json['name'] ??
                json['plan_name'] ??
                json['label'] ??
                '')
            .toString();
    return ListingPriceModel(
      id: (json['id'] ?? json['uuid'] ?? '').toString(),
      title: title,
      price: _toDouble(json['price'] ?? json['amount'] ?? json['value']),
      currency: (json['currency'] ?? json['currency_code'] ?? 'OMR').toString(),
      isStore: _toBool(json['is_store']),
      raw: Map<String, dynamic>.from(json),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    final normalized = value?.toString().toLowerCase().trim();
    return normalized == 'true' || normalized == '1';
  }
}
