import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/core/feature_flags/feature_flag_service.dart';
import 'package:edu_auth/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:edu_auth/features/auth/data/models/auth_request_models.dart';
import 'package:edu_auth/features/auth/data/models/session_model.dart';
import 'package:edu_auth/features/auth/data/models/user_model.dart';
import 'package:edu_auth/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:edu_auth/features/auth/domain/entities/user_entity.dart';

@GenerateMocks([AuthRemoteDatasource, FeatureFlagService])
import 'auth_repository_impl_test.mocks.dart';

void main() {
  late AuthRepositoryImpl repo;
  late MockAuthRemoteDatasource mockRemote;
  late MockFeatureFlagService   mockFlags;

  setUp(() {
    mockRemote = MockAuthRemoteDatasource();
    mockFlags  = MockFeatureFlagService();
    repo = AuthRepositoryImpl(remote: mockRemote, flags: mockFlags);

    // Default flag values
    when(mockFlags.rateLimiting).thenReturn(false);
    when(mockFlags.otpEnabled).thenReturn(true);
    when(mockFlags.teacherCodeSystem).thenReturn(true);
    when(mockFlags.auditLogging).thenReturn(false);
  });

  // ── Login ─────────────────────────────────────────────────────────────────

  group('login', () {
    final tSession = SessionModel(
      accessToken:        'at_test',
      refreshToken:       'rt_test',
      accessTokenExpiry:  DateTime.now().add(const Duration(hours: 1)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
      userId:             'user-001',
      deviceId:           'device-001',
      deviceDescription:  'Test Device',
    );

    test('returns SessionEntity on success', () async {
      when(mockRemote.login(any)).thenAnswer((_) async => Right(tSession));

      final result = await repo.login(
        email:             'test@test.com',
        password:          'Test@1234',
        deviceId:          'device-001',
        deviceDescription: 'Test Device',
      );

      expect(result.isRight(), true);
      result.fold((_) => fail('unexpected failure'), (s) {
        expect(s.userId, 'user-001');
        expect(s.accessToken, 'at_test');
      });
    });

    test('returns InvalidCredentialsFailure on wrong password', () async {
      when(mockRemote.login(any))
          .thenAnswer((_) async => const Left(InvalidCredentialsFailure()));

      final result = await repo.login(
        email:             'test@test.com',
        password:          'wrong',
        deviceId:          'device-001',
        deviceDescription: 'Test Device',
      );

      expect(result.isLeft(), true);
      result.fold((f) => expect(f, isA<InvalidCredentialsFailure>()), (_) => fail('unexpected success'));
    });
  });

  // ── Register Student ──────────────────────────────────────────────────────

  group('registerStudent', () {
    final tUser = UserModel(
      id: 'stu-001', email: 'student@test.com', fullName: 'Test Student',
      role: UserRole.student, status: AccountStatus.active,
      isEmailVerified: false, createdAt: DateTime.now(),
    );

    test('returns UserEntity on success', () async {
      when(mockRemote.registerStudent(any)).thenAnswer((_) async => Right(tUser));

      final result = await repo.registerStudent(
        email: 'student@test.com', password: 'Test@1234',
        fullName: 'Test Student', acceptedTerms: true,
        acceptedPrivacy: true, deviceId: 'device-001',
      );

      expect(result.isRight(), true);
      result.fold((_) => fail(''), (u) => expect(u.role, UserRole.student));
    });

    test('returns EmailAlreadyExistsFailure on duplicate email', () async {
      when(mockRemote.registerStudent(any))
          .thenAnswer((_) async => const Left(EmailAlreadyExistsFailure()));

      final result = await repo.registerStudent(
        email: 'dup@test.com', password: 'Test@1234',
        fullName: 'Dup User', acceptedTerms: true,
        acceptedPrivacy: true, deviceId: 'device-001',
      );

      expect(result.isLeft(), true);
      result.fold((f) => expect(f, isA<EmailAlreadyExistsFailure>()), (_) => fail(''));
    });
  });

  // ── OTP ───────────────────────────────────────────────────────────────────

  group('verifyOtp', () {
    test('returns true on valid OTP', () async {
      when(mockRemote.verifyOtp(any)).thenAnswer((_) async => const Right(true));

      final result = await repo.verifyOtp(
        userId: 'user-001', otp: '123456', purpose: 'login',
      );

      expect(result, const Right(true));
    });

    test('auto-passes when otp feature flag is disabled', () async {
      when(mockFlags.otpEnabled).thenReturn(false);

      final result = await repo.verifyOtp(
        userId: 'user-001', otp: '000000', purpose: 'login',
      );

      expect(result, const Right(true));
      verifyNever(mockRemote.verifyOtp(any));
    });

    test('returns OtpInvalidFailure on wrong OTP', () async {
      when(mockRemote.verifyOtp(any))
          .thenAnswer((_) async => const Left(OtpInvalidFailure()));

      final result = await repo.verifyOtp(
        userId: 'user-001', otp: '000000', purpose: 'login',
      );

      result.fold((f) => expect(f, isA<OtpInvalidFailure>()), (_) => fail(''));
    });
  });

  // ── Teacher Linking ───────────────────────────────────────────────────────

  group('linkToTeacher', () {
    test('returns true on valid code', () async {
      when(mockRemote.linkToTeacher(any)).thenAnswer((_) async => const Right(true));

      final result = await repo.linkToTeacher(
        studentId:   'stu-001',
        teacherCode: 'TCH12345',
        accessToken: 'at_test',
      );

      expect(result, const Right(true));
    });

    test('returns UnknownFailure when teacher code system disabled', () async {
      when(mockFlags.teacherCodeSystem).thenReturn(false);

      final result = await repo.linkToTeacher(
        studentId:   'stu-001',
        teacherCode: 'TCH12345',
        accessToken: 'at_test',
      );

      result.fold(
        (f) => expect(f, isA<UnknownFailure>()),
        (_) => fail('should have failed'),
      );
    });
  });

  // ── Logout ────────────────────────────────────────────────────────────────

  group('logout', () {
    test('clears session and returns true', () async {
      when(mockRemote.logout(any, any)).thenAnswer((_) async => const Right(true));

      final result = await repo.logout(
        accessToken: 'at_test',
        deviceId:    'device-001',
      );

      expect(result, const Right(true));
    });
  });
}
