part of 'payment_bloc.dart';

sealed class PaymentEvent {
  const PaymentEvent();
}

class PaymentCheckoutRequested extends PaymentEvent {
  const PaymentCheckoutRequested({
    this.listingPlanId,
    this.adPlanId,
    this.listingId,
    this.useExistingQuota = false,
    this.adDurationDays = 1,
    this.currency = 'OMR',
  });

  final String? listingPlanId;
  final String? adPlanId;
  final String? listingId;
  final bool useExistingQuota;
  final int adDurationDays;
  final String currency;
}

class PaymentStatusPolled extends PaymentEvent {
  const PaymentStatusPolled({required this.transactionId});

  final String transactionId;
}

class PaymentReset extends PaymentEvent {
  const PaymentReset();
}
