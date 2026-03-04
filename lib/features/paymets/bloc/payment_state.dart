part of 'payment_bloc.dart';

sealed class PaymentState {
  const PaymentState();
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentCheckoutLoading extends PaymentState {
  const PaymentCheckoutLoading();
}

class PaymentCheckoutSuccess extends PaymentState {
  const PaymentCheckoutSuccess({
    required this.paymentUrl,
    required this.transactionId,
  });

  final String paymentUrl;
  final String transactionId;
}

class PaymentCheckoutFailure extends PaymentState {
  const PaymentCheckoutFailure({required this.message});

  final String message;
}

class PaymentStatusLoading extends PaymentState {
  const PaymentStatusLoading();
}

class PaymentStatusSuccess extends PaymentState {
  const PaymentStatusSuccess({required this.transactionId, this.message});

  final String transactionId;
  final String? message;
}

class PaymentStatusPending extends PaymentState {
  const PaymentStatusPending();
}

class PaymentStatusFailure extends PaymentState {
  const PaymentStatusFailure({required this.message});

  final String message;
}
