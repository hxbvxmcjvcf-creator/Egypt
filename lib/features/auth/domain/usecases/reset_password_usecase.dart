import 'package:dartz/dartz.dart';
import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/core/utils/validators.dart';
import 'package:edu_auth/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordParams {
  final String userId, otp, newPassword, confirmPassword;
  const ResetPasswordParams({required this.userId, required this.otp, required this.newPassword, required this.confirmPassword});
}

class ResetPasswordUseCase {
  final AuthRepository _repo;
  const ResetPasswordUseCase(this._repo);
  Future<Either<Failure, bool>> call(ResetPasswordParams p) async {
    if (Validators.otp(p.otp) != null) return Left(ValidationFailure(Validators.otp(p.otp)!));
    if (Validators.password(p.newPassword) != null) return Left(ValidationFailure(Validators.password(p.newPassword)!));
    if (p.newPassword != p.confirmPassword) return const Left(ValidationFailure('Passwords do not match'));
    return _repo.resetPassword(userId: p.userId, otp: p.otp, newPassword: p.newPassword);
  }
}
