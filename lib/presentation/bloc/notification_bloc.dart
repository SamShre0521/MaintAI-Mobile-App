import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maintai/domain/repositories/notificationrepo.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc
    extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({
    required this.repository,
  }) : super(const NotificationState()) {
    on<LoadNotificationsEvent>(_onLoad);
    on<RefreshUnreadCountEvent>(_onRefreshCount);
    on<MarkNotificationReadEvent>(_onMarkRead);
    on<MarkAllNotificationsReadEvent>(_onMarkAllRead);
  }

  Future<void> _onLoad(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final notifications =
          await repository.getNotifications();
      final unreadCount =
          await repository.getUnreadCount();

      emit(
        state.copyWith(
          isLoading: false,
          notifications: notifications,
          unreadCount: unreadCount,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load notifications',
        ),
      );
    }
  }

  Future<void> _onRefreshCount(
    RefreshUnreadCountEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final count = await repository.getUnreadCount();
      emit(state.copyWith(unreadCount: count));
    } catch (_) {}
  }

  Future<void> _onMarkRead(
    MarkNotificationReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await repository.markAsRead(event.notificationId);
    add(LoadNotificationsEvent());
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await repository.markAllAsRead();
    add(LoadNotificationsEvent());
  }
}