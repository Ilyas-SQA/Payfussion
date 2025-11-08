
import 'package:cloud_firestore/cloud_firestore.dart';

class BusModel {
  final String id;
  final String companyName;
  final String route;
  final String via;
  final Duration duration;
  final double approxCostUSD;
  final String description;
  final List<String> amenities;
  final String busType; // Economy, Premium, Express
  final int totalSeats;
  final List<String> departurePoints;
  final List<String> arrivalPoints;

  BusModel({
    required this.id,
    required this.companyName,
    required this.route,
    this.via = '',
    required this.duration,
    required this.approxCostUSD,
    this.description = '',
    this.amenities = const <String>[],
    this.busType = 'Economy',
    this.totalSeats = 50,
    this.departurePoints = const <String>[],
    this.arrivalPoints = const <String>[],
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'companyName': companyName,
      'route': route,
      'via': via,
      'durationHours': duration.inHours,
      'durationMinutes': duration.inMinutes % 60,
      'approxCostUSD': approxCostUSD,
      'description': description,
      'amenities': amenities,
      'busType': busType,
      'totalSeats': totalSeats,
      'departurePoints': departurePoints,
      'arrivalPoints': arrivalPoints,
    };
  }

  factory BusModel.fromMap(Map<String, dynamic> map) {
    return BusModel(
      id: map['id'] ?? '',
      companyName: map['companyName'] ?? '',
      route: map['route'] ?? '',
      via: map['via'] ?? '',
      duration: Duration(
        hours: map['durationHours'] ?? 0,
        minutes: map['durationMinutes'] ?? 0,
      ),
      approxCostUSD: (map['approxCostUSD'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      amenities: List<String>.from(map['amenities'] ?? <dynamic>[]),
      busType: map['busType'] ?? 'Economy',
      totalSeats: map['totalSeats'] ?? 50,
      departurePoints: List<String>.from(map['departurePoints'] ?? <dynamic>[]),
      arrivalPoints: List<String>.from(map['arrivalPoints'] ?? <dynamic>[]),
    );
  }
}

// Updated BusBookingModel with tax-related fields
class BusBookingModel {
  final String id;
  final String busId;
  final String companyName;
  final String passengerName;
  final String email;
  final String phone;
  final DateTime travelDate;
  final int numberOfPassengers;
  final double totalAmount;
  final double baseTicketPrice;
  final double seatUpgradeAmount;
  final double taxAmount;
  final String paymentStatus;
  final DateTime bookingDate;
  final String seatType;

  BusBookingModel({
    required this.id,
    required this.busId,
    required this.companyName,
    required this.passengerName,
    required this.email,
    required this.phone,
    required this.travelDate,
    required this.numberOfPassengers,
    required this.totalAmount,
    required this.baseTicketPrice,
    required this.seatUpgradeAmount,
    required this.taxAmount,
    required this.paymentStatus,
    required this.bookingDate,
    required this.seatType,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'busId': busId,
      'companyName': companyName,
      'passengerName': passengerName,
      'email': email,
      'phone': phone,
      'travelDate': Timestamp.fromDate(travelDate),
      'numberOfPassengers': numberOfPassengers,
      'totalAmount': totalAmount,
      'baseTicketPrice': baseTicketPrice,
      'seatUpgradeAmount': seatUpgradeAmount,
      'taxAmount': taxAmount,
      'paymentStatus': paymentStatus,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'seatType': seatType,
    };
  }

  factory BusBookingModel.fromMap(Map<String, dynamic> map) {
    return BusBookingModel(
      id: map['id'] ?? '',
      busId: map['busId'] ?? '',
      companyName: map['companyName'] ?? '',
      passengerName: map['passengerName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      travelDate: (map['travelDate'] as Timestamp).toDate(),
      numberOfPassengers: map['numberOfPassengers'] ?? 1,
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      baseTicketPrice: (map['baseTicketPrice'] ?? 0.0).toDouble(),
      seatUpgradeAmount: (map['seatUpgradeAmount'] ?? 0.0).toDouble(),
      taxAmount: (map['taxAmount'] ?? 0.0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? 'pending',
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      seatType: map['seatType'] ?? 'Standard',
    );
  }
}


// Major US Bus Services Data
List<BusModel> usBusServices = <BusModel>[
  // Greyhound Lines
  BusModel(
    id: 'greyhound_001',
    companyName: 'Greyhound Lines',
    route: 'New York ↔ Los Angeles',
    via: 'Philadelphia, Pittsburgh, Chicago, Denver, Salt Lake City, Las Vegas',
    duration: const Duration(hours: 72),
    approxCostUSD: 180.0,
    description: 'America\'s largest intercity bus service with coast-to-coast routes and extensive network coverage.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'Reclining Seats', 'Luggage Storage'],
    busType: 'Express',
    totalSeats: 55,
    departurePoints: <String>['Port Authority Bus Terminal, NYC'],
    arrivalPoints: <String>['Los Angeles Union Station'],
  ),

  BusModel(
    id: 'greyhound_002',
    companyName: 'Greyhound Lines',
    route: 'Chicago ↔ Miami',
    via: 'Indianapolis, Nashville, Atlanta, Jacksonville, Orlando',
    duration: const Duration(hours: 28),
    approxCostUSD: 120.0,
    description: 'Popular route connecting the Midwest to South Florida with multiple daily departures.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'Air Conditioning'],
    busType: 'Express',
    totalSeats: 55,
  ),

  // FlixBus USA
  BusModel(
    id: 'flixbus_001',
    companyName: 'FlixBus',
    route: 'New York ↔ Washington DC',
    via: 'Philadelphia, Baltimore',
    duration: const Duration(hours: 5, minutes: 30),
    approxCostUSD: 25.0,
    description: 'European-style intercity bus service with modern amenities and competitive prices.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Extra Legroom', 'Panoramic Windows', 'Snack Bar'],
    busType: 'Premium',
    totalSeats: 49,
  ),

  BusModel(
    id: 'flixbus_002',
    companyName: 'FlixBus',
    route: 'Los Angeles ↔ Las Vegas',
    via: 'San Bernardino, Barstow',
    duration: const Duration(hours: 5),
    approxCostUSD: 20.0,
    description: 'Popular weekend route connecting LA to Las Vegas with frequent departures.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'Air Conditioning'],
    busType: 'Economy',
    totalSeats: 55,
  ),

  // Megabus
  BusModel(
    id: 'megabus_001',
    companyName: 'Megabus',
    route: 'New York ↔ Boston',
    via: 'Hartford, Springfield',
    duration: const Duration(hours: 4, minutes: 30),
    approxCostUSD: 15.0,
    description: 'Low-cost intercity bus service with double-decker buses and advance booking discounts.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'Upper Deck Views'],
    busType: 'Economy',
    totalSeats: 81, // Double-decker
  ),

  BusModel(
    id: 'megabus_002',
    companyName: 'Megabus',
    route: 'Chicago ↔ Detroit',
    via: 'Kalamazoo',
    duration: const Duration(hours: 5),
    approxCostUSD: 20.0,
    description: 'Affordable option connecting major Midwest cities with comfortable seating.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom'],
    busType: 'Economy',
    totalSeats: 55,
  ),

  // BoltBus (Greyhound Express)
  BusModel(
    id: 'boltbus_001',
    companyName: 'BoltBus',
    route: 'New York ↔ Philadelphia',
    via: '',
    duration: const Duration(hours: 2),
    approxCostUSD: 12.0,
    description: 'Express service with limited stops and premium amenities for short-distance travel.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Reserved Seating', 'Express Service'],
    busType: 'Express',
    totalSeats: 48,
  ),

  // Peter Pan Bus Lines
  BusModel(
    id: 'peterpan_001',
    companyName: 'Peter Pan Bus Lines',
    route: 'Boston ↔ New York',
    via: 'Springfield, Hartford',
    duration: const Duration(hours: 4, minutes: 15),
    approxCostUSD: 30.0,
    description: 'Regional carrier serving New England and New York with comfortable coaches.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'Reclining Seats'],
    busType: 'Premium',
    totalSeats: 50,
  ),

  // Adirondack Trailways
  BusModel(
    id: 'adirondack_001',
    companyName: 'Adirondack Trailways',
    route: 'New York ↔ Montreal',
    via: 'Albany, Plattsburgh',
    duration: const Duration(hours: 8),
    approxCostUSD: 55.0,
    description: 'International service connecting New York to Montreal with scenic route through Adirondack Mountains.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'Mountain Views'],
    busType: 'Express',
    totalSeats: 52,
  ),

  // Jefferson Lines
  BusModel(
    id: 'jefferson_001',
    companyName: 'Jefferson Lines',
    route: 'Minneapolis ↔ Kansas City',
    via: 'Des Moines, Omaha',
    duration: const Duration(hours: 9),
    approxCostUSD: 65.0,
    description: 'Midwest regional carrier serving smaller cities with reliable service.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'Comfortable Seating'],
    busType: 'Economy',
    totalSeats: 55,
  ),

  // RedCoach
  BusModel(
    id: 'redcoach_001',
    companyName: 'RedCoach',
    route: 'Miami ↔ Orlando',
    via: 'Fort Lauderdale, West Palm Beach',
    duration: const Duration(hours: 4),
    approxCostUSD: 35.0,
    description: 'Luxury bus service in Florida with leather seats and premium amenities.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Leather Seats', 'Personal Entertainment', 'Restroom'],
    busType: 'Premium',
    totalSeats: 28, // Luxury configuration
  ),

  // Concord Coach Lines
  BusModel(
    id: 'concord_001',
    companyName: 'Concord Coach Lines',
    route: 'Boston ↔ Bangor, ME',
    via: 'Portsmouth, Portland',
    duration: const Duration(hours: 5, minutes: 30),
    approxCostUSD: 40.0,
    description: 'New England regional service known for punctuality and comfort.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'Spacious Seats'],
    busType: 'Premium',
    totalSeats: 50,
  ),

  // El Paso-Los Angeles Limousine Express
  BusModel(
    id: 'elpaso_la_001',
    companyName: 'El Paso-Los Angeles Limousine',
    route: 'El Paso ↔ Los Angeles',
    via: 'Phoenix, Tucson',
    duration: const Duration(hours: 12),
    approxCostUSD: 80.0,
    description: 'Southwest regional service connecting Texas to California.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'Snacks'],
    busType: 'Express',
    totalSeats: 55,
  ),

  // Tornado Bus Company
  BusModel(
    id: 'tornado_001',
    companyName: 'Tornado Bus',
    route: 'Houston ↔ Dallas',
    via: 'Bryan, Huntsville',
    duration: const Duration(hours: 4),
    approxCostUSD: 25.0,
    description: 'Texas regional service connecting major cities with frequent departures.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Air Conditioning', 'Restroom'],
    busType: 'Economy',
    totalSeats: 55,
  ),

  // Burlington Trailways
  BusModel(
    id: 'burlington_001',
    companyName: 'Burlington Trailways',
    route: 'Chicago ↔ Omaha',
    via: 'Rock Island, Burlington, Ottumwa',
    duration: const Duration(hours: 8),
    approxCostUSD: 50.0,
    description: 'Regional carrier serving smaller Midwest communities with personalized service.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'Package Express'],
    busType: 'Economy',
    totalSeats: 47,
  ),

  // Valley Transit Company
  BusModel(
    id: 'valley_001',
    companyName: 'Valley Transit',
    route: 'Harlingen ↔ Houston',
    via: 'McAllen, Corpus Christi, Victoria',
    duration: const Duration(hours: 7),
    approxCostUSD: 45.0,
    description: 'South Texas service connecting the Rio Grande Valley to major cities.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'Bilingual Service'],
    busType: 'Economy',
    totalSeats: 55,
  ),

  // Lakefront Lines
  BusModel(
    id: 'lakefront_001',
    companyName: 'Lakefront Lines',
    route: 'Milwaukee ↔ Duluth',
    via: 'Green Bay, Wausau',
    duration: const Duration(hours: 6),
    approxCostUSD: 35.0,
    description: 'Wisconsin regional service connecting cities along Lake Michigan and Lake Superior.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'Lake Views'],
    busType: 'Economy',
    totalSeats: 50,
  ),

  // Academy Bus
  BusModel(
    id: 'academy_001',
    companyName: 'Academy Bus',
    route: 'New York ↔ Philadelphia',
    via: 'Newark, Trenton',
    duration: const Duration(hours: 2, minutes: 30),
    approxCostUSD: 18.0,
    description: 'Northeast corridor service with frequent departures and competitive pricing.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom'],
    busType: 'Economy',
    totalSeats: 55,
  ),

  // CoachRun
  BusModel(
    id: 'coachrun_001',
    companyName: 'CoachRun',
    route: 'Atlanta ↔ Nashville',
    via: 'Chattanooga',
    duration: const Duration(hours: 5),
    approxCostUSD: 30.0,
    description: 'Southeast regional service connecting major cities with modern coaches.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'USB Charging'],
    busType: 'Premium',
    totalSeats: 50,
  ),

  // OurBus
  BusModel(
    id: 'ourbus_001',
    companyName: 'OurBus',
    route: 'New York ↔ Cleveland',
    via: 'Newark, Allentown, Pittsburgh',
    duration: const Duration(hours: 8),
    approxCostUSD: 40.0,
    description: 'Technology-focused bus service with app-based booking and real-time tracking.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'GPS Tracking', 'Mobile App'],
    busType: 'Premium',
    totalSeats: 52,
  ),

  // Vamoose Bus
  BusModel(
    id: 'vamoose_001',
    companyName: 'Vamoose Bus',
    route: 'New York ↔ Bethesda, MD',
    via: '',
    duration: const Duration(hours: 4, minutes: 30),
    approxCostUSD: 25.0,
    description: 'Express service to Washington DC suburbs with comfortable seating.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom', 'Reserved Seating'],
    busType: 'Express',
    totalSeats: 48,
  ),

  // GO Buses (Transdev)
  BusModel(
    id: 'go_buses_001',
    companyName: 'GO Buses',
    route: 'Raleigh ↔ Charlotte',
    via: 'Durham, Greensboro',
    duration: const Duration(hours: 3, minutes: 30),
    approxCostUSD: 22.0,
    description: 'North Carolina intercity service connecting major cities.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Restroom'],
    busType: 'Economy',
    totalSeats: 55,
  ),
];