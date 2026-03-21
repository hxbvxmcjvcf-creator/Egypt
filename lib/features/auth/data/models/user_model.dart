import 'package:edu_auth/features/auth/domain/entities/user_entity.dart';

/// Data-layer model — serialised from/to JSON.
class UserModel extends UserEntity {
  const UserModel({
    required super.id, required super.email, required super.fullName,
    required super.role, required super.status, required super.isEmailVerified,
    required super.createdAt, super.linkedTeacherId, super.linkedStudentIds,
    super.teacherCode, super.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id:              j['id'] as String,
    email:           j['email'] as String,
    fullName:        j['full_name'] as String,
    role:            j['role'] == 'teacher' ? UserRole.teacher : UserRole.student,
    status:          _parseStatus(j['status'] as String? ?? 'active'),
    isEmailVerified: j['is_email_verified'] as bool? ?? false,
    createdAt:       DateTime.parse(j['created_at'] as String),
    lastLoginAt:     j['last_login_at'] != null ? DateTime.parse(j['last_login_at'] as String) : null,
    linkedTeacherId: j['linked_teacher_id'] as String?,
    teacherCode:     j['teacher_code'] as String?,
    linkedStudentIds: (j['linked_student_ids'] as List<dynamic>?)?.cast<String>() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'email': email, 'full_name': fullName,
    'role': role == UserRole.teacher ? 'teacher' : 'student',
    'status': status.name, 'is_email_verified': isEmailVerified,
    'created_at': createdAt.toIso8601String(),
    if (lastLoginAt != null)   'last_login_at':       lastLoginAt!.toIso8601String(),
    if (linkedTeacherId != null) 'linked_teacher_id': linkedTeacherId,
    if (teacherCode != null)   'teacher_code':        teacherCode,
    'linked_student_ids': linkedStudentIds,
  };

  static AccountStatus _parseStatus(String s) {
    switch (s) {
      case 'suspended': return AccountStatus.suspended;
      case 'deleted':   return AccountStatus.deleted;
      default:          return AccountStatus.active;
    }
  }
}
