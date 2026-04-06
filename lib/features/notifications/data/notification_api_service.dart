import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/notifications/model/notification_model.dart';
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

  Future<List<NotificationModel>> fetchNotifications() async {
    final response = await DioServices.client.get(
      ApiEndpoints.notifications,
    );

    final data = response.data;
    List? items;
    if (data is Map<String, dynamic> && data.containsKey('notifications')) {
      items = data['notifications'] as List?;
    } else if (data is List) {
      items = data;
    }
    if (items != null) {
      return items
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<int> fetchUnreadCount() async {
    final response = await DioServices.client.get(
      ApiEndpoints.notificationsUnreadCount,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['unread_count'] as int? ?? data['count'] as int? ?? 0;
    }
    if (data is int) return data;
    return 0;
  }

  Future<void> markNotificationRead(String notificationId) async {
    await DioServices.client.get(
      ApiEndpoints.notificationMarkRead(notificationId),
    );
  }

  Future<void> markAllRead() async {
    await DioServices.client.post(
      ApiEndpoints.notificationsMarkAllRead,
    );
  }
}

