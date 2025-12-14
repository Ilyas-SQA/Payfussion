import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/notification/notification_model.dart';
import '../../../data/repositories/notification/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;
  StreamSubscription<List<NotificationModel>>? _notificationsSubscription;
  StreamSubscription<int>? _unreadCountSubscription;

  NotificationBloc(this._notificationRepository) : super(NotificationInitial()) {
    on<AddNotification>(_onAddNotification);
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadNotificationsByType>(_onLoadNotificationsByType);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<ClearAllNotifications>(_onClearAllNotifications);
    on<OpenNotificationScreen>(_onOpenNotificationScreen); // New event

    // Start listening to notifications immediately
    _startListeningToNotifications();
  }

  // Start listening to real-time notifications
  void _startListeningToNotifications() {
    try {
      _notificationsSubscription?.cancel();

      _notificationsSubscription = _notificationRepository.notificationsStream().listen(
            (List<NotificationModel> notifications) async {
          final int unreadCount = await _notificationRepository.getUnreadNotificationsCount();
          emit(NotificationsLoaded(notifications, unreadCount));
        },
        onError: (error) {
          emit(NotificationError(error.toString()));
        },
      );
    } catch (e) {
      emit(NotificationError('Failed to start listening to notifications: $e'));
    }
  }

  // Handle opening notification screen - auto mark all as read
  Future<void> _onOpenNotificationScreen(
      OpenNotificationScreen event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());
    try {
      // Load notifications first
      final List<NotificationModel> notifications = await _notificationRepository.getUserNotifications();

      // Check if there are any unread notifications
      final int unreadCount = await _notificationRepository.getUnreadNotificationsCount();

      if (unreadCount > 0) {
        // Mark all notifications as read
        await _notificationRepository.markAllNotificationsAsRead();

        // Get updated notifications with read status
        final List<NotificationModel> updatedNotifications = await _notificationRepository.getUserNotifications();
        emit(NotificationsLoaded(updatedNotifications, 0));
      } else {
        // No unread notifications, just emit loaded state
        emit(NotificationsLoaded(notifications, unreadCount));
      }
    } catch (e) {
      emit(NotificationError('Failed to open notification screen: $e'));
    }
  }

  // Add notification
  Future<void> _onAddNotification(
      AddNotification event,
      Emitter<NotificationState> emit,
      ) async {
    try {
      final NotificationModel notification = NotificationModel(
        title: event.title,
        message: event.message,
        type: event.type,
        data: event.data,
        createdAt: DateTime.now(),
      );

      final String notificationId = await _notificationRepository.addNotification(notification);

      final NotificationModel addedNotification = notification.copyWith(id: notificationId);
      emit(NotificationAdded(addedNotification));

      // The real-time listener will automatically update the state
    } catch (e) {
      emit(NotificationError('Failed to add notification: $e'));
    }
  }

  // Load notifications
  Future<void> _onLoadNotifications(
      LoadNotifications event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());
    try {
      final List<NotificationModel> notifications = await _notificationRepository.getUserNotifications();
      final int unreadCount = await _notificationRepository.getUnreadNotificationsCount();
      emit(NotificationsLoaded(notifications, unreadCount));
    } catch (e) {
      emit(NotificationError('Failed to load notifications: $e'));
    }
  }

  // Load notifications by type
  Future<void> _onLoadNotificationsByType(
      LoadNotificationsByType event,
      Emitter<NotificationState> emit,
      ) async {
    emit(NotificationLoading());
    try {
      final List<NotificationModel> notifications = await _notificationRepository.getNotificationsByType(event.type);
      final int unreadCount = await _notificationRepository.getUnreadNotificationsCount();
      emit(NotificationsLoaded(notifications, unreadCount));
    } catch (e) {
      emit(NotificationError('Failed to load notifications by type: $e'));
    }
  }

  // Mark notification as read
  Future<void> _onMarkNotificationAsRead(
      MarkNotificationAsRead event,
      Emitter<NotificationState> emit,
      ) async {
    try {
      await _notificationRepository.markNotificationAsRead(event.notificationId);
      emit(NotificationUpdated(event.notificationId));

      // The real-time listener will automatically update the state
    } catch (e) {
      emit(NotificationError('Failed to mark notification as read: $e'));
    }
  }

  // Mark all notifications as read
  Future<void> _onMarkAllNotificationsAsRead(
      MarkAllNotificationsAsRead event,
      Emitter<NotificationState> emit,
      ) async {
    try {
      // Get current notifications before marking as read
      final currentState = state;

      await _notificationRepository.markAllNotificationsAsRead();

      // If we have current notifications, emit them immediately with updated read status
      if (currentState is NotificationsLoaded) {
        // Update all notifications to read status
        final updatedNotifications = currentState.notifications.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();
        final int unreadCount = await _notificationRepository.getUnreadNotificationsCount();

        emit(NotificationsLoaded(updatedNotifications,unreadCount));
      }

      emit(NotificationSuccess('All notifications marked as read'));

      // Load fresh data from repository
      add(LoadNotifications());

    } catch (e) {
      emit(NotificationError('Failed to mark all notifications as read: $e'));
    }
  }

  // Delete notification
  Future<void> _onDeleteNotification(
      DeleteNotification event,
      Emitter<NotificationState> emit,
      ) async {
    try {
      await _notificationRepository.deleteNotification(event.notificationId);
      emit(NotificationDeleted(event.notificationId));

      // The real-time listener will automatically update the state
    } catch (e) {
      emit(NotificationError('Failed to delete notification: $e'));
    }
  }

  // Clear all notifications
  Future<void> _onClearAllNotifications(
      ClearAllNotifications event,
      Emitter<NotificationState> emit,
      ) async {
    try {
      await _notificationRepository.clearAllNotifications();
      emit(NotificationSuccess('All notifications cleared'));

      // The real-time listener will automatically update the state
    } catch (e) {
      emit(NotificationError('Failed to clear all notifications: $e'));
    }
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    return super.close();
  }
}