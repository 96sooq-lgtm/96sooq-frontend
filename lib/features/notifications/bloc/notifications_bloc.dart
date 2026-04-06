import 'package:_96_sooq/features/notifications/data/notification_api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationApiService apiService;

  NotificationsBloc({required this.apiService})
      : super(const NotificationsState()) {
    on<NotificationsFetchRequested>(_onFetch);
    on<NotificationsUnreadCountRequested>(_onUnreadCount);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationsMarkAllReadRequested>(_onMarkAllRead);
  }

  Future<void> _onFetch(
    NotificationsFetchRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    try {
      final notifications = await apiService.fetchNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      emit(state.copyWith(
        status: NotificationsStatus.success,
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NOTIFICATIONS-BLOC] fetch_failed error=$e');
      }
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUnreadCount(
    NotificationsUnreadCountRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final count = await apiService.fetchUnreadCount();
      emit(state.copyWith(unreadCount: count));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NOTIFICATIONS-BLOC] unread_count_failed error=$e');
      }
    }
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await apiService.markNotificationRead(event.notificationId);
      // Update local state
      final updated = state.notifications.map((n) {
        if (n.id == event.notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      final unreadCount = updated.where((n) => !n.isRead).length;
      emit(state.copyWith(
        notifications: updated,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NOTIFICATIONS-BLOC] mark_read_failed error=$e');
      }
    }
  }

  Future<void> _onMarkAllRead(
    NotificationsMarkAllReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await apiService.markAllRead();
      // Update local state – mark all as read
      final updated = state.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      emit(state.copyWith(
        notifications: updated,
        unreadCount: 0,
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NOTIFICATIONS-BLOC] mark_all_read_failed error=$e');
      }
    }
  }
}
