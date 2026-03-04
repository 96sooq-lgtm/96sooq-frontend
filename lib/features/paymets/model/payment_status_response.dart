enum PaymentStatusValue { pending, success, failed, unknown }

class PaymentStatusResponse {
  const PaymentStatusResponse({
    required this.status,
    required this.transactionId,
    this.message,
  });

  final PaymentStatusValue status;
  final String transactionId;
  final String? message;

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['status']?.toString().toLowerCase() ?? '';
    final statusValue = switch (raw) {
      'success' => PaymentStatusValue.success,
      'failed' || 'failure' => PaymentStatusValue.failed,
      'pending' => PaymentStatusValue.pending,
      _ => PaymentStatusValue.unknown,
    };
    return PaymentStatusResponse(
      status: statusValue,
      transactionId: json['transaction_id']?.toString() ?? '',
      message: json['message']?.toString(),
    );
  }

  bool get isSuccess => status == PaymentStatusValue.success;
  bool get isFailed =>
      status == PaymentStatusValue.failed ||
      status == PaymentStatusValue.unknown;
  bool get isPending => status == PaymentStatusValue.pending;
}
