import 'package:equatable/equatable.dart';

import '../../../../data/models/tickets/car_model.dart';


abstract class RideState extends Equatable {
  const RideState();

  @override
  List<Object> get props => [];
}

class RideInitial extends RideState {}

class RideLoading extends RideState {}

class RideLoaded extends RideState {
  final List<RideModel> rides;

  const RideLoaded(this.rides);

  @override
  List<Object> get props => [rides];
}

class RideError extends RideState {
  final String message;

  const RideError(this.message);

  @override
  List<Object> get props => [message];
}

abstract class RideBookingState extends Equatable {
  const RideBookingState();

  @override
  List<Object> get props => [];
}

class RideBookingInitial extends RideBookingState {}

class RideBookingLoading extends RideBookingState {}

class RideBookingSuccess extends RideBookingState {
  final String message;

  const RideBookingSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class RideBookingError extends RideBookingState {
  final String message;

  const RideBookingError(this.message);

  @override
  List<Object> get props => [message];
}

class UserRideBookingsLoaded extends RideBookingState {
  final List<RideBookingModel> bookings;

  const UserRideBookingsLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}