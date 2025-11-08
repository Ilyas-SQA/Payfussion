import 'package:equatable/equatable.dart';

import '../../../../data/models/tickets/car_model.dart';

abstract class RideEvent extends Equatable {
  const RideEvent();

  @override
  List<Object> get props => <Object>[];
}

class LoadRides extends RideEvent {}

class InitializeRides extends RideEvent {}

abstract class RideBookingEvent extends Equatable {
  const RideBookingEvent();

  @override
  List<Object> get props => <Object>[];
}

class CreateRideBooking extends RideBookingEvent {
  final RideBookingModel booking;

  const CreateRideBooking(this.booking);

  @override
  List<Object> get props => <Object>[booking];
}

class LoadUserRideBookings extends RideBookingEvent {
  final String userId;

  const LoadUserRideBookings(this.userId);

  @override
  List<Object> get props => <Object>[userId];
}
