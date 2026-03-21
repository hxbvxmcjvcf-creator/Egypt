import 'package:dartz/dartz.dart';
import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/core/utils/validators.dart';
import 'package:edu_auth/features/auth/domain/entities/session_entity.dart';
import 'package:edu_auth/features/auth/domain/repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;
  final String deviceId;
  final String deviceDescription;
  const LoginParams({required this.email, required this.password, required this.deviceId, required this.deviceDescription});
}

class LoginUseCase {
  final AuthRepository _repo;
  const LoginUseCase(this._repo);

  Future<Either<Failure, SessionEntity>> call(LoginParams p) async {
    // UX pre-check (backend re-validates)
    if (Validators.email(p.email) != null)    return const Left(ValidationFailure('Invalid email'));
    if (Validators.password(p.password) != null) return const Left(ValidationFailure('Invalid password'));
    return _repo.login(
      email: p.email.trim().toLowerCase(),
      password: p.password,
      deviceId: p.deviceId,
      deviceDescription: p.deviceDescription,
    );
  }
}
