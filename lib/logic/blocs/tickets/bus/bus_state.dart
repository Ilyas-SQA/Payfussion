import 'package:equatable/equatable.dart';

import '../../../../data/models/tickets/bus_model.dart';

abstract class BusState extends Equatable {
  const BusState();

  @override
  List<Object> get props => [];
}

class BusInitial extends BusState {}

class BusLoading extends BusState {}

class BusLoaded extends BusState {
  final List<BusModel> buses;

  const BusLoaded(this.buses);

  @override
  List<Object> get props => [buses];
}

class BusError extends BusState {
  final String message;

  const BusError(this.message);

  @override
  List<Object> get props => [message];
}

abstract class BusBookingState extends Equatable {
  const BusBookingState();

  @override
  List<Object> get props => [];
}

class BusBookingInitial extends BusBookingState {}

class BusBookingLoading extends BusBookingState {}

class BusBookingSuccess extends BusBookingState {
  final String message;

  const BusBookingSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class BusBookingError extends BusBookingState {
  final String message;

  const BusBookingError(this.message);

  @override
  List<Object> get props => [message];
}

class UserBusBookingsLoaded extends BusBookingState {
  final List<BusBookingModel> bookings;

  const UserBusBookingsLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}
