import 'package:equatable/equatable.dart';

enum AuditAction {
  login, loginFailed, logout, logoutAll,
  registerStudent, registerTeacher,
  forgotPassword, resetPassword,
  verifyOtp, verifyEmail,
  linkTeacher, tokenRefresh,
  deviceNew, suspiciousActivity,
}

/// Immutable audit log entry.
class AuditEntity extends Equatable {
  final String id;
  final AuditAction action;
  final String? userId;
  final String deviceId;
  final String deviceDescription;
  final DateTime timestamp;
  final bool success;
  final String? failureCode;
  final Map<String, dynamic> metadata;

  const AuditEntity({
    required this.id,
    required this.action,
    required this.deviceId,
    required this.deviceDescription,
    required this.timestamp,
    required this.success,
    this.userId,
    this.failureCode,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [id, action, userId, timestamp];
}
