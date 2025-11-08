import 'package:dartz/dartz.dart';

import '../../../core/exceptions/failure.dart';
import '../../../domain/repository/auth/auth_repository.dart';
import '../../data_source/auth_remote_data_source.dart';
import '../../models/user/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, Unit>> changePassword({
    required String newPassword,
    String? oldPassword,
  }) => remoteDataSource.changePassword(
    newPassword: newPassword,
    oldPassword: oldPassword,
  );
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Unit>> signUp({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String phoneNumber,
  }) => remoteDataSource.signUp(
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
    final Either<Failure, UserModel> result = await remoteDataSource.signInWithEmail(email, password);
    return result.map(
      (UserModel user) => UserModel(
        uid: user.uid,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        profileImageUrl: user.profileImageUrl,
        fullName: '${user.firstName} ${user.lastName}'.trim(),
        createdAt: user.createdAt,
        isEmailVerified: user.isEmailVerified ?? false,
        transaction: user.transaction ?? false,
        twoStepAuthentication: user.twoStepAuthentication ?? false,
      ),
    );
  }

  @override
  Stream<UserModel?> get userStream => remoteDataSource.userStream.map(
    (Either<Failure, UserModel?> either) => either.fold(
      (Failure failure) => null,
      (UserModel? user) => user == null ?
      null :
      UserModel(
        uid: user.uid,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        profileImageUrl: user.profileImageUrl,
        fullName: '${user.firstName} ${user.lastName}'.trim(),
        createdAt: user.createdAt,
        isEmailVerified: user.isEmailVerified ?? false,
        transaction: user.transaction ?? false,
        twoStepAuthentication: user.twoStepAuthentication ?? false,
      ),
    ),
  );

  @override
  Future<Either<Failure, Unit>> signOut() => remoteDataSource.signOut();

  @override
  Future<Either<Failure, Unit>> sendOtpToPhone(String phoneNumber) => remoteDataSource.sendOtpToPhone(phoneNumber);

  @override
  Future<Either<Failure, Unit>> forgotPassworWithEmail(String email) => remoteDataSource.forgotPasswordWithEmail(email);

  @override
  Future<bool> verifyOtp(String otp) async {
    final Either<Failure, bool> result = await remoteDataSource.verifyOtp(otp);
    return result.fold((Failure failure) => false, (bool success) => success);
  }

  @override
  Future<Either<Failure, Unit>> signInWithBiometric() => remoteDataSource.signInWithBiometric();

  @override
  Future<UserModel?> getCurrentUser() async {
    final Either<Failure, UserModel?> result = await remoteDataSource.getCurrentUser();
    return result.fold(
      (Failure failure) => null,
      (UserModel? user) => user == null ?
      null :
      UserModel(
        uid: user.uid,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        profileImageUrl: user.profileImageUrl,
        fullName: '${user.firstName} ${user.lastName}'.trim(),
        createdAt: user.createdAt,
        isEmailVerified: user.isEmailVerified ?? false,
        transaction: user.transaction ?? false,
        twoStepAuthentication: user.twoStepAuthentication ?? false,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> updateUserFirstName(String firstName) => remoteDataSource.updateUserFirstName(firstName);

  @override
  Future<Either<Failure, Unit>> updateUserLastName(String lastName) => remoteDataSource.updateUserLastName(lastName);

  @override
  Future<Either<Failure, Unit>> updateUserProfileUrl(String imagePath) => remoteDataSource.updateUserProfileUrl(imagePath);
}
