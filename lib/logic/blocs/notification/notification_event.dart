abstract class NotificationEvent {}

class AddNotification extends NotificationEvent {
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;

  AddNotification({
    required this.title,
    required this.message,
    required this.type,
    this.data,
  });
}

class LoadNotifications extends NotificationEvent {}

class LoadNotificationsByType extends NotificationEvent {
  final String type;

  LoadNotificationsByType(this.type);
}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  MarkNotificationAsRead(this.notificationId);
}

class MarkAllNotificationsAsRead extends NotificationEvent {}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  DeleteNotification(this.notificationId);
}

class ClearAllNotifications extends NotificationEvent {}

// New event for when notification screen is opened
class OpenNotificationScreen extends NotificationEvent {}