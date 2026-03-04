import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/location/model/location_item_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:dio/dio.dart';

class LocationApiService {
  const LocationApiService();

  Future<List<LocationItemModel>> fetchStates() async {
    try {
      final response = await DioServices.client.get(
        ApiEndpoints.locationsByStateType,
      );
      return _parseLocationItems(response);
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('governorates', e));
    }
  }

  Future<List<LocationItemModel>> fetchCities({required String stateId}) async {
    try {
      final response = await DioServices.client.get(
        ApiEndpoints.locationsByCityType(stateId),
      );
      return _parseLocationItems(response);
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('cities', e));
    }
  }

  List<LocationItemModel> _parseLocationItems(Response<dynamic> response) {
    final data = response.data;
    if (data is! List) {
      throw Exception('Unexpected locations response');
    }

    return data
        .map((item) => LocationItemModel.fromJson(item as Map<String, dynamic>))
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  String _buildDioErrorMessage(String resourceName, DioException e) {
    final statusCode = e.response?.statusCode?.toString() ?? 'unknown';
    final message = _extractApiErrorMessage(e.response?.data);
    if (message != null && message.isNotEmpty) {
      return 'Failed to load $resourceName ($statusCode): $message';
    }
    return 'Failed to load $resourceName ($statusCode)';
  }

  String? _extractApiErrorMessage(dynamic data) {
    if (data is String) return data;
    if (data is Map<String, dynamic>) {
      const keys = ['message', 'detail', 'error', 'error_description'];
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
