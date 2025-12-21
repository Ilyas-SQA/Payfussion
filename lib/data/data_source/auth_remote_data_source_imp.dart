import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/exceptions/auth_exception.dart';
import '../../core/exceptions/failure.dart';
import '../../services/service_locator.dart';
import '../../services/session_manager_service.dart';
import '../models/user/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<Either<Failure, Unit>> changePassword({
    required String newPassword,
    String? oldPassword,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return left(AuthFailure('No authenticated user.'));

      // If oldPassword is provided, reauthenticate first
      if (oldPassword != null && user.email != null) {
        final AuthCredential cred = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );
        await user.reauthenticateWithCredential(cred);
      }

      await user.updatePassword(newPassword);
      return right(unit);
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure(TFirebaseAuthException(e.code).message));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  String? _verificationId;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final SessionController _userSession = getIt<SessionController>();

  AuthRemoteDataSourceImpl(this._auth, this._firestore, this._storage);
  Future<Either<Failure, Unit>> _updateUserField(
    String field,
    String value,
  ) async {
    try {
      final String uid = _auth.currentUser!.uid;

      // Update Firestore with the new field value
      await _firestore.collection('users').doc(uid).update(<Object, Object?>{field: value});

      // Update SessionController to keep user data in sync
      final UserModel updatedUser = SessionController.user;
      if (field == 'firstName') {
        updatedUser.firstName = value;
      } else if (field == 'lastName') {
        updatedUser.lastName = value;
      } else if (field == 'profileUrl') {
        updatedUser.profileImageUrl = value;
      }

      // Save the updated user in local storage (SessionController)
      await _userSession.saveUserInPreference(updatedUser.toJson());

      return right(unit); // Return success with Unit
    } catch (e) {
      return left(
        AuthFailure(e.toString()),
      ); // Return failure with error message
    }
  }

  @override
  Future<Either<Failure, Unit>> signUp({required String firstName, required String lastName, required String email, required String phoneNumber, required String password,}) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user == null) return left(AuthFailure('User creation failed.'));

      await user.sendEmailVerification();

      await _firestore.collection('users').doc(user.uid).set(<String, dynamic>{
        'profileUrl': '',
        'uid': user.uid,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'isEmailVerified': false,
        "transaction": true,
        "twoStepAuthentication": false,
        "kycVerification": false,
        "suspendAccount": false,
        "accountVerified": false,
        'createdAt': FieldValue.serverTimestamp(),
        'updateAt': FieldValue.serverTimestamp(),
      });
      // await user.sendEmailVerification();

      // // Send OTP to phone
      // // final completer = Completer<Unit>();
      // // await _auth.verifyPhoneNumber(
      // //   phoneNumber: phoneNumber,
      // //   verificationCompleted: (PhoneAuthCredential credential) async {
      // //     await user.linkWithCredential(credential);
      // //     completer.complete(unit);
      // //   },
      // //   verificationFailed: (FirebaseAuthException e) {
      // //     completer.completeError(
      // //       AuthFailure(e.message ?? 'Verification failed'),
      // //     );
      // //   },
      // //   codeSent: (String verId, int? resendToken) {
      // //     _verificationId = verId;
      // //     completer.complete(unit); // Signal to UI to show OTP input
      // //   },
      // //   codeAutoRetrievalTimeout: (String verId) {
      // //     _verificationId = verId;
      // //   },
      // // );
      // // await completer.future;

      // Do NOT store in Firestore here
      return right(unit);
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure(TFirebaseAuthException(e.code).message));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  // Replace your existing signInWithEmail method in AuthRemoteDataSourceImpl

  @override
  Future<Either<Failure, UserModel>> signInWithEmail(
      String email,
      String password,
      ) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        return left(AuthFailure('Sign in failed. User is null.'));
      }

      // Check if email is verified
      if (!user.emailVerified) {
        // Send verification email again
        try {
          await user.sendEmailVerification();
        } catch (e) {
          // Ignore if email already sent
        }

        // Don't sign out here - let the bloc handle it
        // This way we can get the user info for the verification screen
        return left(AuthFailure(
          'Email not verified. Please check your email and verify your account before logging in.',
        ));
      }

      // Get user document from Firestore
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
      await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        return left(AuthFailure('User data not found in database.'));
      }

      final userData = userDoc.data()!;

      // Check if account is suspended
      if (userData['suspendAccount'] == true) {
        await _auth.signOut();
        return left(AuthFailure(
          'Your account has been suspended. Please contact support at support@payfussion.com for assistance.',
        ));
      }

      // Check if account is verified by admin
      if (userData['accountVerified'] == false) {
        await _auth.signOut();
        return left(AuthFailure(
          'Your account is pending admin approval. You will receive a notification once your account is verified. Please contact support if you have questions.',
        ));
      }

      // Update email verified status in Firestore if needed
      if (userData['isEmailVerified'] != true) {
        await _firestore.collection('users').doc(user.uid).update({
          'isEmailVerified': true,
          'updateAt': FieldValue.serverTimestamp(),
        });
        userData['isEmailVerified'] = true;
      }

      // Update last login time
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
        'updateAt': FieldValue.serverTimestamp(),
      });

      return right(UserModel.fromJson(userData));
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure(TFirebaseAuthException(e.code).message));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithPhoneAndPassword(String phoneNumber, String password,) async {
    try {
      // Lookup email by phone number in Firestore
      final QuerySnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (userDoc.docs.isEmpty) {
        return left(AuthFailure('Phone number not found'));
      }
      final email = userDoc.docs.first['email'];

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user == null) {
        return left(AuthFailure('Sign in failed. User is null.'));
      }
      final DocumentSnapshot<Map<String, dynamic>> userDocData = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDocData.exists) {
        return right(UserModel.fromJson(userDocData.data()!));
      } else {
        return left(AuthFailure('User data not found.'));
      }
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure(TFirebaseAuthException(e.code).message));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, UserModel?>> get userStream =>
      _auth.authStateChanges().asyncMap((User? user) async {
        if (user == null) return right(null);
        try {
          final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
              .collection('users')
              .doc(user.uid)
              .get();
          if (userDoc.exists) {
            return right(UserModel.fromJson(userDoc.data()!));
          }
          return right(null);
        } catch (e) {
          return left(AuthFailure(e.toString()));
        }
      });

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _auth.signOut();
      return right(unit);
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendOtpToPhone(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw TFirebaseAuthException(e.code);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return right(unit);
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure(TFirebaseAuthException(e.code).message));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> forgotPasswordWithEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return right(unit);
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure(TFirebaseAuthException(e.code).message));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp(String otp) async {
    try {
      if (_verificationId == null) {
        return left(
          AuthFailure('No verificationId. Please request OTP first.'),
        );
      }
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return right(userCredential.user != null);
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure(TFirebaseAuthException(e.code).message));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> linkPhoneNumberWithOtp(String smsCode) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return left(AuthFailure('No authenticated user.'));
      if (_verificationId == null)
        return left(AuthFailure('No verificationId.'));
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await user.linkWithCredential(credential);

      // Optionally, update Firestore or perform additional logic here if needed.

      return right(unit);
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure(TFirebaseAuthException(e.code).message));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signInWithBiometric() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return right(unit);
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel?>> getCurrentUser() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return right(null);
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return right(UserModel.fromJson(userDoc.data()!));
      }
      return right(null);
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUserFirstName(String firstName) async {
    return _updateUserField('firstName', firstName);
  }

  @override
  Future<Either<Failure, Unit>> updateUserLastName(String lastName) async {
    return _updateUserField('lastName', lastName);
  }

  @override
  Future<Either<Failure, Unit>> updateUserProfileUrl(String imagePath) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return left(PlatformFailure('No authenticated user.'));
      final File file = File(imagePath);
      if (!file.existsSync()) {
        return left(FormatFailure('Selected image file does not exist.'));
      }
      final Reference ref = _storage
          .ref()
          .child('user_profiles')
          .child('${user.uid}.jpg');
      await ref.putFile(file);
      final String imageUrl = await ref.getDownloadURL();
      return _updateUserField('profileUrl', imageUrl);
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }
}
