import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failure.dart';
import '../../../data/models/user/user_model.dart';

abstract class AuthRepository {
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

  Stream<UserModel?> get userStream;

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, Unit>> sendOtpToPhone(String phoneNumber);

  Future<Either<Failure, Unit>> forgotPassworWithEmail(String email);

  Future<bool> verifyOtp(String otp);

  Future<Either<Failure, Unit>> signInWithBiometric();

  Future<UserModel?> getCurrentUser();

  Future<Either<Failure, Unit>> updateUserFirstName(String firstName);

  Future<Either<Failure, Unit>> updateUserLastName(String lastName);

  Future<Either<Failure, Unit>> updateUserProfileUrl(String imagePath);
  Future<Either<Failure, Unit>> changePassword({
    required String newPassword,
    String? oldPassword,
  });
}
