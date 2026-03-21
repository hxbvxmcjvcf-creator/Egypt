import 'package:equatable/equatable.dart';

enum UserRole { student, teacher }
enum AccountStatus { active, suspended, deleted }

/// Core user entity — pure domain, no Flutter/external dependencies.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final AccountStatus status;
  final bool isEmailVerified;
  final String? linkedTeacherId;   // Student → Teacher link
  final List<String> linkedStudentIds; // Teacher → Students list
  final String? teacherCode;       // Only for teachers
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.status,
    required this.isEmailVerified,
    required this.createdAt,
    this.linkedTeacherId,
    this.linkedStudentIds = const [],
    this.teacherCode,
    this.lastLoginAt,
  });

  bool get isActive    => status == AccountStatus.active;
  bool get isSuspended => status == AccountStatus.suspended;
  bool get isStudent   => role == UserRole.student;
  bool get isTeacher   => role == UserRole.teacher;

  @override
  List<Object?> get props => [id, email, role, status, isEmailVerified];
}
