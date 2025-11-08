import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // Initialize notification service
  static Future<void> initialize() async {
    // Request notification permission
    await _requestPermissions();

    // Initialize local notifications
    await _initializeLocalNotifications();
  }

  // Request notification permissions
  static Future<void> _requestPermissions() async {
    // Request notification permission for Android 13+
    await Permission.notification.request();
  }

  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    // Android settings
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS settings
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize with callback
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Yahan aap navigation handle kar sakte hain
  }

  // Show transaction notification
  static Future<void> showTransactionNotification({
    required String transactionType,
    required double amount,
    required String currency,
  }) async {
    final String title = getTransactionTitle(transactionType);
    final String body = 'Amount: $currency ${amount.toStringAsFixed(2)}';

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'transaction_channel',
      'Transaction Notifications',
      channelDescription: 'Notifications for transactions',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/launcher_icon',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Generate unique notification ID
    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _localNotifications.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: '$transactionType|$amount|$currency',
    );
  }

  // Get transaction title based on type
  static String getTransactionTitle(String type) {
    switch (type.toLowerCase()) {
      case 'sent':
        return 'Money Sent';
      case 'received':
        return 'Money Received';
      case 'deposit':
        return 'Deposit Successful';
      case 'withdrawal':
        return 'Withdrawal Complete';
      default:
        return 'Transaction Complete';
    }
  }

  // Show custom notification
  static Future<void> showCustomNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'custom_channel',
      'Custom Notifications',
      channelDescription: 'Custom app notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _localNotifications.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}