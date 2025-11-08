import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payfussion/core/exceptions/failure.dart';
import 'package:payfussion/domain/repository/auth/auth_repository.dart';
import 'package:payfussion/logic/blocs/setting/user_profile/profile_event.dart';
import 'package:payfussion/logic/blocs/setting/user_profile/profile_state.dart';

import '../../../../services/service_locator.dart';
import '../../../../services/session_manager_service.dart';


class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository authRepository;
  final SessionController _session = getIt<SessionController>();

  ProfileBloc({required this.authRepository}) : super(ProfileInitial()) {
    on<UpdateFirstName>(_handleUpdateFirstName);
    on<UpdateLastName>(_handleUpdateLastName);
    on<UpdateProfileImage>(_handleUpdateProfileImage);
    on<Logout>(_handleLogout);
  }

  // Centralized error handler
  void _emitError(Emitter<ProfileState> emit, String message) {
    emit(ProfileFailure(message));
  }

  // Centralized loading handler
  void _emitLoading(Emitter<ProfileState> emit) {
    emit(ProfileLoading());
  }

  // Handles success and failure from an Either result
  void _handleEither<E, F>(
    Either<F, E> result,
    Emitter<ProfileState> emit,
    Function(F) onFailure,
    Function(E) onSuccess,
  ) {
    result.fold(
      (failure) => onFailure(failure),
      (success) => onSuccess(success),
    );
  }

  Future<void> _handleLogout(Logout event, Emitter<ProfileState> emit) async {
    _emitLoading(emit);
    try {
      // FIRST: Mark device as inactive before signing out
      await _markCurrentDeviceInactive();

      // THEN: Sign out the user
      final Either<Failure, Unit> result = await authRepository.signOut();
      await result.fold((Failure failure) async => _emitError(emit, failure.message), (
          _,
          ) async {
        await _session.clearUserPreference();
        FirebaseAuth.instance.currentUser?.reload();
        emit(LogoutSuccess());
      });
    } catch (e) {
      _emitError(emit, "An unexpected error occurred: ${e.toString()}");
    }
  }

  Future<void> _markCurrentDeviceInactive() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final String currentDeviceId = await _getDeviceId();

        // Use FirebaseFirestore directly with proper error handling
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('devices')
            .doc(currentDeviceId)
            .update(<Object, Object?>{
          'isActive': false,
          'lastLogin': DateTime.now().toIso8601String(),
        });

        print('✅ Device marked inactive before logout: $currentDeviceId');
      }
    } catch (deviceError) {
      print('❌ Warning: Could not mark device inactive: $deviceError');
      // Don't throw the error - continue with logout even if device update fails
    }
  }

  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final AndroidDeviceInfo info = await deviceInfo.androidInfo;
      return info.id;
    } else {
      final IosDeviceInfo info = await deviceInfo.iosInfo;
      return info.identifierForVendor ?? "unknown";
    }
  }


  Future<void> _handleUpdateFirstName(
    UpdateFirstName event,
    Emitter<ProfileState> emit,
  ) async {
    _emitLoading(emit);
    try {
      final Either<Failure, Unit> result = await authRepository.updateUserFirstName(event.firstName);
      _handleEither(
        result,
        emit,
        (Failure failure) =>
            _emitError(emit, "Failed to update first name: ${failure.message}"),
        (_) => emit(ProfileSucess()),
      );
    } catch (e) {
      _emitError(emit, "Error updating first name: ${e.toString()}");
    }
  }

  Future<void> _handleUpdateLastName(
    UpdateLastName event,
    Emitter<ProfileState> emit,
  ) async {
    _emitLoading(emit);
    try {
      final Either<Failure, Unit> result = await authRepository.updateUserLastName(event.lastName);
      _handleEither(
        result,
        emit,
        (Failure failure) =>
            _emitError(emit, "Failed to update last name: ${failure.message}"),
        (_) => emit(ProfileSucess()),
      );
    } catch (e) {
      _emitError(emit, "Error updating last name: ${e.toString()}");
    }
  }

  Future<void> _handleUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<ProfileState> emit,
  ) async {
    _emitLoading(emit);
    try {
      final Either<Failure, Unit> result = await authRepository.updateUserProfileUrl(
        event.profileImage!.path,
      );
      _handleEither(
        result,
        emit,
        (Failure failure) => _emitError(
          emit,
          "Failed to update profile image: ${failure.message}",
        ),
        (_) => emit(ProfileSucess()),
      );
    } catch (e) {
      _emitError(emit, "Error updating profile image: ${e.toString()}");
    }
  }
}
