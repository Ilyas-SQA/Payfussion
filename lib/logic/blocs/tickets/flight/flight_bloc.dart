import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/tickets/flight_model.dart';
import '../../../../data/repositories/ticket/flight_repository.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'flight_event.dart';
import 'flight_state.dart';

class FlightBloc extends Bloc<FlightEvent, FlightState> {
  final FlightFirebaseService _firebaseService;

  FlightBloc(this._firebaseService) : super(FlightInitial()) {
    on<InitializeFlights>(_onInitializeFlights);
    on<LoadFlights>(_onLoadFlights);
  }

  void _onInitializeFlights(InitializeFlights event, Emitter<FlightState> emit) async {
    emit(FlightLoading());
    try {
      await _firebaseService.addFlightsToUser(FirebaseAuth.instance.currentUser!.uid, usFlightServices);
      add(LoadFlights());
    } catch (e) {
      emit(FlightError('Failed to initialize flights: $e'));
    }
  }

  void _onLoadFlights(LoadFlights event, Emitter<FlightState> emit) async {
    emit(FlightLoading());
    try {
      await emit.forEach<List<FlightModel>>(
        _firebaseService.getUserFlights(FirebaseAuth.instance.currentUser!.uid),
        onData: (List<FlightModel> flights) => FlightLoaded(flights),
        onError: (Object error, _) => FlightError('Failed to load flights: $error'),
      );
    } catch (e) {
      emit(FlightError('Failed to load flights: $e'));
    }
  }
}

class FlightBookingBloc extends Bloc<FlightBookingEvent, FlightBookingState> {
  final FlightFirebaseService _firebaseService;
  final NotificationBloc _notificationBloc;

  FlightBookingBloc(this._firebaseService, this._notificationBloc) : super(FlightBookingInitial()) {
    on<CreateFlightBooking>(_onCreateFlightBooking);
    on<LoadUserFlightBookings>(_onLoadUserFlightBookings);
  }

  void _onCreateFlightBooking(CreateFlightBooking event, Emitter<FlightBookingState> emit) async {
    emit(FlightBookingLoading());
    try {
      print('Creating flight booking...');
      print('Flight: ${event.booking.flightNumber}');
      print('From: ${event.booking.departureAirport}');
      print('To: ${event.booking.arrivalAirport}');
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
        currency: 'USD', // or get from booking if available
      );

      // ADD FIRESTORE NOTIFICATION
      try {
        print('Adding flight booking notification to Firestore...');

        final Map<String, Object> notificationData = <String, Object>{
          'bookingId': event.booking.id,
          'flightId': event.booking.flightId,
          'airline': event.booking.airline,
          'flightNumber': event.booking.flightNumber,
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
          'departureAirport': event.booking.departureAirport,
          'arrivalAirport': event.booking.arrivalAirport,
          'departureTime': event.booking.departureTime,
          'arrivalTime': event.booking.arrivalTime,
          'paymentStatus': event.booking.paymentStatus,
          'bookingDate': event.booking.bookingDate.toIso8601String(),
          'userId': FirebaseAuth.instance.currentUser!.uid,
        };

        print('Flight booking notification data: $notificationData');

        _notificationBloc.add(AddNotification(
          title: 'Flight Ticket Booked Successfully!',
          message: _buildFlightBookingNotificationMessage(event.booking),
          type: 'flight_booking_success',
          data: notificationData,
        ));

        print('✅ Flight booking notification event added to bloc');
      } catch (notificationError) {
        print('❌ Error adding flight booking notification: $notificationError');
      }

      emit(const FlightBookingSuccess('Flight booking created successfully!'));

    } catch (e) {
      print('❌ Flight booking error: $e');

      // ERROR LOCAL NOTIFICATION
      await LocalNotificationService.showCustomNotification(
        title: 'Booking Failed',
        body: 'Flight booking failed: ${e.toString()}',
        payload: 'flight_booking_failed|${event.booking.id}',
      );

      // ERROR FIRESTORE NOTIFICATION
      _notificationBloc.add(AddNotification(
        title: 'Flight Booking Failed',
        message: 'Failed to book flight ticket: ${e.toString()}',
        type: 'flight_booking_failed',
        data: <String, dynamic>{
          'bookingId': event.booking.id,
          'flightNumber': event.booking.flightNumber,
          'airline': event.booking.airline,
          'error': e.toString(),
          'userId': FirebaseAuth.instance.currentUser!.uid,
        },
      ));

      emit(FlightBookingError('Failed to create flight booking: $e'));
    }
  }

  void _onLoadUserFlightBookings(LoadUserFlightBookings event, Emitter<FlightBookingState> emit) async {
    try {
      await emit.forEach<List<FlightBookingModel>>(
        _firebaseService.getUserBookings(event.userId),
        onData: (List<FlightBookingModel> bookings) => UserFlightBookingsLoaded(bookings),
        onError: (Object error, _) => FlightBookingError('Failed to load bookings: $error'),
      );
    } catch (e) {
      emit(FlightBookingError('Failed to load bookings: $e'));
    }
  }

  // Helper method to build detailed notification message
  String _buildFlightBookingNotificationMessage(FlightBookingModel booking) {
    final String flightNumber = booking.flightNumber;
    final String airline = booking.airline;
    final String passengerName = booking.passengerName;
    final String departureAirport = booking.departureAirport;
    final String arrivalAirport = booking.arrivalAirport;
    final String travelDate = booking.travelDate.toString().substring(0, 10); // YYYY-MM-DD format
    final String departureTime = booking.departureTime;
    final String arrivalTime = booking.arrivalTime;
    final int numberOfPassengers = booking.numberOfPassengers;
    final String travelClass = booking.travelClass;
    final double baseFare = booking.baseFare;
    final double classUpgradeAmount = booking.classUpgradeAmount;
    final double taxAmount = booking.taxAmount;
    final double totalAmount = booking.totalAmount;

    return '''Flight ticket booked successfully! 

Flight: $airline $flightNumber
Passenger: $passengerName
Route: $departureAirport → $arrivalAirport
Date: $travelDate
Departure: $departureTime
Arrival: $arrivalTime
Passengers: $numberOfPassengers
Class: $travelClass

Pricing Breakdown:
Base Fare: \${baseFare.toStringAsFixed(2)} x $numberOfPassengers
Class Upgrade: \${classUpgradeAmount.toStringAsFixed(2)}
Tax & Fees: \${taxAmount.toStringAsFixed(2)}
Total Amount: \${totalAmount.toStringAsFixed(2)}

Booking confirmed at ${DateTime.now().toString().substring(0, 19)}

Have a safe flight! ''';
  }
}