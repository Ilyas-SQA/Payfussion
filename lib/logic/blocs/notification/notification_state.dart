
import '../../../data/models/notification/notification_model.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationsLoaded(this.notifications, this.unreadCount);
}

class NotificationAdded extends NotificationState {
  final NotificationModel notification;

  NotificationAdded(this.notification);
}

class NotificationUpdated extends NotificationState {
  final String notificationId;

  NotificationUpdated(this.notificationId);
}

class NotificationDeleted extends NotificationState {
  final String notificationId;

  NotificationDeleted(this.notificationId);
}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

class NotificationSuccess extends NotificationState {
  final String message;

  NotificationSuccess(this.message);
}