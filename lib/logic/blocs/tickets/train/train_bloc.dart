import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payfussion/logic/blocs/tickets/train/train_event.dart';
import 'package:payfussion/logic/blocs/tickets/train/train_state.dart';

import '../../../../data/models/tickets/train_model.dart';
import '../../../../data/repositories/ticket/train_repository.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';

class TrainBloc extends Bloc<TrainEvent, TrainState> {
  final TrainRepository _firebaseService;

  TrainBloc(this._firebaseService) : super(TrainInitial()) {
    on<InitializeTrains>(_onInitializeTrains);
    on<LoadTrains>(_onLoadTrains);
  }

  void _onInitializeTrains(InitializeTrains event, Emitter<TrainState> emit) async {
    emit(TrainLoading());
    try {
      await _firebaseService.addTrainsToUser(FirebaseAuth.instance.currentUser!.uid, usTrainDetails);
      add(LoadTrains());
    } catch (e) {
      emit(TrainError('Failed to initialize trains: $e'));
    }
  }

  void _onLoadTrains(LoadTrains event, Emitter<TrainState> emit) async {
    emit(TrainLoading());
    try {
      await emit.forEach<List<TrainModel>>(
        _firebaseService.getUserTrains(FirebaseAuth.instance.currentUser!.uid),
        onData: (List<TrainModel> trains) => TrainLoaded(trains),
        onError: (Object error, _) => TrainError('Failed to load trains: $error'),
      );
    } catch (e) {
      emit(TrainError('Failed to load trains: $e'));
    }
  }
}

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final TrainRepository _firebaseService;
  final NotificationBloc _notificationBloc;

  BookingBloc(this._firebaseService, this._notificationBloc) : super(BookingInitial()) {
    on<CreateBooking>(_onCreateBooking);
    on<LoadUserBookings>(_onLoadUserBookings);
  }

  void _onCreateBooking(CreateBooking event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      print('Creating train booking...');
      print('Train: ${event.booking.trainName}');
      print('Travel Date: ${event.booking.travelDate}');
      print('Passengers: ${event.booking.numberOfPassengers}');
      print('Class: ${event.booking.travelClass}');
      print('Total Amount: ${event.booking.totalAmount}');

      // Add booking to Firestore
      await _firebaseService.addBookingToUser(FirebaseAuth.instance.currentUser!.uid, event.booking);

      // SHOW LOCAL NOTIFICATION
      await LocalNotificationService.showTransactionNotification(
        transactionType: 'sent',
        amount: event.booking.totalAmount,
        currency: 'USD',
      );

      // ADD FIRESTORE NOTIFICATION
      try {
        print('Adding train booking notification to Firestore...');

        final Map<String, Object> notificationData = <String, Object>{
          'bookingId': event.booking.id,
          'trainId': event.booking.trainId,
          'trainName': event.booking.trainName,
          'passengerName': event.booking.passengerName,
          'email': event.booking.email,
          'phone': event.booking.phone,
          'travelDate': event.booking.travelDate.toIso8601String(),
          'numberOfPassengers': event.booking.numberOfPassengers,
          'totalAmount': event.booking.totalAmount,
          'baseFare': event.booking.baseFare,
          'classUpgradeAmount': event.booking.classUpgradeAmount,
          'taxAmount': event.booking.taxAmount,
          'travelClass': event.booking.travelClass,
          'paymentStatus': event.booking.paymentStatus,
          'bookingDate': event.booking.bookingDate.toIso8601String(),
          'userId': FirebaseAuth.instance.currentUser!.uid,
        };

        print('Train booking notification data: $notificationData');

        _notificationBloc.add(AddNotification(
          title: 'Train Ticket Booked Successfully!',
          message: _buildTrainBookingNotificationMessage(event.booking),
          type: 'train_booking_success',
          data: notificationData,
        ));

        print('Train booking notification event added to bloc');
      } catch (notificationError) {
        print('Error adding train booking notification: $notificationError');
      }

      emit(const BookingSuccess('Train booking created successfully!'));

    } catch (e) {
      print('Train booking error: $e');

      // ERROR LOCAL NOTIFICATION
      await LocalNotificationService.showCustomNotification(
        title: 'Booking Failed',
        body: 'Train booking failed: ${e.toString()}',
        payload: 'train_booking_failed|${event.booking.id}',
      );

      // ERROR FIRESTORE NOTIFICATION
      _notificationBloc.add(AddNotification(
        title: 'Train Booking Failed',
        message: 'Failed to book train ticket: ${e.toString()}',
        type: 'train_booking_failed',
        data: <String, dynamic>{
          'bookingId': event.booking.id,
          'trainName': event.booking.trainName,
          'error': e.toString(),
          'userId': FirebaseAuth.instance.currentUser!.uid,
        },
      ));

      emit(BookingError('Failed to create booking: $e'));
    }
  }

  void _onLoadUserBookings(LoadUserBookings event, Emitter<BookingState> emit) async {
    try {
      await emit.forEach<List<BookingModel>>(
        _firebaseService.getUserBookings(event.email),
        onData: (List<BookingModel> bookings) => UserBookingsLoaded(bookings),
        onError: (Object error, _) => BookingError('Failed to load bookings: $error'),
      );
    } catch (e) {
      emit(BookingError('Failed to load bookings: $e'));
    }
  }

  // Helper method to build detailed notification message
  String _buildTrainBookingNotificationMessage(BookingModel booking) {
    final String trainName = booking.trainName;
    final String passengerName = booking.passengerName;
    final String travelDate = booking.travelDate.toString().substring(0, 10); // YYYY-MM-DD format
    final int numberOfPassengers = booking.numberOfPassengers;
    final String travelClass = booking.travelClass;
    final double baseFare = booking.baseFare;
    final double classUpgradeAmount = booking.classUpgradeAmount;
    final double taxAmount = booking.taxAmount;
    final double totalAmount = booking.totalAmount;

    return '''Train ticket booked successfully!

Train: $trainName
Passenger: $passengerName
Travel Date: $travelDate
Passengers: $numberOfPassengers
Class: $travelClass

Pricing Breakdown:
Base Fare: \$${baseFare.toStringAsFixed(2)} x $numberOfPassengers
Class Upgrade: \$${classUpgradeAmount.toStringAsFixed(2)}
Tax: \$${taxAmount.toStringAsFixed(2)}
Total Amount: \$${totalAmount.toStringAsFixed(2)}

Booking confirmed at ${DateTime.now().toString().substring(0, 19)}

Have a safe journey! ''';
  }
}

// US Train Services Data
List<TrainModel> usTrainDetails = <TrainModel>[
  TrainModel(
    id: 'acela_001',
    name: 'Acela',
    route: 'Boston ↔ Washington, DC',
    via: 'New York, Philadelphia, Baltimore',
    duration: const Duration(hours: 6, minutes: 30),
    approxCostUSD: 150.0,
    description: 'Amtrak\'s flagship high-speed rail service connecting major Northeast cities. Experience premium comfort and faster travel times.',
    amenities: <String>['Free WiFi', 'Power Outlets', 'Café Car', 'Business Class Seating', 'At-seat Food Service'],
  ),
  TrainModel(
    id: 'northeast_regional_001',
    name: 'Northeast Regional',
    route: 'Boston / New York ↔ Washington, DC / Virginia',
    via: 'Philadelphia, Baltimore, Richmond',
    duration: const Duration(hours: 7, minutes: 30),
    approxCostUSD: 65.0,
    description: 'Comfortable and affordable train service along the Northeast Corridor, serving major cities and smaller communities.',
    amenities: <String>['Free WiFi', 'Café Car', 'Large Windows', 'Comfortable Seating'],
  ),
  TrainModel(
    id: 'empire_builder_001',
    name: 'Empire Builder',
    route: 'Chicago ↔ Seattle / Portland',
    via: 'Milwaukee, Minneapolis, Glacier National Park, Spokane',
    duration: const Duration(hours: 46, minutes: 0),
    approxCostUSD: 200.0,
    description: 'A scenic cross-country journey through the northern United States, featuring stunning views of Glacier National Park and the Rocky Mountains.',
    amenities: <String>['Observation Car', 'Dining Car', 'Sleeping Cars', 'Baggage Service', 'Spectacular Mountain Views'],
  ),
  TrainModel(
    id: 'southwest_chief_001',
    name: 'Southwest Chief',
    route: 'Chicago ↔ Los Angeles',
    via: 'Kansas City, Albuquerque, Flagstaff, Grand Canyon',
    duration: const Duration(hours: 43, minutes: 0),
    approxCostUSD: 180.0,
    description: 'Travel the historic Santa Fe Railway route through the American Southwest, passing near the Grand Canyon and through stunning desert landscapes.',
    amenities: <String>['Sightseer Lounge', 'Dining Car', 'Sleeping Cars', 'Desert Views', 'Native American Cultural Sites'],
  ),
  TrainModel(
    id: 'sunset_limited_001',
    name: 'Sunset Limited',
    route: 'New Orleans ↔ Los Angeles',
    via: 'Houston, San Antonio, El Paso, Tucson, Phoenix',
    duration: const Duration(hours: 48, minutes: 0),
    approxCostUSD: 190.0,
    description: 'The southernmost transcontinental route, offering views of bayous, deserts, and mountains across the Deep South and Southwest.',
    amenities: <String>['Observation Car', 'Dining Car', 'Sleeping Cars', 'Southern Cuisine', 'Desert and Bayou Views'],
  ),
  TrainModel(
    id: 'wolverine_001',
    name: 'Wolverine',
    route: 'Chicago ↔ Detroit / Pontiac',
    via: 'Kalamazoo, Battle Creek, Ann Arbor, Dearborn',
    duration: const Duration(hours: 5, minutes: 45),
    approxCostUSD: 35.0,
    description: 'Daily service connecting Chicago with Michigan\'s largest cities, perfect for business travel or exploring the Great Lakes region.',
    amenities: <String>['Free WiFi', 'Café Car', 'Business Class', 'Great Lakes Views'],
  ),
  TrainModel(
    id: 'california_zephyr_001',
    name: 'California Zephyr',
    route: 'Chicago ↔ San Francisco Bay Area',
    via: 'Denver, Salt Lake City, Reno, Sacramento',
    duration: const Duration(hours: 51, minutes: 20),
    approxCostUSD: 220.0,
    description: 'Often called the most beautiful train ride in North America, crossing the Rocky Mountains, Sierra Nevada, and offering spectacular scenery.',
    amenities: <String>['Sightseer Lounge', 'Dining Car', 'Sleeping Cars', 'Rocky Mountain Views', 'Sierra Nevada Crossing'],
  ),
  TrainModel(
    id: 'silver_star_001',
    name: 'Silver Star',
    route: 'New York ↔ Miami',
    via: 'Philadelphia, Washington DC, Raleigh, Savannah, Jacksonville, Orlando, Tampa',
    duration: const Duration(hours: 28, minutes: 0),
    approxCostUSD: 120.0,
    description: 'Travel the East Coast from New York to Florida, passing through historic cities and beautiful coastal regions.',
    amenities: <String>['Café Car', 'Business Class', 'Sleeping Cars', 'Coastal Views', 'Historic Cities'],
  ),
  TrainModel(
    id: 'coast_starlight_001',
    name: 'Coast Starlight',
    route: 'Seattle ↔ Los Angeles',
    via: 'Portland, Sacramento, San Francisco Bay Area, San Luis Obispo, Santa Barbara',
    duration: const Duration(hours: 35, minutes: 0),
    approxCostUSD: 160.0,
    description: 'Spectacular Pacific Coast journey featuring ocean views, mountain forests, and California wine country.',
    amenities: <String>['Pacific Parlour Car', 'Dining Car', 'Sightseer Lounge', 'Ocean Views', 'Wine Tasting'],
  ),
  TrainModel(
    id: 'crescent_001',
    name: 'Crescent',
    route: 'New York ↔ New Orleans',
    via: 'Philadelphia, Washington DC, Atlanta, Birmingham, Meridian',
    duration: const Duration(hours: 30, minutes: 0),
    approxCostUSD: 140.0,
    description: 'Journey through the heart of the American South, from the bustling Northeast to the cultural richness of New Orleans.',
    amenities: <String>['Dining Car', 'Sleeping Cars', 'Lounge Car', 'Southern Scenery', 'Historic Cities'],
  ),
  TrainModel(
    id: 'cardinal_001',
    name: 'Cardinal',
    route: 'New York ↔ Chicago',
    via: 'Philadelphia, Washington DC, Charlottesville, Indianapolis',
    duration: const Duration(hours: 26, minutes: 45),
    approxCostUSD: 110.0,
    description: 'Scenic route through Virginia\'s Blue Ridge Mountains and West Virginia\'s New River Gorge, operating three times per week.',
    amenities: <String>['Café Car', 'Sleeping Cars', 'Mountain Views', 'New River Gorge', 'Blue Ridge Mountains'],
  ),
  TrainModel(
    id: 'texas_eagle_001',
    name: 'Texas Eagle',
    route: 'Chicago ↔ San Antonio (extends to Los Angeles)',
    via: 'St. Louis, Little Rock, Dallas, Fort Worth, Austin',
    duration: const Duration(hours: 32, minutes: 0),
    approxCostUSD: 150.0,
    description: 'Daily service through the heart of Texas, with through cars continuing to Los Angeles three times per week.',
    amenities: <String>['Sightseer Lounge', 'Dining Car', 'Sleeping Cars', 'Texas Hill Country', 'Big Sky Country'],
  ),
];