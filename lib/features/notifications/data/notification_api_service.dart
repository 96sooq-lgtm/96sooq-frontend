import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/shared/dio_services.dart';

class NotificationApiService {
  const NotificationApiService();

  Future<void> registerToken({required String fcmToken}) async {
    final token = fcmToken.trim();
    if (token.isEmpty) return;

    await DioServices.client.post(
      ApiEndpoints.registerNotificationToken,
      data: <String, dynamic>{'fcm_token': token},
    );
  }

  Future<void> unregisterToken({required String fcmToken}) async {
    final token = fcmToken.trim();
    if (token.isEmpty) return;

    await DioServices.client.delete(
      ApiEndpoints.unregisterNotificationToken,
      data: <String, dynamic>{'fcm_token': token},
    );
  }
}
