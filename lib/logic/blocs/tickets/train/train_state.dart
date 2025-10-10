import 'package:equatable/equatable.dart';

import '../../../../data/models/tickets/train_model.dart';

abstract class TrainState extends Equatable {
  const TrainState();

  @override
  List<Object> get props => [];
}

class TrainInitial extends TrainState {}

class TrainLoading extends TrainState {}

class TrainLoaded extends TrainState {
  final List<TrainModel> trains;

  const TrainLoaded(this.trains);

  @override
  List<Object> get props => [trains];
}

class TrainError extends TrainState {
  final String message;

  const TrainError(this.message);

  @override
  List<Object> get props => [message];
}

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final String message;

  const BookingSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object> get props => [message];
}

class UserBookingsLoaded extends BookingState {
  final List<BookingModel> bookings;

  const UserBookingsLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}
