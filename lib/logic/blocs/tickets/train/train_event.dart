import 'package:equatable/equatable.dart';

import '../../../../data/models/tickets/train_model.dart';

abstract class TrainEvent extends Equatable {
  const TrainEvent();

  @override
  List<Object> get props => <Object>[];
}

class LoadTrains extends TrainEvent {}

class InitializeTrains extends TrainEvent {}

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object> get props => <Object>[];
}

class CreateBooking extends BookingEvent {
  final BookingModel booking;

  const CreateBooking(this.booking);

  @override
  List<Object> get props => <Object>[booking];
}

class LoadUserBookings extends BookingEvent {
  final String email;

  const LoadUserBookings(this.email);

  @override
  List<Object> get props => <Object>[email];
}
