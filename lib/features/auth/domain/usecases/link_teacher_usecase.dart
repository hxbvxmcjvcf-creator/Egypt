import 'package:dartz/dartz.dart';
import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/core/utils/validators.dart';
import 'package:edu_auth/features/auth/domain/repositories/auth_repository.dart';

class LinkTeacherParams {
  final String studentId, teacherCode, accessToken;
  const LinkTeacherParams({required this.studentId, required this.teacherCode, required this.accessToken});
}

class LinkTeacherUseCase {
  final AuthRepository _repo;
  const LinkTeacherUseCase(this._repo);
  Future<Either<Failure, bool>> call(LinkTeacherParams p) async {
    if (Validators.teacherCode(p.teacherCode) != null) return Left(ValidationFailure(Validators.teacherCode(p.teacherCode)!));
    return _repo.linkToTeacher(
      studentId: p.studentId,
      teacherCode: p.teacherCode.trim().toUpperCase(),
      accessToken: p.accessToken,
    );
  }
}
