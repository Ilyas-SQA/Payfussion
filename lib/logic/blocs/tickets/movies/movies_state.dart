import 'package:equatable/equatable.dart';

import '../../../../data/models/tickets/movies_model.dart';


abstract class MovieState extends Equatable {
  const MovieState();

  @override
  List<Object> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List<MovieModel> movies;

  const MovieLoaded(this.movies);

  @override
  List<Object> get props => [movies];
}

class MovieError extends MovieState {
  final String message;

  const MovieError(this.message);

  @override
  List<Object> get props => [message];
}

abstract class MovieBookingState extends Equatable {
  const MovieBookingState();

  @override
  List<Object> get props => [];
}

class MovieBookingInitial extends MovieBookingState {}

class MovieBookingLoading extends MovieBookingState {}

class MovieBookingSuccess extends MovieBookingState {
  final String message;

  const MovieBookingSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class MovieBookingError extends MovieBookingState {
  final String message;

  const MovieBookingError(this.message);

  @override
  List<Object> get props => [message];
}

class UserMovieBookingsLoaded extends MovieBookingState {
  final List<MovieBookingModel> bookings;

  const UserMovieBookingsLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}