import 'package:equatable/equatable.dart';

import '../../../../data/models/tickets/flight_model.dart';

abstract class FlightEvent extends Equatable {
  const FlightEvent();

  @override
  List<Object> get props => <Object>[];
}

class LoadFlights extends FlightEvent {}

class InitializeFlights extends FlightEvent {}

abstract class FlightBookingEvent extends Equatable {
  const FlightBookingEvent();

  @override
  List<Object> get props => <Object>[];
}

class CreateFlightBooking extends FlightBookingEvent {
  final FlightBookingModel booking;

  const CreateFlightBooking(this.booking);

  @override
  List<Object> get props => <Object>[booking];
}

class LoadUserFlightBookings extends FlightBookingEvent {
  final String userId;

  const LoadUserFlightBookings(this.userId);

  @override
  List<Object> get props => <Object>[userId];
}