import 'package:equatable/equatable.dart';

abstract class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object?> get props => [];
}

class SubmitChangePasswordEvent extends ChangePasswordEvent {
  final String oldPassword;
  final String newPassword;

  const SubmitChangePasswordEvent({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}

// New event to indicate password fields have changed, for validation
class PasswordFieldsChangedEvent extends ChangePasswordEvent {
  final String newPassword;
  final String confirmNewPassword;
  // You could also pass oldPassword if you want to validate it dynamically
  // final String oldPassword;

  const PasswordFieldsChangedEvent({
    required this.newPassword,
    required this.confirmNewPassword,
    // required this.oldPassword,
  });

  @override
  List<Object?> get props => [newPassword, confirmNewPassword];
}

// Optional: Event to clear specific UI errors if needed
class ClearPasswordMismatchErrorEvent extends ChangePasswordEvent {}
