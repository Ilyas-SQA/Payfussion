import 'package:cloud_firestore/cloud_firestore.dart';

class TrainModel {
  final String id;
  final String name;
  final String route;
  final String via;
  final Duration duration;
  final double approxCostUSD;
  final String description;
  final List<String> amenities;

  TrainModel({
    required this.id,
    required this.name,
    required this.route,
    this.via = '',
    required this.duration,
    required this.approxCostUSD,
    this.description = '',
    this.amenities = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'route': route,
      'via': via,
      'durationHours': duration.inHours,
      'durationMinutes': duration.inMinutes % 60,
      'approxCostUSD': approxCostUSD,
      'description': description,
      'amenities': amenities,
    };
  }

  factory TrainModel.fromMap(Map<String, dynamic> map) {
    return TrainModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      route: map['route'] ?? '',
      via: map['via'] ?? '',
      duration: Duration(
        hours: map['durationHours'] ?? 0,
        minutes: map['durationMinutes'] ?? 0,
      ),
      approxCostUSD: (map['approxCostUSD'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      amenities: List<String>.from(map['amenities'] ?? []),
    );
  }
}

class BookingModel {
  final String id;
  final String trainId;
  final String trainName;
  final String passengerName;
  final String email;
  final String phone;
  final DateTime travelDate;
  final int numberOfPassengers;
  final double totalAmount;
  final double baseFare;
  final double classUpgradeAmount;
  final double taxAmount;
  final String travelClass;
  final String paymentStatus;
  final DateTime bookingDate;

  BookingModel({
    required this.id,
    required this.trainId,
    required this.trainName,
    required this.passengerName,
    required this.email,
    required this.phone,
    required this.travelDate,
    required this.numberOfPassengers,
    required this.totalAmount,
    required this.baseFare,
    required this.classUpgradeAmount,
    required this.taxAmount,
    required this.travelClass,
    required this.paymentStatus,
    required this.bookingDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainId': trainId,
      'trainName': trainName,
      'passengerName': passengerName,
      'email': email,
      'phone': phone,
      'travelDate': Timestamp.fromDate(travelDate),
      'numberOfPassengers': numberOfPassengers,
      'totalAmount': totalAmount,
      'baseFare': baseFare,
      'classUpgradeAmount': classUpgradeAmount,
      'taxAmount': taxAmount,
      'travelClass': travelClass,
      'paymentStatus': paymentStatus,
      'bookingDate': Timestamp.fromDate(bookingDate),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      trainId: map['trainId'] ?? '',
      trainName: map['trainName'] ?? '',
      passengerName: map['passengerName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      travelDate: (map['travelDate'] as Timestamp).toDate(),
      numberOfPassengers: map['numberOfPassengers'] ?? 1,
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      baseFare: (map['baseFare'] ?? 0.0).toDouble(),
      classUpgradeAmount: (map['classUpgradeAmount'] ?? 0.0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0.0).toDouble(),
      travelClass: map['travelClass'] ?? 'Economy',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
    );
  }
}