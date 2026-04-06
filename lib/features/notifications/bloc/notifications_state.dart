import 'package:_96_sooq/features/notifications/model/notification_model.dart';
import 'package:equatable/equatable.dart';

enum NotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final String errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const <NotificationModel>[],
    this.unreadCount = 0,
    this.errorMessage = '',
  });

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationModel>? notifications,
    int? unreadCount,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, notifications, unreadCount, errorMessage];
}
