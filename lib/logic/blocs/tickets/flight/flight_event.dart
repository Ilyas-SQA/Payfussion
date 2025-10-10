import 'package:equatable/equatable.dart';

import '../../../../data/models/tickets/flight_model.dart';

abstract class FlightEvent extends Equatable {
  const FlightEvent();

  @override
  List<Object> get props => [];
}

class LoadFlights extends FlightEvent {}

class InitializeFlights extends FlightEvent {}

abstract class FlightBookingEvent extends Equatable {
  const FlightBookingEvent();

  @override
  List<Object> get props => [];
}

class CreateFlightBooking extends FlightBookingEvent {
  final FlightBookingModel booking;

  const CreateFlightBooking(this.booking);

  @override
  List<Object> get props => [booking];
}

class LoadUserFlightBookings extends FlightBookingEvent {
  final String userId;

  const LoadUserFlightBookings(this.userId);

  @override
  List<Object> get props => [userId];
}