/// Typed request models — sent to AuthService (not directly to HTTP).
class LoginRequest {
  final String email, password, deviceId, deviceDescription;
  const LoginRequest({required this.email, required this.password, required this.deviceId, required this.deviceDescription});
  Map<String, dynamic> toJson() => {'email': email, 'password': password, 'device_id': deviceId, 'device_description': deviceDescription};
}

class RegisterStudentRequest {
  final String email, password, fullName, deviceId;
  final bool acceptedTerms, acceptedPrivacy;
  const RegisterStudentRequest({required this.email, required this.password, required this.fullName, required this.deviceId, required this.acceptedTerms, required this.acceptedPrivacy});
  Map<String, dynamic> toJson() => {'email': email, 'password': password, 'full_name': fullName, 'device_id': deviceId, 'accepted_terms': acceptedTerms, 'accepted_privacy': acceptedPrivacy, 'role': 'student'};
}

class RegisterTeacherRequest {
  final String email, password, fullName, deviceId;
  final bool acceptedTerms, acceptedPrivacy;
  const RegisterTeacherRequest({required this.email, required this.password, required this.fullName, required this.deviceId, required this.acceptedTerms, required this.acceptedPrivacy});
  Map<String, dynamic> toJson() => {'email': email, 'password': password, 'full_name': fullName, 'device_id': deviceId, 'accepted_terms': acceptedTerms, 'accepted_privacy': acceptedPrivacy, 'role': 'teacher'};
}

class OtpRequest {
  final String userId, otp, purpose;
  const OtpRequest({required this.userId, required this.otp, required this.purpose});
  Map<String, dynamic> toJson() => {'user_id': userId, 'otp': otp, 'purpose': purpose};
}

class LinkTeacherRequest {
  final String studentId, teacherCode;
  const LinkTeacherRequest({required this.studentId, required this.teacherCode});
  Map<String, dynamic> toJson() => {'student_id': studentId, 'teacher_code': teacherCode};
}

/// Standard API response wrapper.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorCode;
  final String? message;

  const ApiResponse({required this.success, this.data, this.errorCode, this.message});

  factory ApiResponse.fromJson(
    Map<String, dynamic> j,
    T Function(dynamic)? dataParser,
  ) => ApiResponse(
    success:   j['success'] as bool? ?? false,
    data:      j['data'] != null && dataParser != null ? dataParser(j['data']) : null,
    errorCode: j['error'] as String?,
    message:   j['message'] as String?,
  );
}
