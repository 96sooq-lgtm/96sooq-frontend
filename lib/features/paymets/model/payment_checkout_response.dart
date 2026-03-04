class PaymentCheckoutResponse {
  const PaymentCheckoutResponse({
    required this.status,
    required this.transactionId,
    required this.paymentUrl,
    this.message,
  });

  final String status;
  final String transactionId;
  final String paymentUrl;
  final String? message;

  factory PaymentCheckoutResponse.fromJson(Map<String, dynamic> json) {
    return PaymentCheckoutResponse(
      status: json['status']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
      paymentUrl: json['payment_url']?.toString() ?? '',
      message: json['message']?.toString(),
    );
  }

  bool get isInitiated => status == 'payment_initiated';
}
