import 'package:edu_auth/features/auth/data/models/user_model.dart';
import 'package:edu_auth/features/auth/data/models/session_model.dart';
import 'package:edu_auth/features/auth/data/models/auth_request_models.dart';

/// Service contract — the ONLY interface the data layer communicates with.
/// Swap MockAuthService ↔ FirebaseAuthService ↔ RestAuthService without
/// touching any other file.
abstract class IAuthService {
  Future<SessionModel> login(LoginRequest req);
  Future<UserModel>    registerStudent(RegisterStudentRequest req);
  Future<UserModel>    registerTeacher(RegisterTeacherRequest req);
  Future<bool>         verifyOtp(OtpRequest req);
  Future<bool>         resendOtp({required String userId, required String purpose});
  Future<bool>         forgotPassword({required String email});
  Future<bool>         resetPassword({required String userId, required String otp, required String newPassword});
  Future<bool>         linkToTeacher(LinkTeacherRequest req);
  Future<SessionModel> refreshToken({required String refreshToken, required String deviceId});
  Future<bool>         logout({required String accessToken, required String deviceId});
  Future<bool>         logoutAllDevices({required String accessToken});
  Future<UserModel>    getCurrentUser({required String accessToken});
  Future<bool>         verifyEmail({required String userId, required String token});
  Future<void>         logAudit({required String action, required String deviceId, String? userId, bool success = true, String? failureCode, Map<String, dynamic>? metadata});
}
