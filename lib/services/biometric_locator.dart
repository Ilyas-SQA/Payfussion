import 'package:payfussion/services/service_locator.dart';

import 'biometric_service.dart';
import 'local_storage.dart';

void setupLocator() {
  // Your existing registrations...
  getIt.registerLazySingleton<LocalStorage>(() => LocalStorage());
  getIt.registerLazySingleton<BiometricService>(() => BiometricService());
}