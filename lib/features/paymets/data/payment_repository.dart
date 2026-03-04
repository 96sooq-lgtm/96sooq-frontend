import 'dart:convert';
import 'dart:developer' as developer;

import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/paymets/model/payment_checkout_response.dart';
import 'package:_96_sooq/features/paymets/model/payment_status_response.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:dio/dio.dart';

class PaymentRepository {
  const PaymentRepository();

  /// Initiates checkout. Returns [PaymentCheckoutResponse] on success.
  Future<PaymentCheckoutResponse> initiateCheckout({
    String? listingPlanId,
    String? adPlanId,
    String? listingId,
    bool useExistingQuota = false,
    int adDurationDays = 1,
    String currency = 'OMR',
  }) async {
    try {
      final body = <String, dynamic>{
        'listing_plan_id': listingPlanId?.trim().isNotEmpty == true
            ? listingPlanId!.trim()
            : null,
        'use_existing_quota': useExistingQuota,
        'ad_duration_days': adDurationDays,
        'currency': currency,
      };
      if (listingId != null && listingId.trim().isNotEmpty) {
        body['listing_id'] = listingId.trim();
      }
      if (adPlanId != null && adPlanId.trim().isNotEmpty) {
        body['ad_plan_id'] = adPlanId.trim();
      }

      developer.log(
        '\n╔══════════════════════════════════════════════════════════════╗\n'
        '║ 🔴 CHECKOUT API REQUEST (PaymentRepository)                 ║\n'
        '╠══════════════════════════════════════════════════════════════╣\n'
        '║ URL  : ${ApiEndpoints.paymentCheckout}\n'
        '║ BODY :\n'
        '${const JsonEncoder.withIndent("  ").convert(body)}\n'
        '╚══════════════════════════════════════════════════════════════╝',
        name: 'PaymentAPI',
      );

      final response = await DioServices.client.post(
        ApiEndpoints.paymentCheckout,
        data: body,
      );

      final data = response.data;
      developer.log(
        '\n╔══════════════════════════════════════════════════════════════╗\n'
        '║ ✅ CHECKOUT API RESPONSE                                     ║\n'
        '╠══════════════════════════════════════════════════════════════╣\n'
        '║ statusCode : ${response.statusCode}\n'
        '║ data       :\n'
        '${data is Map ? const JsonEncoder.withIndent("  ").convert(data) : data}\n'
        '╚══════════════════════════════════════════════════════════════╝',
        name: 'PaymentAPI',
      );

      if (data is Map<String, dynamic>) {
        return PaymentCheckoutResponse.fromJson(data);
      }
      throw Exception('Invalid response format from checkout API');
    } on DioException catch (e) {
      developer.log(
        '\n╔══════════════════════════════════════════════════════════════╗\n'
        '║ ❌ CHECKOUT API ERROR                                        ║\n'
        '╠══════════════════════════════════════════════════════════════╣\n'
        '║ statusCode : ${e.response?.statusCode}\n'
        '║ data       : ${e.response?.data}\n'
        '╚══════════════════════════════════════════════════════════════╝',
        name: 'PaymentAPI',
      );
      throw Exception(_extractError(e));
    }
  }

  /// Polls the payment status for a given [transactionId].
  Future<PaymentStatusResponse> getPaymentStatus({
    required String transactionId,
  }) async {
    try {
      final response = await DioServices.client.get(
        ApiEndpoints.paymentStatus(transactionId),
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PaymentStatusResponse.fromJson(data);
      }
      throw Exception('Invalid response format from payment status API');
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  String _extractError(DioException e) {
    final statusCode = e.response?.statusCode?.toString() ?? 'unknown';
    final data = e.response?.data;
    String? message;
    if (data is Map<String, dynamic>) {
      for (final key in ['message', 'detail', 'error', 'error_description']) {
        final val = data[key]?.toString();
        if (val != null && val.isNotEmpty) {
          message = val;
          break;
        }
      }
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }
    return message != null
        ? 'Payment error ($statusCode): $message'
        : 'Payment request failed ($statusCode)';
  }
}
