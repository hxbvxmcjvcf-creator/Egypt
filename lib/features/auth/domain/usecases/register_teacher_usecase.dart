import 'package:dartz/dartz.dart';
import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/core/utils/validators.dart';
import 'package:edu_auth/features/auth/domain/entities/user_entity.dart';
import 'package:edu_auth/features/auth/domain/repositories/auth_repository.dart';

class RegisterTeacherParams {
  final String email, password, confirmPassword, fullName, deviceId;
  final bool acceptedTerms, acceptedPrivacy;
  const RegisterTeacherParams({
    required this.email, required this.password, required this.confirmPassword,
    required this.fullName, required this.acceptedTerms, required this.acceptedPrivacy,
    required this.deviceId,
  });
}

class RegisterTeacherUseCase {
  final AuthRepository _repo;
  const RegisterTeacherUseCase(this._repo);

  Future<Either<Failure, UserEntity>> call(RegisterTeacherParams p) async {
    if (!p.acceptedTerms || !p.acceptedPrivacy) return const Left(TermsNotAcceptedFailure());
    if (Validators.email(p.email) != null)       return Left(ValidationFailure(Validators.email(p.email)!));
    if (Validators.password(p.password) != null) return Left(ValidationFailure(Validators.password(p.password)!));
    if (Validators.confirmPassword(p.confirmPassword, p.password) != null)
      return Left(ValidationFailure(Validators.confirmPassword(p.confirmPassword, p.password)!));
    if (Validators.fullName(p.fullName) != null) return Left(ValidationFailure(Validators.fullName(p.fullName)!));
    return _repo.registerTeacher(
      email: p.email.trim().toLowerCase(), password: p.password,
      fullName: p.fullName.trim(), acceptedTerms: p.acceptedTerms,
      acceptedPrivacy: p.acceptedPrivacy, deviceId: p.deviceId,
    );
  }
}
