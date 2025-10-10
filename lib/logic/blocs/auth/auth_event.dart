import 'package:image_picker/image_picker.dart' show XFile;

import '../setting/setting_event.dart';

abstract class AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;

  SignUpRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
  });
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  final bool enableBiometric;

  SignInRequested({
    required this.email,
    required this.password,
    this.enableBiometric = false,
  });
}

class UpdateFirstName extends AuthEvent {
  final String firstName;
  UpdateFirstName({required this.firstName});
}

// Event for updating the last name
class UpdateLastName extends AuthEvent {
  final String lastName;
  UpdateLastName({required this.lastName});
}

class UpdateProfileImage extends AuthEvent {
  final XFile? profileImage;
  UpdateProfileImage({this.profileImage});
}

class RequestOtp extends AuthEvent {
  final String input;

  RequestOtp({required this.input});
}

class VerifyOtp extends AuthEvent {
  final String otp;

  VerifyOtp({required this.otp});
}

class ForgotPasswordWithEmail extends AuthEvent {
  final String email;

  ForgotPasswordWithEmail({required this.email});
}

class Logout extends AuthEvent {}

class EnableBiometriCheckbox extends AuthEvent {
  final bool isEnabled;

  EnableBiometriCheckbox(this.isEnabled);
}

class CheckBiometricAvailability extends AuthEvent {}

// class BiometricSignInRequested extends AuthEvent {
//   String email, password;
//   BiometricSignInRequested({required this.email, required this.password});
// }

class TransactionWithBiometrics extends AuthEvent {
  final String transactionDetails;

  TransactionWithBiometrics({required this.transactionDetails});
}

class BiometricSettingChanged extends SettingsEvent {
  final bool enabled;

  const BiometricSettingChanged(this.enabled);
}

class LoginWithBiometric extends AuthEvent {}

class SendOtpEvent extends AuthEvent {
  final String phoneNumber;
  SendOtpEvent({required this.phoneNumber});
}

class VerifyOtpEvent extends AuthEvent {
  final String otp;
  final String verificationId;
  VerifyOtpEvent({required this.otp, required this.verificationId});
}

class ResendOtpEvent extends AuthEvent {
  final String phoneNumber;
  ResendOtpEvent({required this.phoneNumber});
}
