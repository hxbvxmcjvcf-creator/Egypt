// ─────────────────────────────────────────────────────────────────────────────
// lib/core/di/injection_container.dart
//
// Single source-of-truth for all DI wiring.
// To toggle Firebase ↔ Mock:
//   flutter run --dart-define=USE_MOCK=false   (Firebase — production)
//   flutter run --dart-define=USE_MOCK=true    (Mock — development, default)
// ─────────────────────────────────────────────────────────────────────────────
import 'package:get_it/get_it.dart';

import 'package:edu_auth/core/config/environment_config.dart';
import 'package:edu_auth/core/feature_flags/feature_flag_service.dart';
import 'package:edu_auth/core/logging/app_logger.dart';
import 'package:edu_auth/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:edu_auth/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:edu_auth/features/auth/domain/repositories/auth_repository.dart';
import 'package:edu_auth/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:edu_auth/features/auth/domain/usecases/link_teacher_usecase.dart';
import 'package:edu_auth/features/auth/domain/usecases/login_usecase.dart';
import 'package:edu_auth/features/auth/domain/usecases/logout_usecase.dart';
import 'package:edu_auth/features/auth/domain/usecases/register_student_usecase.dart';
import 'package:edu_auth/features/auth/domain/usecases/register_teacher_usecase.dart';
import 'package:edu_auth/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:edu_auth/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:edu_auth/services/firebase/firebase_auth_service.dart';
import 'package:edu_auth/services/interfaces/i_auth_service.dart';
import 'package:edu_auth/services/mock/mock_auth_service.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

/// Call once in main() AFTER Firebase.initializeApp().
Future<void> initDependencies() async {
  AppLogger.info('DI: initialising...');

  // 1. Core
  sl.registerLazySingleton<FeatureFlagService>(() {
    final svc = FeatureFlagService()..loadCached();
    return svc;
  });

  // 2. Auth Service — swap without touching anything else
  if (EnvironmentConfig.useMockServices) {
    AppLogger.info('DI: MockAuthService bound');
    sl.registerLazySingleton<IAuthService>(() => MockAuthService());
  } else {
    AppLogger.info('DI: FirebaseAuthService bound');
    sl.registerLazySingleton<IAuthService>(() => FirebaseAuthService());
  }

  // 3. Data Sources
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(sl<IAuthService>()),
  );

  // 4. Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: sl<AuthRemoteDatasource>(),
      flags:  sl<FeatureFlagService>(),
    ),
  );

  // 5. Use Cases (factory = stateless, cheap to create)
  sl.registerFactory<LoginUseCase>(            () => LoginUseCase(sl<AuthRepository>()));
  sl.registerFactory<RegisterStudentUseCase>(  () => RegisterStudentUseCase(sl<AuthRepository>()));
  sl.registerFactory<RegisterTeacherUseCase>(  () => RegisterTeacherUseCase(sl<AuthRepository>()));
  sl.registerFactory<VerifyOtpUseCase>(        () => VerifyOtpUseCase(sl<AuthRepository>()));
  sl.registerFactory<ForgotPasswordUseCase>(   () => ForgotPasswordUseCase(sl<AuthRepository>()));
  sl.registerFactory<ResetPasswordUseCase>(    () => ResetPasswordUseCase(sl<AuthRepository>()));
  sl.registerFactory<LinkTeacherUseCase>(      () => LinkTeacherUseCase(sl<AuthRepository>()));
  sl.registerFactory<LogoutUseCase>(           () => LogoutUseCase(sl<AuthRepository>()));
  sl.registerFactory<LogoutAllDevicesUseCase>( () => LogoutAllDevicesUseCase(sl<AuthRepository>()));

  AppLogger.info('DI: all dependencies registered ✓');
}
