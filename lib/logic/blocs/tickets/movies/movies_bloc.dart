import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/tickets/movies_model.dart';
import '../../../../data/repositories/ticket/movies_repository.dart';
import '../../../../services/notification_service.dart';
import '../../notification/notification_bloc.dart';
import '../../notification/notification_event.dart';
import 'movies_event.dart';
import 'movies_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieRepository _firebaseService;

  MovieBloc(this._firebaseService) : super(MovieInitial()) {
    on<InitializeMovies>(_onInitializeMovies);
    on<LoadMovies>(_onLoadMovies);
  }

  void _onInitializeMovies(InitializeMovies event, Emitter<MovieState> emit) async {
    emit(MovieLoading());
    try {
      await _firebaseService.addMoviesToUser(FirebaseAuth.instance.currentUser!.uid, usMovieServices);
      add(LoadMovies());
    } catch (e) {
      emit(MovieError('Failed to initialize movies: $e'));
    }
  }

  void _onLoadMovies(LoadMovies event, Emitter<MovieState> emit) async {
    emit(MovieLoading());
    try {
      await emit.forEach<List<MovieModel>>(
        _firebaseService.getUserMovies(FirebaseAuth.instance.currentUser!.uid),
        onData: (List<MovieModel> movies) => MovieLoaded(movies),
        onError: (Object error, _) => MovieError('Failed to load movies: $error'),
      );
    } catch (e) {
      emit(MovieError('Failed to load movies: $e'));
    }
  }
}

class MovieBookingBloc extends Bloc<MovieBookingEvent, MovieBookingState> {
  final MovieRepository _firebaseService;
  final NotificationBloc _notificationBloc;

  MovieBookingBloc(this._firebaseService, this._notificationBloc) : super(MovieBookingInitial()) {
    on<CreateMovieBooking>(_onCreateMovieBooking);
    on<LoadUserMovieBookings>(_onLoadUserMovieBookings);
  }

  void _onCreateMovieBooking(CreateMovieBooking event, Emitter<MovieBookingState> emit) async {
    emit(MovieBookingLoading());
    try {
      print('🎬 Creating movie booking...');
      print('Movie: ${event.booking.movieTitle}');
      print('Date: ${event.booking.showDate}');
      print('Time: ${event.booking.showtime}');
      print('Seats: ${event.booking.seatType}');
      print('Total Amount: ${event.booking.totalAmount}');

      // Add booking to Firestore
      await _firebaseService.addBookingToUser(FirebaseAuth.instance.currentUser!.uid, event.booking);

      // SHOW LOCAL NOTIFICATION
      await LocalNotificationService.showTransactionNotification(
        transactionType: 'sent',
        amount: event.booking.totalAmount ?? 0.0,
        currency: 'USD', // or get from booking if available
      );

      // ADD FIRESTORE NOTIFICATION
      try {
        print('🔔 Adding movie booking notification to Firestore...');

        final Map<String, Object> notificationData = <String, Object>{
          'bookingId': event.booking.id,
          'movieId': event.booking.movieId,
          'movieTitle': event.booking.movieTitle,
          'cinemaChain': event.booking.cinemaChain,
          'customerName': event.booking.customerName,
          'email': event.booking.email,
          'phone': event.booking.phone,
          'showDate': event.booking.showDate.toIso8601String(),
          'showtime': event.booking.showtime,
          'numberOfTickets': event.booking.numberOfTickets,
          'seatType': event.booking.seatType,
          'totalAmount': event.booking.totalAmount,
          'baseTicketPrice': event.booking.baseTicketPrice,
          'seatUpgradeAmount': event.booking.seatUpgradeAmount,
          'taxAmount': event.booking.taxAmount,
          'paymentStatus': event.booking.paymentStatus,
          'bookingDate': event.booking.bookingDate.toIso8601String(),
          'userId': FirebaseAuth.instance.currentUser!.uid,
        };

        print('Movie booking notification data: $notificationData');

        _notificationBloc.add(AddNotification(
          title: 'Movie Ticket Booked Successfully!',
          message: _buildMovieBookingNotificationMessage(event.booking),
          type: 'movie_booking_success',
          data: notificationData,
        ));

        print('✅ Movie booking notification event added to bloc');
      } catch (notificationError) {
        print('❌ Error adding movie booking notification: $notificationError');
      }

      emit(const MovieBookingSuccess('Movie booking created successfully!'));

    } catch (e) {
      print('❌ Movie booking error: $e');

      // ERROR LOCAL NOTIFICATION
      await LocalNotificationService.showCustomNotification(
        title: 'Booking Failed',
        body: 'Movie booking failed: ${e.toString()}',
        payload: 'movie_booking_failed|${event.booking.id ?? "unknown"}',
      );

      // ERROR FIRESTORE NOTIFICATION
      _notificationBloc.add(AddNotification(
        title: 'Movie Booking Failed',
        message: 'Failed to book movie ticket: ${e.toString()}',
        type: 'movie_booking_failed',
        data: <String, dynamic>{
          'bookingId': event.booking.id,
          'movieTitle': event.booking.movieTitle,
          'error': e.toString(),
          'userId': FirebaseAuth.instance.currentUser!.uid,
        },
      ));

      emit(MovieBookingError('Failed to create movie booking: $e'));
    }
  }

  void _onLoadUserMovieBookings(LoadUserMovieBookings event, Emitter<MovieBookingState> emit) async {
    try {
      await emit.forEach<List<MovieBookingModel>>(
        _firebaseService.getUserBookings(event.userId),
        onData: (List<MovieBookingModel> bookings) => UserMovieBookingsLoaded(bookings),
        onError: (Object error, _) => MovieBookingError('Failed to load bookings: $error'),
      );
    } catch (e) {
      emit(MovieBookingError('Failed to load bookings: $e'));
    }
  }

  // Helper method to build detailed notification message
  String _buildMovieBookingNotificationMessage(MovieBookingModel booking) {
    final String movieTitle = booking.movieTitle;
    final String cinemaChain = booking.cinemaChain;
    final String showDate = booking.showDate.toString().substring(0, 10); // YYYY-MM-DD format
    final String showtime = booking.showtime;
    final int numberOfTickets = booking.numberOfTickets;
    final String seatType = booking.seatType;
    final double basePrice = booking.baseTicketPrice;
    final double upgradeAmount = booking.seatUpgradeAmount;
    final double taxAmount = booking.taxAmount;
    final double totalAmount = booking.totalAmount;

    return '''Movie ticket booked successfully!

Movie: $movieTitle
Cinema: $cinemaChain
Date: $showDate
Time: $showtime
Tickets: $numberOfTickets x $seatType
Customer: ${booking.customerName}

Pricing Breakdown:
Base Price: \${basePrice.toStringAsFixed(2)} x $numberOfTickets
Seat Upgrade: \${upgradeAmount.toStringAsFixed(2)}
Tax: \${taxAmount.toStringAsFixed(2)}
Total Amount: \${totalAmount.toStringAsFixed(2)}

Booking confirmed at ${DateTime.now().toString().substring(0, 19)}

Enjoy your movie!''';
  }
}