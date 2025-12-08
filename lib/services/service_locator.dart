import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:payfussion/services/payment_service.dart';

import '../../data/data_source/auth_remote_data_source.dart';
import '../../data/data_source/auth_remote_data_source_imp.dart';
import '../../data/repositories/auth/auth_repository_imp.dart';
import '../../data/repositories/setting_repositories/community_forum/forum_post_repository.dart';
import '../../domain/repository/auth/auth_repository.dart';
import '../services/hive_service.dart';
import 'biometric_service.dart';
import 'local_storage.dart';
import 'session_manager_service.dart';

final GetIt getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> init() async {
    try {
      // Initialize Hive first
      await HiveService.init();

      // Core services
      getIt.registerSingleton<HiveService>(HiveService());
      getIt.registerLazySingleton<LocalStorage>(() => LocalStorage());
      getIt.registerSingleton<BiometricService>(BiometricService());
      getIt.registerLazySingleton<SessionController>(() => SessionController());

      getIt.registerLazySingleton<PaymentService>(() => PaymentService());

      // Firebase services
      getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
      getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance,
      );
      getIt.registerLazySingleton<FirebaseStorage>(
        () => FirebaseStorage.instance,
      );

      // Data sources
      getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
          getIt<FirebaseAuth>(),
          getIt<FirebaseFirestore>(),
          getIt<FirebaseStorage>(),
        ),
      );

      // Repositories
      getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
      );
      getIt.registerLazySingleton<ForumPostRepository>(
        () => ForumPostRepository(),
      );
    } catch (e, stack) {
      // Log or handle initialization errors here
      print('ServiceLocator initialization error: $e');
      print(stack);
      rethrow;
    }
  }

  static void reset() {
    getIt.reset();
  }
}
