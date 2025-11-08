import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? data;

  const NotificationModel({
    this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.data,
  });

  // Create NotificationModel from Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'general',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      data: data['data'] != null ? Map<String, dynamic>.from(data['data']) : null,
    );
  }

  // Convert NotificationModel to Firestore format
  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'data': data,
    };
  }

  // Create a copy of NotificationModel with updated fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationModel &&
        other.id == id &&
        other.title == title &&
        other.message == message &&
        other.type == type &&
        other.isRead == isRead &&
        other.createdAt == createdAt &&
        other.readAt == readAt &&
        _mapEquals(other.data, data);
  }

  @override
  int get hashCode {
    return id.hashCode ^
    title.hashCode ^
    message.hashCode ^
    type.hashCode ^
    isRead.hashCode ^
    createdAt.hashCode ^
    readAt.hashCode ^
    data.hashCode;
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, message: $message, type: $type, isRead: $isRead, createdAt: $createdAt, readAt: $readAt, data: $data)';
  }

  // Helper method to compare maps
  bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    for (final String key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) {
        return false;
      }
    }

    return true;
  }

  // Static helper methods to create specific notification types
  static NotificationModel createTransactionNotification({
    required String recipientName,
    required double amount,
    required double fee,
    required double totalAmount,
    required String transactionId,
    required String status,
  }) {
    return NotificationModel(
      title: status == 'success' ? 'Payment Sent Successfully' : 'Payment Failed',
      message: status == 'success'
          ? 'You sent \$${amount.toStringAsFixed(2)} to $recipientName'
          : 'Your payment of \$${amount.toStringAsFixed(2)} to $recipientName failed',
      type: 'transaction',
      createdAt: DateTime.now(),
      data: <String, dynamic>{
        'transactionId': transactionId,
        'recipientName': recipientName,
        'amount': amount,
        'fee': fee,
        'totalAmount': totalAmount,
        'currency': 'USD',
        'transactionType': 'sent',
        'status': status,
      },
    );
  }

  static NotificationModel createBillPaymentNotification({
    required String companyName,
    required double amount,
    required String billId,
    required String status,
    String? errorMessage,
  }) {
    return NotificationModel(
      title: status == 'success' ? 'Bill Payment Successful' : 'Bill Payment Failed',
      message: status == 'success'
          ? 'Your $companyName bill payment of \$${amount.toStringAsFixed(2)} was successful'
          : 'Your $companyName bill payment of \$${amount.toStringAsFixed(2)} failed',
      type: status == 'success' ? 'bill_payment_success' : 'bill_payment_failed',
      createdAt: DateTime.now(),
      data: <String, dynamic>{
        'companyName': companyName,
        'amount': amount,
        'billId': billId,
        'currency': 'USD',
        'status': status,
        if (errorMessage != null) 'errorMessage': errorMessage,
      },
    );
  }

  static NotificationModel createTicketNotification({required String companyName, required String route, required DateTime travelDate, required String passengerName, required int numberOfPassengers, required double totalAmount, required String seatType, required String status, String? errorMessage,}) {
    final String passengerText = numberOfPassengers == 1
        ? 'passenger'
        : '$numberOfPassengers passengers';

    final String formattedDate = '${travelDate.day}/${travelDate.month}/${travelDate.year}';

    return NotificationModel(
      title: status == 'success'
          ? 'Bus Ticket Booked Successfully'
          : 'Bus Ticket Booking Failed',
      message: status == 'success'
          ? 'Your $companyName bus ticket for $passengerText on $formattedDate has been confirmed'
          : 'Your $companyName bus ticket booking for $passengerText on $formattedDate failed',
      type: 'ticket',
      createdAt: DateTime.now(),
      data: <String, dynamic>{
        'companyName': companyName,
        'route': route,
        'travelDate': travelDate.toIso8601String(),
        'passengerName': passengerName,
        'numberOfPassengers': numberOfPassengers,
        'totalAmount': totalAmount,
        'seatType': seatType,
        'currency': 'USD',
        'status': status,
        if (errorMessage != null) 'errorMessage': errorMessage,
      },
    );
  }

  static NotificationModel createTransferNotification({required String recipientName, required double amount, required String transferId, required String transferType, required String status,}) {
    return NotificationModel(
      title: transferType == 'sent'
          ? (status == 'success' ? 'Transfer Sent' : 'Transfer Failed')
          : 'Transfer Received',
      message: transferType == 'sent'
          ? 'You ${status == 'success' ? 'sent' : 'tried to send'} \$${amount.toStringAsFixed(2)} to $recipientName'
          : 'You received \$${amount.toStringAsFixed(2)} from $recipientName',
      type: 'transfer',
      createdAt: DateTime.now(),
      data: <String, dynamic>{
        'transferId': transferId,
        'recipientName': recipientName,
        'amount': amount,
        'currency': 'USD',
        'transferType': transferType,
        'status': status,
      },
    );
  }

  static NotificationModel createGeneralNotification({required String title, required String message, Map<String, dynamic>? data,}) {
    return NotificationModel(
      title: title,
      message: message,
      type: 'general',
      createdAt: DateTime.now(),
      data: data,
    );
  }

  static NotificationModel createRideNotification({
    required String driverName,
    required String serviceType,
    required String passengerName,
    required String pickupLocation,
    required String destination,
    required double estimatedFare,
    required String rideType,
    DateTime? scheduledDateTime,
    String? bookingId,
    required String status,
    String? errorMessage,
  }) {
    final String rideTypeText = rideType == 'Scheduled' ? 'scheduled' : 'immediate';
    final String timeText = scheduledDateTime != null
        ? ' for ${scheduledDateTime.day}/${scheduledDateTime.month}/${scheduledDateTime.year} at ${scheduledDateTime.hour.toString().padLeft(2, '0')}:${scheduledDateTime.minute.toString().padLeft(2, '0')}'
        : '';

    return NotificationModel(
      title: status == 'success'
          ? 'Ride Booked Successfully'
          : 'Ride Booking Failed',
      message: status == 'success'
          ? 'Your $rideTypeText $serviceType ride with $driverName has been confirmed$timeText'
          : 'Your $serviceType ride booking with $driverName failed',
      type: 'ride',
      createdAt: DateTime.now(),
      data: <String, dynamic>{
        'bookingId': bookingId,
        'driverName': driverName,
        'serviceType': serviceType,
        'passengerName': passengerName,
        'pickupLocation': pickupLocation,
        'destination': destination,
        'estimatedFare': estimatedFare,
        'rideType': rideType,
        'scheduledDateTime': scheduledDateTime?.toIso8601String(),
        'currency': 'USD',
        'status': status,
        if (errorMessage != null) 'errorMessage': errorMessage,
      },
    );
  }

  static NotificationModel createFlightNotification({
    required String airline,
    required String flightNumber,
    required String passengerName,
    required String departureAirport,
    required String arrivalAirport,
    required DateTime travelDate,
    required int numberOfPassengers,
    required double totalAmount,
    required String travelClass,
    String? bookingId,
    required String status,
    String? errorMessage,
  }) {
    final String passengerText = numberOfPassengers == 1
        ? 'passenger'
        : '$numberOfPassengers passengers';

    final String formattedDate = '${travelDate.day}/${travelDate.month}/${travelDate.year}';
    final String route = '$departureAirport → $arrivalAirport';

    return NotificationModel(
      title: status == 'success'
          ? 'Flight Ticket Booked Successfully'
          : 'Flight Ticket Booking Failed',
      message: status == 'success'
          ? 'Your $airline flight $flightNumber for $passengerText on $formattedDate has been confirmed'
          : 'Your $airline flight $flightNumber booking for $passengerText on $formattedDate failed',
      type: 'flight',
      createdAt: DateTime.now(),
      data: <String, dynamic>{
        'bookingId': bookingId,
        'airline': airline,
        'flightNumber': flightNumber,
        'passengerName': passengerName,
        'departureAirport': departureAirport,
        'arrivalAirport': arrivalAirport,
        'route': route,
        'travelDate': travelDate.toIso8601String(),
        'numberOfPassengers': numberOfPassengers,
        'totalAmount': totalAmount,
        'travelClass': travelClass,
        'currency': 'USD',
        'status': status,
        if (errorMessage != null) 'errorMessage': errorMessage,
      },
    );
  }
}