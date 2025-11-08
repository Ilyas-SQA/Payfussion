import 'package:cloud_firestore/cloud_firestore.dart';

class FlightModel {
  final String id;
  final String airline;
  final String flightNumber;
  final String aircraft;
  final String departureAirport;
  final String arrivalAirport;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final double basePrice;
  final String flightType; // Domestic, International, Regional
  final int totalSeats;
  final int stops;
  final List<String> amenities;

  FlightModel({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.aircraft,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.basePrice,
    required this.flightType,
    required this.totalSeats,
    this.stops = 0,
    this.amenities = const <String>[],
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'airline': airline,
      'flightNumber': flightNumber,
      'aircraft': aircraft,
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'basePrice': basePrice,
      'flightType': flightType,
      'totalSeats': totalSeats,
      'stops': stops,
      'amenities': amenities,
    };
  }

  factory FlightModel.fromMap(Map<String, dynamic> map) {
    return FlightModel(
      id: map['id'] ?? '',
      airline: map['airline'] ?? '',
      flightNumber: map['flightNumber'] ?? '',
      aircraft: map['aircraft'] ?? '',
      departureAirport: map['departureAirport'] ?? '',
      arrivalAirport: map['arrivalAirport'] ?? '',
      departureTime: map['departureTime'] ?? '',
      arrivalTime: map['arrivalTime'] ?? '',
      duration: map['duration'] ?? '',
      basePrice: (map['basePrice'] ?? 0.0).toDouble(),
      flightType: map['flightType'] ?? '',
      totalSeats: map['totalSeats'] ?? 0,
      stops: map['stops'] ?? 0,
      amenities: List<String>.from(map['amenities'] ?? <dynamic>[]),
    );
  }
}

// flight_booking_model.dart
// Updated FlightBookingModel with tax-related fields
class FlightBookingModel {
  final String id;
  final String flightId;
  final String airline;
  final String flightNumber;
  final String passengerName;
  final String email;
  final String phone;
  final DateTime travelDate;
  final int numberOfPassengers;
  final double totalAmount;
  final double baseFare;
  final double classUpgradeAmount;
  final double taxAmount;
  final String paymentStatus;
  final DateTime bookingDate;
  final String travelClass;
  final String departureAirport;
  final String arrivalAirport;
  final String departureTime;
  final String arrivalTime;

  FlightBookingModel({
    required this.id,
    required this.flightId,
    required this.airline,
    required this.flightNumber,
    required this.passengerName,
    required this.email,
    required this.phone,
    required this.travelDate,
    required this.numberOfPassengers,
    required this.totalAmount,
    required this.baseFare,
    required this.classUpgradeAmount,
    required this.taxAmount,
    required this.paymentStatus,
    required this.bookingDate,
    required this.travelClass,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'flightId': flightId,
      'airline': airline,
      'flightNumber': flightNumber,
      'passengerName': passengerName,
      'email': email,
      'phone': phone,
      'travelDate': Timestamp.fromDate(travelDate),
      'numberOfPassengers': numberOfPassengers,
      'totalAmount': totalAmount,
      'baseFare': baseFare,
      'classUpgradeAmount': classUpgradeAmount,
      'taxAmount': taxAmount,
      'paymentStatus': paymentStatus,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'travelClass': travelClass,
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
    };
  }

  factory FlightBookingModel.fromMap(Map<String, dynamic> map) {
    return FlightBookingModel(
      id: map['id'] ?? '',
      flightId: map['flightId'] ?? '',
      airline: map['airline'] ?? '',
      flightNumber: map['flightNumber'] ?? '',
      passengerName: map['passengerName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      travelDate: (map['travelDate'] as Timestamp).toDate(),
      numberOfPassengers: map['numberOfPassengers'] ?? 1,
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      baseFare: (map['baseFare'] ?? 0.0).toDouble(),
      classUpgradeAmount: (map['classUpgradeAmount'] ?? 0.0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0.0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? 'pending',
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      travelClass: map['travelClass'] ?? 'Economy',
      departureAirport: map['departureAirport'] ?? '',
      arrivalAirport: map['arrivalAirport'] ?? '',
      departureTime: map['departureTime'] ?? '',
      arrivalTime: map['arrivalTime'] ?? '',
    );
  }
}

// US Airlines Flight Data
List<FlightModel> usFlightServices = <FlightModel>[
  // American Airlines
  FlightModel(
    id: 'aa_001',
    airline: 'American Airlines',
    flightNumber: 'AA 1234',
    aircraft: 'Boeing 737-800',
    departureAirport: 'JFK (New York)',
    arrivalAirport: 'LAX (Los Angeles)',
    departureTime: '08:00 AM',
    arrivalTime: '11:30 AM',
    duration: '6h 30m',
    basePrice: 320.0,
    flightType: 'Domestic',
    totalSeats: 160,
    stops: 0,
    amenities: <String>['In-flight Entertainment', 'WiFi', 'Food Service', 'Power Outlets'],
  ),

  FlightModel(
    id: 'aa_002',
    airline: 'American Airlines',
    flightNumber: 'AA 5678',
    aircraft: 'Boeing 787-9',
    departureAirport: 'MIA (Miami)',
    arrivalAirport: 'LHR (London)',
    departureTime: '10:45 PM',
    arrivalTime: '12:30 PM+1',
    duration: '8h 45m',
    basePrice: 650.0,
    flightType: 'International',
    totalSeats: 285,
    stops: 0,
    amenities: <String>['Lie-flat Seats', 'Premium Entertainment', 'WiFi', 'Full Meal Service'],
  ),

  // Delta Air Lines
  FlightModel(
    id: 'dl_001',
    airline: 'Delta Air Lines',
    flightNumber: 'DL 2567',
    aircraft: 'Airbus A320',
    departureAirport: 'ATL (Atlanta)',
    arrivalAirport: 'SEA (Seattle)',
    departureTime: '06:15 AM',
    arrivalTime: '08:45 AM',
    duration: '5h 30m',
    basePrice: 280.0,
    flightType: 'Domestic',
    totalSeats: 150,
    stops: 0,
    amenities: <String>['In-flight Entertainment', 'WiFi', 'Snacks', 'Power Outlets'],
  ),

  FlightModel(
    id: 'dl_002',
    airline: 'Delta Air Lines',
    flightNumber: 'DL 8901',
    aircraft: 'Airbus A350-900',
    departureAirport: 'JFK (New York)',
    arrivalAirport: 'NRT (Tokyo)',
    departureTime: '01:30 PM',
    arrivalTime: '04:55 PM+1',
    duration: '14h 25m',
    basePrice: 850.0,
    flightType: 'International',
    totalSeats: 306,
    stops: 0,
    amenities: <String>['Delta One Suites', 'Premium Entertainment', 'WiFi', 'Gourmet Dining'],
  ),

  // United Airlines
  FlightModel(
    id: 'ua_001',
    airline: 'United Airlines',
    flightNumber: 'UA 3456',
    aircraft: 'Boeing 737 MAX 8',
    departureAirport: 'ORD (Chicago)',
    arrivalAirport: 'DEN (Denver)',
    departureTime: '02:20 PM',
    arrivalTime: '03:45 PM',
    duration: '2h 25m',
    basePrice: 180.0,
    flightType: 'Domestic',
    totalSeats: 166,
    stops: 0,
    amenities: <String>['WiFi', 'Snacks for Purchase', 'Power Outlets', 'Streaming Entertainment'],
  ),

  FlightModel(
    id: 'ua_002',
    airline: 'United Airlines',
    flightNumber: 'UA 7890',
    aircraft: 'Boeing 777-300ER',
    departureAirport: 'SFO (San Francisco)',
    arrivalAirport: 'FRA (Frankfurt)',
    departureTime: '03:25 PM',
    arrivalTime: '01:15 PM+1',
    duration: '11h 50m',
    basePrice: 720.0,
    flightType: 'International',
    totalSeats: 364,
    stops: 0,
    amenities: <String>['Polaris Business Class', 'Premium Entertainment', 'WiFi', 'Multi-course Dining'],
  ),

  // Southwest Airlines
  FlightModel(
    id: 'wn_001',
    airline: 'Southwest Airlines',
    flightNumber: 'WN 1234',
    aircraft: 'Boeing 737-800',
    departureAirport: 'DAL (Dallas)',
    arrivalAirport: 'PHX (Phoenix)',
    departureTime: '11:30 AM',
    arrivalTime: '12:25 PM',
    duration: '1h 55m',
    basePrice: 150.0,
    flightType: 'Domestic',
    totalSeats: 175,
    stops: 0,
    amenities: <String>['Free Checked Bags', 'WiFi', 'Snacks', 'No Change Fees'],
  ),

  FlightModel(
    id: 'wn_002',
    airline: 'Southwest Airlines',
    flightNumber: 'WN 5678',
    aircraft: 'Boeing 737 MAX 8',
    departureAirport: 'LAS (Las Vegas)',
    arrivalAirport: 'BWI (Baltimore)',
    departureTime: '08:45 AM',
    arrivalTime: '04:20 PM',
    duration: '4h 35m',
    basePrice: 220.0,
    flightType: 'Domestic',
    totalSeats: 175,
    stops: 0,
    amenities: <String>['Free Checked Bags', 'WiFi', 'Drinks & Snacks', 'Flexible Booking'],
  ),

  // JetBlue Airways
  FlightModel(
    id: 'b6_001',
    airline: 'JetBlue Airways',
    flightNumber: 'B6 1357',
    aircraft: 'Airbus A320',
    departureAirport: 'BOS (Boston)',
    arrivalAirport: 'FLL (Fort Lauderdale)',
    departureTime: '07:00 AM',
    arrivalTime: '10:30 AM',
    duration: '3h 30m',
    basePrice: 200.0,
    flightType: 'Domestic',
    totalSeats: 150,
    stops: 0,
    amenities: <String>['Free WiFi', 'Live TV', 'Extra Legroom', 'Free Snacks & Drinks'],
  ),

  FlightModel(
    id: 'b6_002',
    airline: 'JetBlue Airways',
    flightNumber: 'B6 2468',
    aircraft: 'Airbus A321',
    departureAirport: 'JFK (New York)',
    arrivalAirport: 'SJU (San Juan)',
    departureTime: '09:15 AM',
    arrivalTime: '01:45 PM',
    duration: '4h 30m',
    basePrice: 280.0,
    flightType: 'International',
    totalSeats: 200,
    stops: 0,
    amenities: <String>['Mint Class Available', 'Free WiFi', 'Live TV', 'Premium Dining'],
  ),

  // Alaska Airlines
  FlightModel(
    id: 'as_001',
    airline: 'Alaska Airlines',
    flightNumber: 'AS 1122',
    aircraft: 'Boeing 737-900',
    departureAirport: 'SEA (Seattle)',
    arrivalAirport: 'ANC (Anchorage)',
    departureTime: '06:30 AM',
    arrivalTime: '09:45 AM',
    duration: '3h 15m',
    basePrice: 250.0,
    flightType: 'Domestic',
    totalSeats: 178,
    stops: 0,
    amenities: <String>['WiFi', 'Power Outlets', 'Food for Purchase', 'Alaska Beyond Entertainment'],
  ),

  FlightModel(
    id: 'as_002',
    airline: 'Alaska Airlines',
    flightNumber: 'AS 3344',
    aircraft: 'Boeing 737-800',
    departureAirport: 'PDX (Portland)',
    arrivalAirport: 'HNL (Honolulu)',
    departureTime: '11:20 AM',
    arrivalTime: '02:30 PM',
    duration: '6h 10m',
    basePrice: 380.0,
    flightType: 'Domestic',
    totalSeats: 159,
    stops: 0,
    amenities: <String>['WiFi', 'Premium Class', 'Hawaiian Meals', 'Entertainment System'],
  ),

  // Spirit Airlines
  FlightModel(
    id: 'nk_001',
    airline: 'Spirit Airlines',
    flightNumber: 'NK 567',
    aircraft: 'Airbus A319',
    departureAirport: 'FLL (Fort Lauderdale)',
    arrivalAirport: 'DTW (Detroit)',
    departureTime: '01:45 PM',
    arrivalTime: '04:20 PM',
    duration: '2h 35m',
    basePrice: 120.0,
    flightType: 'Domestic',
    totalSeats: 145,
    stops: 0,
    amenities: <String>['WiFi for Purchase', 'Big Front Seat Option', 'Food & Drinks for Purchase'],
  ),

  // Frontier Airlines
  FlightModel(
    id: 'f9_001',
    airline: 'Frontier Airlines',
    flightNumber: 'F9 789',
    aircraft: 'Airbus A320neo',
    departureAirport: 'DEN (Denver)',
    arrivalAirport: 'MCO (Orlando)',
    departureTime: '08:15 AM',
    arrivalTime: '01:30 PM',
    duration: '3h 15m',
    basePrice: 140.0,
    flightType: 'Domestic',
    totalSeats: 186,
    stops: 0,
    amenities: <String>['WiFi for Purchase', 'Stretch Seating Available', 'Food & Drinks for Purchase'],
  ),

  // Hawaiian Airlines
  FlightModel(
    id: 'ha_001',
    airline: 'Hawaiian Airlines',
    flightNumber: 'HA 23',
    aircraft: 'Airbus A330-200',
    departureAirport: 'HNL (Honolulu)',
    arrivalAirport: 'LAX (Los Angeles)',
    departureTime: '11:59 PM',
    arrivalTime: '07:05 AM+1',
    duration: '5h 06m',
    basePrice: 320.0,
    flightType: 'Domestic',
    totalSeats: 294,
    stops: 0,
    amenities: <String>['WiFi', 'Island-inspired Meals', 'Premium Cabin', 'Hawaiian Entertainment'],
  ),

  // Allegiant Air
  FlightModel(
    id: 'g4_001',
    airline: 'Allegiant Air',
    flightNumber: 'G4 456',
    aircraft: 'Airbus A319',
    departureAirport: 'LAS (Las Vegas)',
    arrivalAirport: 'BIL (Billings)',
    departureTime: '10:30 AM',
    arrivalTime: '01:45 PM',
    duration: '2h 15m',
    basePrice: 110.0,
    flightType: 'Domestic',
    totalSeats: 156,
    stops: 0,
    amenities: <String>['Priority Seating Available', 'Snacks for Purchase', 'Giant Seats Option'],
  ),

  // Sun Country Airlines
  FlightModel(
    id: 'sy_001',
    airline: 'Sun Country Airlines',
    flightNumber: 'SY 234',
    aircraft: 'Boeing 737-800',
    departureAirport: 'MSP (Minneapolis)',
    arrivalAirport: 'PHX (Phoenix)',
    departureTime: '07:20 AM',
    arrivalTime: '09:45 AM',
    duration: '3h 25m',
    basePrice: 170.0,
    flightType: 'Domestic',
    totalSeats: 162,
    stops: 0,
    amenities: <String>['WiFi', 'First Class Available', 'Snacks & Drinks for Purchase'],
  ),

  // Regional Airlines

  // SkyWest Airlines (Operating as United Express)
  FlightModel(
    id: 'oo_001',
    airline: 'SkyWest Airlines',
    flightNumber: 'UA 5432',
    aircraft: 'Embraer E175',
    departureAirport: 'SLC (Salt Lake City)',
    arrivalAirport: 'BOI (Boise)',
    departureTime: '05:45 PM',
    arrivalTime: '06:30 PM',
    duration: '1h 45m',
    basePrice: 140.0,
    flightType: 'Regional',
    totalSeats: 76,
    stops: 0,
    amenities: <String>['WiFi', 'First Class Available', 'Complimentary Snacks'],
  ),

  // Mesa Airlines (Operating as American Eagle)
  FlightModel(
    id: 'yv_001',
    airline: 'Mesa Airlines',
    flightNumber: 'AA 4567',
    aircraft: 'Bombardier CRJ-900',
    departureAirport: 'PHX (Phoenix)',
    arrivalAirport: 'TUS (Tucson)',
    departureTime: '12:30 PM',
    arrivalTime: '01:15 PM',
    duration: '45m',
    basePrice: 90.0,
    flightType: 'Regional',
    totalSeats: 76,
    stops: 0,
    amenities: <String>['First Class Available', 'Complimentary Beverages'],
  ),

  // Connecting Flights with Stops
  FlightModel(
    id: 'aa_connect_001',
    airline: 'American Airlines',
    flightNumber: 'AA 9876',
    aircraft: 'Boeing 737-800',
    departureAirport: 'BOS (Boston)',
    arrivalAirport: 'LAX (Los Angeles)',
    departureTime: '06:00 AM',
    arrivalTime: '02:30 PM',
    duration: '8h 30m',
    basePrice: 280.0,
    flightType: 'Domestic',
    totalSeats: 160,
    stops: 1,
    amenities: <String>['WiFi', 'In-flight Entertainment', 'Food Service', 'Power Outlets'],
  ),

  FlightModel(
    id: 'dl_connect_001',
    airline: 'Delta Air Lines',
    flightNumber: 'DL 5432',
    aircraft: 'Boeing 757-200',
    departureAirport: 'MIA (Miami)',
    arrivalAirport: 'SEA (Seattle)',
    departureTime: '08:15 AM',
    arrivalTime: '04:45 PM',
    duration: '9h 30m',
    basePrice: 340.0,
    flightType: 'Domestic',
    totalSeats: 199,
    stops: 1,
    amenities: <String>['WiFi', 'Delta Studio', 'Meal Service', 'Power Outlets'],
  ),
];
