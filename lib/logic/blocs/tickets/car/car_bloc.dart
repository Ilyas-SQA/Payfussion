import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/tickets/car_model.dart';
import '../../../../data/repositories/ticket/car_repository.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'car_event.dart';
import 'car_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  final RideFirebaseService _firebaseService;

  RideBloc(this._firebaseService) : super(RideInitial()) {
    on<InitializeRides>(_onInitializeRides);
    on<LoadRides>(_onLoadRides);
  }

  void _onInitializeRides(InitializeRides event, Emitter<RideState> emit) async {
    emit(RideLoading());
    try {
      await _firebaseService.addRidesToUser(FirebaseAuth.instance.currentUser!.uid, usRideServices);
      add(LoadRides());
    } catch (e) {
      emit(RideError('Failed to initialize rides: $e'));
    }
  }

  void _onLoadRides(LoadRides event, Emitter<RideState> emit) async {
    emit(RideLoading());
    try {
      await emit.forEach<List<RideModel>>(
        _firebaseService.getUserRides(FirebaseAuth.instance.currentUser!.uid),
        onData: (rides) => RideLoaded(rides),
        onError: (error, _) => RideError('Failed to load rides: $error'),
      );
    } catch (e) {
      emit(RideError('Failed to load rides: $e'));
    }
  }
}

class RideBookingBloc extends Bloc<RideBookingEvent, RideBookingState> {
  final RideFirebaseService _firebaseService;
  final NotificationBloc _notificationBloc;

  RideBookingBloc(this._firebaseService, this._notificationBloc) : super(RideBookingInitial()) {
    on<CreateRideBooking>(_onCreateRideBooking);
    on<LoadUserRideBookings>(_onLoadUserRideBookings);
  }

  void _onCreateRideBooking(CreateRideBooking event, Emitter<RideBookingState> emit) async {
    emit(RideBookingLoading());
    try {
      print('Creating ride booking...');
      print('Service: ${event.booking.serviceType}');
      print('Driver: ${event.booking.driverName}');
      print('From: ${event.booking.pickupLocation}');
      print('To: ${event.booking.destination}');
      print('Scheduled: ${event.booking.scheduledDateTime}');
      print('Distance: ${event.booking.estimatedDistance} miles');
      print('Total Fare: ${event.booking.estimatedFare}');

      // Add booking to Firestore
      await _firebaseService.addBookingToUser(FirebaseAuth.instance.currentUser!.uid, event.booking);

      // SHOW LOCAL NOTIFICATION
      await LocalNotificationService.showTransactionNotification(
        transactionType: 'sent',
        amount: event.booking.estimatedFare,
        currency: 'USD',
      );

      // ADD FIRESTORE NOTIFICATION
      try {
        print('🔔 Adding ride booking notification to Firestore...');

        final notificationData = {
          'bookingId': event.booking.id,
          'rideId': event.booking.rideId,
          'driverName': event.booking.driverName,
          'serviceType': event.booking.serviceType,
          'passengerName': event.booking.passengerName,
          'passengerPhone': event.booking.passengerPhone,
          'pickupLocation': event.booking.pickupLocation,
          'destination': event.booking.destination,
          'estimatedDistance': event.booking.estimatedDistance,
          'estimatedFare': event.booking.estimatedFare,
          'baseFare': event.booking.baseFare,
          'schedulingFee': event.booking.schedulingFee,
          'taxAmount': event.booking.taxAmount,
          'rideType': event.booking.rideType,
          'scheduledDateTime': event.booking.scheduledDateTime.toIso8601String(),
          'specialInstructions': event.booking.specialInstructions,
          'paymentStatus': event.booking.paymentStatus,
          'bookingDate': event.booking.bookingDate.toIso8601String(),
          'status': event.booking.status,
          'userId': FirebaseAuth.instance.currentUser!.uid,
        };

        print('Ride booking notification data: $notificationData');

        _notificationBloc.add(AddNotification(
          title: 'Ride Booked Successfully!',
          message: _buildRideBookingNotificationMessage(event.booking),
          type: 'ride_booking_success',
          data: notificationData,
        ));

        print('✅ Ride booking notification event added to bloc');
      } catch (notificationError) {
        print('❌ Error adding ride booking notification: $notificationError');
      }

      emit(const RideBookingSuccess('Ride booking created successfully!'));

    } catch (e) {
      print('❌ Ride booking error: $e');

      // ERROR LOCAL NOTIFICATION
      await LocalNotificationService.showCustomNotification(
        title: 'Booking Failed',
        body: 'Ride booking failed: ${e.toString()}',
        payload: 'ride_booking_failed|${event.booking.id}',
      );

      // ERROR FIRESTORE NOTIFICATION
      _notificationBloc.add(AddNotification(
        title: 'Ride Booking Failed',
        message: 'Failed to book ride: ${e.toString()}',
        type: 'ride_booking_failed',
        data: {
          'bookingId': event.booking.id,
          'serviceType': event.booking.serviceType,
          'driverName': event.booking.driverName,
          'error': e.toString(),
          'userId': FirebaseAuth.instance.currentUser!.uid,
        },
      ));

      emit(RideBookingError('Failed to create ride booking: $e'));
    }
  }

  void _onLoadUserRideBookings(LoadUserRideBookings event, Emitter<RideBookingState> emit) async {
    try {
      await emit.forEach<List<RideBookingModel>>(
        _firebaseService.getUserBookings(event.userId),
        onData: (bookings) => UserRideBookingsLoaded(bookings),
        onError: (error, _) => RideBookingError('Failed to load bookings: $error'),
      );
    } catch (e) {
      emit(RideBookingError('Failed to load bookings: $e'));
    }
  }

  // Helper method to build detailed notification message
  String _buildRideBookingNotificationMessage(RideBookingModel booking) {
    final String serviceType = booking.serviceType;
    final String driverName = booking.driverName;
    final String passengerName = booking.passengerName;
    final String pickupLocation = booking.pickupLocation;
    final String destination = booking.destination;
    final String rideType = booking.rideType;
    final String scheduledTime = booking.rideType == 'Now'
        ? 'ASAP'
        : booking.scheduledDateTime.toString().substring(0, 19);
    final double estimatedDistance = booking.estimatedDistance;
    final double baseFare = booking.baseFare;
    final double schedulingFee = booking.schedulingFee;
    final double taxAmount = booking.taxAmount;
    final double estimatedFare = booking.estimatedFare;
    final String specialInstructions = booking.specialInstructions;

    String instructionsText = '';
    if (specialInstructions.isNotEmpty) {
      instructionsText = '\nSpecial Instructions: $specialInstructions';
    }

    return '''Ride booked successfully!

Service: $serviceType
Driver: $driverName
Passenger: $passengerName
Pickup: $pickupLocation
Destination: $destination
Distance: ${estimatedDistance.toStringAsFixed(1)} miles
Ride Type: $rideType
${rideType == 'Now' ? 'Pickup: ASAP' : 'Scheduled: $scheduledTime'}

Pricing Breakdown:
Base Fare: \$${baseFare.toStringAsFixed(2)}
Scheduling Fee: \$${schedulingFee.toStringAsFixed(2)}
Tax & Fees: \$${taxAmount.toStringAsFixed(2)}
Total Fare: \$${estimatedFare.toStringAsFixed(2)}$instructionsText

Booking confirmed at ${DateTime.now().toString().substring(0, 19)}

Your driver will contact you shortly!''';
  }
}

// US Ride Services Data
// List<RideModel> usRideServices = [
//   // Uber Drivers
//   RideModel(
//     id: 'uber_001',
//     driverName: 'Michael Rodriguez',
//     serviceType: 'Uber',
//     carMake: 'Toyota',
//     carModel: 'Camry',
//     carYear: 2022,
//     carColor: 'Silver',
//     licensePlate: 'UBR-1234',
//     phoneNumber: '+1-555-0101',
//     rating: 4.9,
//     totalRides: 2847,
//     baseRate: 1.25,
//     languages: ['English', 'Spanish'],
//     serviceAreas: ['Manhattan', 'Brooklyn', 'Queens', 'Bronx'],
//     specialServices: ['Child Car Seat Available', 'Pet Friendly', 'Airport Pickup'],
//     isAvailable: true,
//   ),
//
//   RideModel(
//     id: 'uber_002',
//     driverName: 'Sarah Johnson',
//     serviceType: 'Uber',
//     carMake: 'Honda',
//     carModel: 'Accord',
//     carYear: 2021,
//     carColor: 'Black',
//     licensePlate: 'UBR-5678',
//     phoneNumber: '+1-555-0102',
//     rating: 4.8,
//     totalRides: 1956,
//     baseRate: 1.30,
//     languages: ['English'],
//     serviceAreas: ['Los Angeles', 'Santa Monica', 'Beverly Hills', 'Hollywood'],
//     specialServices: ['Quiet Ride', 'Phone Charger', 'Bottled Water'],
//     isAvailable: true,
//   ),
//
//   // Lyft Drivers
//   RideModel(
//     id: 'lyft_001',
//     driverName: 'David Chen',
//     serviceType: 'Lyft',
//     carMake: 'Nissan',
//     carModel: 'Altima',
//     carYear: 2023,
//     carColor: 'White',
//     licensePlate: 'LFT-9012',
//     phoneNumber: '+1-555-0201',
//     rating: 4.7,
//     totalRides: 1456,
//     baseRate: 0.95,
//     languages: ['English'],
//     serviceAreas: ['Denver', 'Denver Airport', 'Boulder', 'Colorado Springs'],
//     specialServices: ['Airport Specialist', 'Ski Resort Transport', 'Mountain Weather Expert', 'Large Luggage'],
//     isAvailable: true,
//   ),
// ];