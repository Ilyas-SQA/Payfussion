import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/tickets/bus_model.dart';
import '../../../../data/repositories/ticket/bus_repository.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'bus_event.dart';
import 'bus_state.dart';

class BusBloc extends Bloc<BusEvent, BusState> {
  final BusRepository _firebaseService;

  BusBloc(this._firebaseService) : super(BusInitial()) {
    on<InitializeBuses>(_onInitializeBuses);
    on<LoadBuses>(_onLoadBuses);
  }

  void _onInitializeBuses(InitializeBuses event, Emitter<BusState> emit) async {
    emit(BusLoading());
    try {
      await _firebaseService.addBusesToUser(FirebaseAuth.instance.currentUser!.uid, usBusServices);
      add(LoadBuses());
    } catch (e) {
      emit(BusError('Failed to initialize buses: $e'));
    }
  }

  void _onLoadBuses(LoadBuses event, Emitter<BusState> emit) async {
    emit(BusLoading());
    try {
      await emit.forEach<List<BusModel>>(
        _firebaseService.getUserBuses(FirebaseAuth.instance.currentUser!.uid),
        onData: (buses) => BusLoaded(buses),
        onError: (error, _) => BusError('Failed to load buses: $error'),
      );
    } catch (e) {
      emit(BusError('Failed to load buses: $e'));
    }
  }
}

class BusBookingBloc extends Bloc<BusBookingEvent, BusBookingState> {
  final BusRepository _firebaseService;
  final NotificationBloc _notificationBloc;

  BusBookingBloc(this._firebaseService, this._notificationBloc) : super(BusBookingInitial()) {
    on<CreateBusBooking>(_onCreateBusBooking);
    on<LoadUserBusBookings>(_onLoadUserBusBookings);
  }

  void _onCreateBusBooking(CreateBusBooking event, Emitter<BusBookingState> emit) async {
    emit(BusBookingLoading());
    try {
      print('🚌 Creating bus booking...');
      print('Bus Service: ${event.booking.companyName}');
      print('Travel Date: ${event.booking.travelDate}');
      print('Passengers: ${event.booking.numberOfPassengers}');
      print('Seat Type: ${event.booking.seatType}');
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
        print('🔔 Adding bus booking notification to Firestore...');

        final notificationData = {
          'bookingId': event.booking.id,
          'busId': event.booking.busId,
          'companyName': event.booking.companyName,
          'passengerName': event.booking.passengerName,
          'email': event.booking.email,
          'phone': event.booking.phone,
          'travelDate': event.booking.travelDate.toIso8601String(),
          'numberOfPassengers': event.booking.numberOfPassengers,
          'totalAmount': event.booking.totalAmount,
          'baseTicketPrice': event.booking.baseTicketPrice,
          'seatUpgradeAmount': event.booking.seatUpgradeAmount,
          'taxAmount': event.booking.taxAmount,
          'seatType': event.booking.seatType,
          'paymentStatus': event.booking.paymentStatus,
          'bookingDate': event.booking.bookingDate.toIso8601String(),
          'userId': FirebaseAuth.instance.currentUser!.uid,
        };

        print('Bus booking notification data: $notificationData');

        _notificationBloc.add(AddNotification(
          title: 'Bus Ticket Booked Successfully!',
          message: _buildBusBookingNotificationMessage(event.booking),
          type: 'bus_booking_success',
          data: notificationData,
        ));

        print('✅ Bus booking notification event added to bloc');
      } catch (notificationError) {
        print('❌ Error adding bus booking notification: $notificationError');
      }

      emit(const BusBookingSuccess('Bus booking created successfully!'));

    } catch (e) {
      print('❌ Bus booking error: $e');

      // ERROR LOCAL NOTIFICATION
      await LocalNotificationService.showCustomNotification(
        title: 'Booking Failed',
        body: 'Bus booking failed: ${e.toString()}',
        payload: 'bus_booking_failed|${event.booking.id}',
      );

      // ERROR FIRESTORE NOTIFICATION
      _notificationBloc.add(AddNotification(
        title: 'Bus Booking Failed',
        message: 'Failed to book bus ticket: ${e.toString()}',
        type: 'bus_booking_failed',
        data: {
          'bookingId': event.booking.id,
          'companyName': event.booking.companyName,
          'error': e.toString(),
          'userId': FirebaseAuth.instance.currentUser!.uid,
        },
      ));

      emit(BusBookingError('Failed to create bus booking: $e'));
    }
  }

  void _onLoadUserBusBookings(LoadUserBusBookings event, Emitter<BusBookingState> emit) async {
    try {
      await emit.forEach<List<BusBookingModel>>(
        _firebaseService.getUserBookings(event.userId),
        onData: (bookings) => UserBusBookingsLoaded(bookings),
        onError: (error, _) => BusBookingError('Failed to load bookings: $error'),
      );
    } catch (e) {
      emit(BusBookingError('Failed to load bookings: $e'));
    }
  }

  // Helper method to build detailed notification message
  String _buildBusBookingNotificationMessage(BusBookingModel booking) {
    final String companyName = booking.companyName;
    final String passengerName = booking.passengerName;
    final String travelDate = booking.travelDate.toString().substring(0, 10); // YYYY-MM-DD format
    final int numberOfPassengers = booking.numberOfPassengers;
    final String seatType = booking.seatType;
    final double baseTicketPrice = booking.baseTicketPrice;
    final double seatUpgradeAmount = booking.seatUpgradeAmount;
    final double taxAmount = booking.taxAmount;
    final double totalAmount = booking.totalAmount;

    return '''Bus ticket booked successfully!

Bus Company: $companyName
Passenger: $passengerName
Travel Date: $travelDate
Passengers: $numberOfPassengers
Seat Type: $seatType

Pricing Breakdown:
Base Ticket Price: \${baseTicketPrice.toStringAsFixed(2)} x $numberOfPassengers
Seat Upgrade: \${seatUpgradeAmount.toStringAsFixed(2)}
Tax & Fees: \${taxAmount.toStringAsFixed(2)}
Total Amount: \${totalAmount.toStringAsFixed(2)}

Booking confirmed at ${DateTime.now().toString().substring(0, 19)}

Have a safe journey!️''';
  }
}