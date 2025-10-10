import 'package:equatable/equatable.dart';

import '../../../../data/models/tickets/bus_model.dart';

abstract class BusEvent extends Equatable {
  const BusEvent();

  @override
  List<Object> get props => [];
}

class LoadBuses extends BusEvent {}

class InitializeBuses extends BusEvent {}

abstract class BusBookingEvent extends Equatable {
  const BusBookingEvent();

  @override
  List<Object> get props => [];
}

class CreateBusBooking extends BusBookingEvent {
  final BusBookingModel booking;

  const CreateBusBooking(this.booking);

  @override
  List<Object> get props => [booking];
}

class LoadUserBusBookings extends BusBookingEvent {
  final String userId;

  const LoadUserBusBookings(this.userId);

  @override
  List<Object> get props => [userId];
}
