import 'package:equatable/equatable.dart';

import '../../../../data/models/tickets/flight_model.dart';

abstract class FlightState extends Equatable {
  const FlightState();

  @override
  List<Object> get props => <Object>[];
}

class FlightInitial extends FlightState {}

class FlightLoading extends FlightState {}

class FlightLoaded extends FlightState {
  final List<FlightModel> flights;

  const FlightLoaded(this.flights);

  @override
  List<Object> get props => <Object>[flights];
}

class FlightError extends FlightState {
  final String message;

  const FlightError(this.message);

  @override
  List<Object> get props => <Object>[message];
}

abstract class FlightBookingState extends Equatable {
  const FlightBookingState();

  @override
  List<Object> get props => <Object>[];
}

class FlightBookingInitial extends FlightBookingState {}

class FlightBookingLoading extends FlightBookingState {}

class FlightBookingSuccess extends FlightBookingState {
  final String message;

  const FlightBookingSuccess(this.message);

  @override
  List<Object> get props => <Object>[message];
}

class FlightBookingError extends FlightBookingState {
  final String message;

  const FlightBookingError(this.message);

  @override
  List<Object> get props => <Object>[message];
}

class UserFlightBookingsLoaded extends FlightBookingState {
  final List<FlightBookingModel> bookings;

  const UserFlightBookingsLoaded(this.bookings);

  @override
  List<Object> get props => <Object>[bookings];
}