import 'package:dartz/dartz.dart';
import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repo;
  const LogoutUseCase(this._repo);
  Future<Either<Failure, bool>> call({required String accessToken, required String deviceId}) =>
      _repo.logout(accessToken: accessToken, deviceId: deviceId);
}

class LogoutAllDevicesUseCase {
  final AuthRepository _repo;
  const LogoutAllDevicesUseCase(this._repo);
  Future<Either<Failure, bool>> call({required String accessToken}) =>
      _repo.logoutAllDevices(accessToken: accessToken);
}
