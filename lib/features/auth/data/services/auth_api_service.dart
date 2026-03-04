import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/auth/data/models/check_user_request_model.dart';
import 'package:_96_sooq/features/auth/data/models/check_user_response_model.dart';
import 'package:_96_sooq/features/auth/data/models/complete_profile_request_model.dart';
import 'package:_96_sooq/features/auth/data/models/complete_profile_response_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:dio/dio.dart';

class AuthApiService {
  const AuthApiService();

  Future<CheckUserResponse> checkUser(CheckUserRequest request) async {
    try {
      final response = await DioServices.client.post(
        ApiEndpoints.checkUser,
        data: request.toJson(),
      );
      return _parseCheckUserResponse(response);
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('check user', e));
    }
  }

  Future<CompleteProfileResponse> completeProfile(
    CompleteProfileRequest request,
  ) async {
    try {
      final response = await DioServices.client.post(
        ApiEndpoints.createAccount,
        data: request.toJson(),
      );
      return _parseCompleteProfileResponse(response);
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('create account', e));
    }
  }

  CheckUserResponse _parseCheckUserResponse(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected check user response');
    }
    return CheckUserResponse.fromJson(data);
  }

  CompleteProfileResponse _parseCompleteProfileResponse(
    Response<dynamic> response,
  ) {
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected create account response');
    }
    return CompleteProfileResponse.fromJson(data);
  }

  String _buildDioErrorMessage(String resourceName, DioException e) {
    final statusCode = e.response?.statusCode?.toString() ?? 'unknown';
    final message = _extractApiErrorMessage(e.response?.data);
    if (message != null && message.isNotEmpty) {
      return 'Failed to $resourceName ($statusCode): $message';
    }
    return 'Failed to $resourceName ($statusCode)';
  }

  String? _extractApiErrorMessage(dynamic data) {
    if (data is String) return data;
    if (data is Map<String, dynamic>) {
      const keys = <String>['message', 'detail', 'error', 'error_description'];
      for (final key in keys) {
        final value = data[key];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }
    }
    return null;
  }
}
