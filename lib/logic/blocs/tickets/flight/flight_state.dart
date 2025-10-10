import 'package:equatable/equatable.dart';

import '../../../../data/models/tickets/flight_model.dart';

abstract class FlightState extends Equatable {
  const FlightState();

  @override
  List<Object> get props => [];
}

class FlightInitial extends FlightState {}

class FlightLoading extends FlightState {}

class FlightLoaded extends FlightState {
  final List<FlightModel> flights;

  const FlightLoaded(this.flights);

  @override
  List<Object> get props => [flights];
}

class FlightError extends FlightState {
  final String message;

  const FlightError(this.message);

  @override
  List<Object> get props => [message];
}

abstract class FlightBookingState extends Equatable {
  const FlightBookingState();

  @override
  List<Object> get props => [];
}

class FlightBookingInitial extends FlightBookingState {}

class FlightBookingLoading extends FlightBookingState {}

class FlightBookingSuccess extends FlightBookingState {
  final String message;

  const FlightBookingSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class FlightBookingError extends FlightBookingState {
  final String message;

  const FlightBookingError(this.message);

  @override
  List<Object> get props => [message];
}

class UserFlightBookingsLoaded extends FlightBookingState {
  final List<FlightBookingModel> bookings;

  const UserFlightBookingsLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}