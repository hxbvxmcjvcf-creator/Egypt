import 'package:dartz/dartz.dart';
import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/core/utils/validators.dart';
import 'package:edu_auth/features/auth/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _repo;
  const ForgotPasswordUseCase(this._repo);
  Future<Either<Failure, bool>> call(String email) async {
    if (Validators.email(email) != null) return Left(ValidationFailure(Validators.email(email)!));
    return _repo.forgotPassword(email: email.trim().toLowerCase());
  }
}
