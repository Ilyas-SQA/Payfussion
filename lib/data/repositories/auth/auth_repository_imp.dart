import 'package:dartz/dartz.dart';
import '../../../core/exceptions/failure.dart';
import '../../../domain/repository/auth/auth_repository.dart';
import '../../data_source/auth_remote_data_source.dart';
import '../../models/user/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String newPassword,
    String? oldPassword,
  }) =>
      remoteDataSource.changePassword(
        newPassword: newPassword,
        oldPassword: oldPassword,
      );

  @override
  Future<Either<Failure, Unit>> signUp({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
  }) =>
      remoteDataSource.signUp(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

  @override
  Future<Either<Failure, UserModel>> signInWithEmail(
      String email,
      String password,
      ) async {
    final result =
    await remoteDataSource.signInWithEmail(email, password);

    return result.map(
          (user) => UserModel(
        uid: user.uid,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        profileImageUrl: user.profileImageUrl,
        isEmailVerified: user.isEmailVerified ?? false,
        accountVerified: user.accountVerified ?? false,
        kycVerification: user.kycVerification ?? false,
        suspendAccount: user.suspendAccount ?? false,
        transaction: user.transaction ?? false,
        twoStepAuthentication: user.twoStepAuthentication ?? false,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      ),
    );
  }

  @override
  Stream<UserModel?> get userStream =>
      remoteDataSource.userStream.map(
            (either) => either.fold(
              (_) => null,
              (user) => user == null
              ? null
              : UserModel(
            uid: user.uid,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            phoneNumber: user.phoneNumber,
            profileImageUrl: user.profileImageUrl,
            isEmailVerified: user.isEmailVerified ?? false,
            accountVerified: user.accountVerified ?? false,
            kycVerification: user.kycVerification ?? false,
            suspendAccount: user.suspendAccount ?? false,
            transaction: user.transaction ?? false,
            twoStepAuthentication:
            user.twoStepAuthentication ?? false,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
          ),
        ),
      );

  @override
  Future<UserModel?> getCurrentUser() async {
    final result = await remoteDataSource.getCurrentUser();

    return result.fold(
          (_) => null,
          (user) => user == null
          ? null
          : UserModel(
        uid: user.uid,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        profileImageUrl: user.profileImageUrl,
        isEmailVerified: user.isEmailVerified ?? false,
        accountVerified: user.accountVerified ?? false,
        kycVerification: user.kycVerification ?? false,
        suspendAccount: user.suspendAccount ?? false,
        transaction: user.transaction ?? false,
        twoStepAuthentication:
        user.twoStepAuthentication ?? false,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> signOut() =>
      remoteDataSource.signOut();

  @override
  Future<Either<Failure, Unit>> sendOtpToPhone(String phoneNumber) =>
      remoteDataSource.sendOtpToPhone(phoneNumber);

  @override
  Future<Either<Failure, Unit>> forgotPassworWithEmail(String email) =>
      remoteDataSource.forgotPasswordWithEmail(email);

  @override
  Future<bool> verifyOtp(String otp) async {
    final result = await remoteDataSource.verifyOtp(otp);
    return result.fold((_) => false, (success) => success);
  }

  @override
  Future<Either<Failure, Unit>> signInWithBiometric() =>
      remoteDataSource.signInWithBiometric();

  @override
  Future<Either<Failure, Unit>> updateUserFirstName(String firstName) =>
      remoteDataSource.updateUserFirstName(firstName);

  @override
  Future<Either<Failure, Unit>> updateUserLastName(String lastName) =>
      remoteDataSource.updateUserLastName(lastName);

  @override
  Future<Either<Failure, Unit>> updateUserProfileUrl(String imagePath) =>
      remoteDataSource.updateUserProfileUrl(imagePath);
}

