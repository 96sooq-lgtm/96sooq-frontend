class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final String? paymobTransactionId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    this.paymobTransactionId,
    this.metadata,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'OMR',
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? 'card',
      paymobTransactionId: json['paymob_transaction_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Determines the transaction label e.g. "Post Listing Payment", "Top Offer Price"
  String get displayLabel {
    if (metadata != null) {
      if (metadata!['ad_plan_id'] != null &&
          metadata!['listing_plan_id'] != null) {
        return 'Post Listing + Ad';
      }
      if (metadata!['ad_plan_id'] != null) {
        return 'Top Offer Price';
      }
      if (metadata!['listing_plan_id'] != null) {
        return 'Post Listing Payment';
      }
    }
    return 'Payment';
  }

  bool get isSuccess => status.toLowerCase() == 'success';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isFailed =>
      status.toLowerCase() == 'failed' || status.toLowerCase() == 'cancelled';
}
