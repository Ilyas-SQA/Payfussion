import 'package:dartz/dartz.dart';

import '../../core/exceptions/failure.dart';
import '../models/user/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, Unit>> signUp({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
  });

  Future<Either<Failure, UserModel>> signInWithEmail(
    String email,
    String password,
  );

  Stream<Either<Failure, UserModel?>> get userStream;

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, Unit>> sendOtpToPhone(String phoneNumber);

  Future<Either<Failure, Unit>> forgotPasswordWithEmail(String email);

  /// Verifies the OTP and links the phone number to the current user
  Future<Either<Failure, Unit>> linkPhoneNumberWithOtp(String smsCode);

  Future<Either<Failure, bool>> verifyOtp(String otp);

  Future<Either<Failure, Unit>> signInWithBiometric();

  Future<Either<Failure, UserModel?>> getCurrentUser();

  Future<Either<Failure, Unit>> updateUserFirstName(String firstName);

  Future<Either<Failure, Unit>> updateUserLastName(String lastName);

  Future<Either<Failure, Unit>> updateUserProfileUrl(String imagePath);

  /// Optional: Sign in with phone and password (using email lookup)
  Future<Either<Failure, UserModel>> signInWithPhoneAndPassword(
    String phoneNumber,
    String password,
  );

  /// Changes the current user's password. May require reauthentication.
  Future<Either<Failure, Unit>> changePassword({
    required String newPassword,
    String? oldPassword, // Optional: for reauthentication if needed
  });
}
