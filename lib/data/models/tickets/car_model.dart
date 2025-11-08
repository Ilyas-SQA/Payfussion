import 'package:cloud_firestore/cloud_firestore.dart';

class RideModel {
  final String id;
  final String driverName;
  final String serviceType; // Uber, Lyft, Taxi, Limousine, Shuttle
  final String carMake;
  final String carModel;
  final int carYear;
  final String carColor;
  final String licensePlate;
  final String phoneNumber;
  final double rating;
  final int totalRides;
  final double baseRate; // per mile
  final List<String> languages;
  final List<String> serviceAreas;
  final List<String> specialServices;
  final bool isAvailable;

  RideModel({
    required this.id,
    required this.driverName,
    required this.serviceType,
    required this.carMake,
    required this.carModel,
    required this.carYear,
    required this.carColor,
    required this.licensePlate,
    required this.phoneNumber,
    required this.rating,
    required this.totalRides,
    required this.baseRate,
    required this.languages,
    required this.serviceAreas,
    this.specialServices = const <String>[],
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'driverName': driverName,
      'serviceType': serviceType,
      'carMake': carMake,
      'carModel': carModel,
      'carYear': carYear,
      'carColor': carColor,
      'licensePlate': licensePlate,
      'phoneNumber': phoneNumber,
      'rating': rating,
      'totalRides': totalRides,
      'baseRate': baseRate,
      'languages': languages,
      'serviceAreas': serviceAreas,
      'specialServices': specialServices,
      'isAvailable': isAvailable,
    };
  }

  factory RideModel.fromMap(Map<String, dynamic> map) {
    return RideModel(
      id: map['id'] ?? '',
      driverName: map['driverName'] ?? '',
      serviceType: map['serviceType'] ?? '',
      carMake: map['carMake'] ?? '',
      carModel: map['carModel'] ?? '',
      carYear: map['carYear'] ?? 0,
      carColor: map['carColor'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRides: map['totalRides'] ?? 0,
      baseRate: (map['baseRate'] ?? 0.0).toDouble(),
      languages: List<String>.from(map['languages'] ?? <dynamic>[]),
      serviceAreas: List<String>.from(map['serviceAreas'] ?? <dynamic>[]),
      specialServices: List<String>.from(map['specialServices'] ?? <dynamic>[]),
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}

// ride_booking_model.dart
// Updated RideBookingModel with tax-related fields
class RideBookingModel {
  final String id;
  final String rideId;
  final String driverName;
  final String serviceType;
  final String passengerName;
  final String passengerPhone;
  final String pickupLocation;
  final String destination;
  final double estimatedDistance;
  final double estimatedFare;
  final double baseFare;
  final double schedulingFee;
  final double taxAmount;
  final String rideType; // Now, Scheduled
  final DateTime scheduledDateTime;
  final String specialInstructions;
  final String paymentStatus;
  final DateTime bookingDate;
  final String status; // confirmed, in_progress, completed, cancelled

  RideBookingModel({
    required this.id,
    required this.rideId,
    required this.driverName,
    required this.serviceType,
    required this.passengerName,
    required this.passengerPhone,
    required this.pickupLocation,
    required this.destination,
    required this.estimatedDistance,
    required this.estimatedFare,
    required this.baseFare,
    required this.schedulingFee,
    required this.taxAmount,
    required this.rideType,
    required this.scheduledDateTime,
    this.specialInstructions = '',
    required this.paymentStatus,
    required this.bookingDate,
    this.status = 'confirmed',
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'rideId': rideId,
      'driverName': driverName,
      'serviceType': serviceType,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'pickupLocation': pickupLocation,
      'destination': destination,
      'estimatedDistance': estimatedDistance,
      'estimatedFare': estimatedFare,
      'baseFare': baseFare,
      'schedulingFee': schedulingFee,
      'taxAmount': taxAmount,
      'rideType': rideType,
      'scheduledDateTime': Timestamp.fromDate(scheduledDateTime),
      'specialInstructions': specialInstructions,
      'paymentStatus': paymentStatus,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'status': status,
    };
  }

  factory RideBookingModel.fromMap(Map<String, dynamic> map) {
    return RideBookingModel(
      id: map['id'] ?? '',
      rideId: map['rideId'] ?? '',
      driverName: map['driverName'] ?? '',
      serviceType: map['serviceType'] ?? '',
      passengerName: map['passengerName'] ?? '',
      passengerPhone: map['passengerPhone'] ?? '',
      pickupLocation: map['pickupLocation'] ?? '',
      destination: map['destination'] ?? '',
      estimatedDistance: (map['estimatedDistance'] ?? 0.0).toDouble(),
      estimatedFare: (map['estimatedFare'] ?? 0.0).toDouble(),
      baseFare: (map['baseFare'] ?? 0.0).toDouble(),
      schedulingFee: (map['schedulingFee'] ?? 0.0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0.0).toDouble(),
      rideType: map['rideType'] ?? 'Now',
      scheduledDateTime: (map['scheduledDateTime'] as Timestamp).toDate(),
      specialInstructions: map['specialInstructions'] ?? '',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'confirmed',
    );
  }
}


// US Ride Services Data
List<RideModel> usRideServices = <RideModel>[
  // Uber Drivers
  RideModel(
    id: 'uber_001',
    driverName: 'Michael Rodriguez',
    serviceType: 'Uber',
    carMake: 'Toyota',
    carModel: 'Camry',
    carYear: 2022,
    carColor: 'Silver',
    licensePlate: 'UBR-1234',
    phoneNumber: '+1-555-0101',
    rating: 4.9,
    totalRides: 2847,
    baseRate: 1.25,
    languages: <String>['English', 'Spanish'],
    serviceAreas: <String>['Manhattan', 'Brooklyn', 'Queens', 'Bronx'],
    specialServices: <String>['Child Car Seat Available', 'Pet Friendly', 'Airport Pickup'],
    isAvailable: true,
  ),

  RideModel(
    id: 'uber_002',
    driverName: 'Sarah Johnson',
    serviceType: 'Uber',
    carMake: 'Honda',
    carModel: 'Accord',
    carYear: 2021,
    carColor: 'Black',
    licensePlate: 'UBR-5678',
    phoneNumber: '+1-555-0102',
    rating: 4.8,
    totalRides: 1956,
    baseRate: 1.30,
    languages: <String>['English'],
    serviceAreas: <String>['Los Angeles', 'Santa Monica', 'Beverly Hills', 'Hollywood'],
    specialServices: <String>['Quiet Ride', 'Phone Charger', 'Bottled Water'],
    isAvailable: true,
  ),

  // Lyft Drivers
  RideModel(
    id: 'lyft_001',
    driverName: 'David Chen',
    serviceType: 'Lyft',
    carMake: 'Nissan',
    carModel: 'Altima',
    carYear: 2023,
    carColor: 'White',
    licensePlate: 'LFT-9012',
    phoneNumber: '+1-555-0201',
    rating: 4.7,
    totalRides: 1456,
    baseRate: 0.95,
    languages: <String>['English'],
    serviceAreas: <String>['Denver', 'Denver Airport', 'Boulder', 'Colorado Springs'],
    specialServices: <String>['Airport Specialist', 'Ski Resort Transport', 'Mountain Weather Expert', 'Large Luggage'],
    isAvailable: true,
  ),
];