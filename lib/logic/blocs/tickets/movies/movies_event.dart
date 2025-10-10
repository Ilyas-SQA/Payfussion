import 'package:equatable/equatable.dart';

import '../../../../data/models/tickets/movies_model.dart';

abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object> get props => [];
}

class LoadMovies extends MovieEvent {}

class InitializeMovies extends MovieEvent {}

abstract class MovieBookingEvent extends Equatable {
  const MovieBookingEvent();

  @override
  List<Object> get props => [];
}

class CreateMovieBooking extends MovieBookingEvent {
  final MovieBookingModel booking;

  const CreateMovieBooking(this.booking);

  @override
  List<Object> get props => [booking];
}

class LoadUserMovieBookings extends MovieBookingEvent {
  final String userId;

  const LoadUserMovieBookings(this.userId);

  @override
  List<Object> get props => [userId];
}
