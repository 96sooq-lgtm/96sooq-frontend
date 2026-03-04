import 'dart:developer' as developer;

import 'package:_96_sooq/features/paymets/data/payment_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({PaymentRepository? repository})
    : _repository = repository ?? const PaymentRepository(),
      super(const PaymentInitial()) {
    on<PaymentCheckoutRequested>(_onCheckoutRequested);
    on<PaymentStatusPolled>(_onStatusPolled);
    on<PaymentReset>(_onReset);
  }

  final PaymentRepository _repository;

  Future<void> _onCheckoutRequested(
    PaymentCheckoutRequested event,
    Emitter<PaymentState> emit,
  ) async {
    // Guard: prevent duplicate submissions
    if (state is PaymentCheckoutLoading) return;

    developer.log(
      '\n╔══════════════════════════════════════════════════════════════╗\n'
      '║ 🟡 PAYMENT CHECKOUT REQUESTED (PaymentBloc)                 ║\n'
      '╠══════════════════════════════════════════════════════════════╣\n'
      '║ listingPlanId     : ${event.listingPlanId}\n'
      '║ adPlanId          : ${event.adPlanId}\n'
      '║ listingId         : ${event.listingId}\n'
      '║ useExistingQuota  : ${event.useExistingQuota}\n'
      '║ adDurationDays    : ${event.adDurationDays}\n'
      '║ currency          : ${event.currency}\n'
      '╚══════════════════════════════════════════════════════════════╝',
      name: 'PaymentBloc',
    );

    emit(const PaymentCheckoutLoading());
    try {
      final response = await _repository.initiateCheckout(
        listingPlanId: event.listingPlanId,
        adPlanId: event.adPlanId,
        listingId: event.listingId,
        useExistingQuota: event.useExistingQuota,
        adDurationDays: event.adDurationDays,
        currency: event.currency,
      );

      if (response.isInitiated &&
          response.paymentUrl.isNotEmpty &&
          response.transactionId.isNotEmpty) {
        emit(
          PaymentCheckoutSuccess(
            paymentUrl: response.paymentUrl,
            transactionId: response.transactionId,
          ),
        );
      } else {
        emit(
          PaymentCheckoutFailure(
            message: response.message ?? 'Checkout could not be initiated.',
          ),
        );
      }
    } catch (e) {
      emit(PaymentCheckoutFailure(message: e.toString()));
    }
  }

  Future<void> _onStatusPolled(
    PaymentStatusPolled event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentStatusLoading());
    try {
      final response = await _repository.getPaymentStatus(
        transactionId: event.transactionId,
      );

      if (response.isSuccess) {
        emit(
          PaymentStatusSuccess(
            transactionId: response.transactionId,
            message: response.message,
          ),
        );
      } else if (response.isPending) {
        // Still let the UI know it's pending so it can show a retry or wait
        emit(const PaymentStatusPending());
      } else {
        emit(
          PaymentStatusFailure(
            message: response.message ?? 'Payment was not successful.',
          ),
        );
      }
    } catch (e) {
      emit(PaymentStatusFailure(message: e.toString()));
    }
  }

  void _onReset(PaymentReset event, Emitter<PaymentState> emit) {
    emit(const PaymentInitial());
  }
}
