import 'package:dartz/dartz.dart';
import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/core/utils/validators.dart';
import 'package:edu_auth/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtpParams {
  final String userId, otp, purpose;
  const VerifyOtpParams({required this.userId, required this.otp, required this.purpose});
}

class VerifyOtpUseCase {
  final AuthRepository _repo;
  const VerifyOtpUseCase(this._repo);
  Future<Either<Failure, bool>> call(VerifyOtpParams p) async {
    if (Validators.otp(p.otp) != null) return Left(ValidationFailure(Validators.otp(p.otp)!));
    return _repo.verifyOtp(userId: p.userId, otp: p.otp, purpose: p.purpose);
  }
}
