import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:edu_auth/core/logging/app_logger.dart';
import 'package:edu_auth/features/auth/data/models/auth_request_models.dart';
import 'package:edu_auth/features/auth/data/models/session_model.dart';
import 'package:edu_auth/features/auth/data/models/user_model.dart';
import 'package:edu_auth/features/auth/domain/entities/user_entity.dart';
import 'package:edu_auth/services/interfaces/i_auth_service.dart';

/// Fully-functional mock service — no network calls.
/// Replace with RestAuthService or FirebaseAuthService via DI.
class MockAuthService implements IAuthService {
  static const _uuid = Uuid();

  // In-memory user store keyed by email
  final Map<String, _MockUser> _users = {
    'student@test.com': _MockUser(
      id: 'stu-001', email: 'student@test.com', password: 'Test@1234',
      fullName: 'أحمد محمد', role: 'student', teacherCode: null,
    ),
    'teacher@test.com': _MockUser(
      id: 'tea-001', email: 'teacher@test.com', password: 'Test@1234',
      fullName: 'د. سارة أحمد', role: 'teacher', teacherCode: 'TCH12345',
    ),
  };

  final Map<String, String> _otpStore    = {}; // userId → otp
  final Map<String, int>    _attempts    = {}; // email  → attempts
  final Map<String, String> _tokens      = {}; // userId → accessToken
  final Map<String, String> _refreshTokens = {};
  final List<Map<String, dynamic>> _auditLog = [];

  // ── AI Hook (stub) ────────────────────────────────────────────────────────
  // ignore: unused_element
  Future<void> _aiFraudHook(String action, String email) async {
    // AI fraud detection will plug here in production
    AppLogger.debug('[AI_HOOK] fraud_check: action=$action email=$email');
  }

  // ── Simulate network delay ────────────────────────────────────────────────
  Future<void> _delay([int ms = 800]) => Future.delayed(Duration(milliseconds: ms));

  // ── Rate limit check ──────────────────────────────────────────────────────
  void _checkRateLimit(String email) {
    final attempts = _attempts[email] ?? 0;
    if (attempts >= 5) throw Exception('AUTH_010'); // RateLimitExceeded
  }

  void _incrementAttempts(String email) {
    _attempts[email] = (_attempts[email] ?? 0) + 1;
  }

  void _resetAttempts(String email) => _attempts.remove(email);

  // ── Token factory ─────────────────────────────────────────────────────────
  SessionModel _makeSession(_MockUser user, String deviceId, String deviceDesc) {
    final at = 'at_${_uuid.v4()}';
    final rt = 'rt_${_uuid.v4()}';
    _tokens[user.id]       = at;
    _refreshTokens[user.id] = rt;
    return SessionModel(
      accessToken:        at,
      refreshToken:       rt,
      accessTokenExpiry:  DateTime.now().add(const Duration(hours: 1)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 30)),
      userId:             user.id,
      deviceId:           deviceId,
      deviceDescription:  deviceDesc,
    );
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  @override
  Future<SessionModel> login(LoginRequest req) async {
    await _delay();
    _checkRateLimit(req.email);
    await _aiFraudHook('login', req.email);

    final user = _users[req.email.toLowerCase()];
    if (user == null) { _incrementAttempts(req.email); throw Exception('AUTH_002'); }
    if (user.password != req.password) { _incrementAttempts(req.email); throw Exception('AUTH_001'); }
    if (user.suspended) throw Exception('AUTH_003');

    _resetAttempts(req.email);
    user.isEmailVerified = true; // Mock: auto-verify for demo

    // Generate mock OTP for MFA
    final otp = _generateOtp();
    _otpStore[user.id] = otp;
    AppLogger.debug('[MOCK OTP] ${user.email}: $otp');

    await logAudit(action: 'login', deviceId: req.deviceId, userId: user.id, success: true);
    return _makeSession(user, req.deviceId, req.deviceDescription);
  }

  // ── Register Student ──────────────────────────────────────────────────────
  @override
  Future<UserModel> registerStudent(RegisterStudentRequest req) async {
    await _delay(1000);
    if (_users.containsKey(req.email.toLowerCase())) throw Exception('REG_001');

    final user = _MockUser(
      id: _uuid.v4(), email: req.email.toLowerCase(),
      password: req.password, fullName: req.fullName, role: 'student',
    );
    _users[req.email.toLowerCase()] = user;

    final otp = _generateOtp();
    _otpStore[user.id] = otp;
    AppLogger.debug('[MOCK VERIFY OTP] ${user.email}: $otp');

    await logAudit(action: 'register_student', deviceId: req.deviceId, userId: user.id, success: true);
    return user.toModel();
  }

  // ── Register Teacher ──────────────────────────────────────────────────────
  @override
  Future<UserModel> registerTeacher(RegisterTeacherRequest req) async {
    await _delay(1000);
    if (_users.containsKey(req.email.toLowerCase())) throw Exception('REG_001');

    final teacherCode = _generateTeacherCode();
    final user = _MockUser(
      id: _uuid.v4(), email: req.email.toLowerCase(),
      password: req.password, fullName: req.fullName,
      role: 'teacher', teacherCode: teacherCode,
    );
    _users[req.email.toLowerCase()] = user;

    AppLogger.debug('[MOCK TEACHER CODE] ${user.email}: $teacherCode');
    await logAudit(action: 'register_teacher', deviceId: req.deviceId, userId: user.id, success: true);
    return user.toModel();
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────
  @override
  Future<bool> verifyOtp(OtpRequest req) async {
    await _delay(600);
    final stored = _otpStore[req.userId];
    if (stored == null || stored != req.otp) throw Exception('AUTH_011');
    _otpStore.remove(req.userId);
    await logAudit(action: 'verify_otp', deviceId: 'unknown', userId: req.userId, success: true);
    return true;
  }

  @override
  Future<bool> resendOtp({required String userId, required String purpose}) async {
    await _delay(400);
    final otp = _generateOtp();
    _otpStore[userId] = otp;
    AppLogger.debug('[MOCK RESEND OTP] userId=$userId otp=$otp purpose=$purpose');
    return true;
  }

  // ── Forgot / Reset Password ───────────────────────────────────────────────
  @override
  Future<bool> forgotPassword({required String email}) async {
    await _delay(700);
    final user = _users[email.toLowerCase()];
    if (user == null) throw Exception('AUTH_002');
    final otp = _generateOtp();
    _otpStore[user.id] = otp;
    AppLogger.debug('[MOCK RESET OTP] ${user.email}: $otp');
    return true;
  }

  @override
  Future<bool> resetPassword({required String userId, required String otp, required String newPassword}) async {
    await _delay(800);
    final stored = _otpStore[userId];
    if (stored == null || stored != otp) throw Exception('AUTH_011');
    final user = _users.values.firstWhere((u) => u.id == userId, orElse: () => throw Exception('AUTH_002'));
    user.password = newPassword;
    _otpStore.remove(userId);
    await logAudit(action: 'reset_password', deviceId: 'unknown', userId: userId, success: true);
    return true;
  }

  // ── Link Teacher ──────────────────────────────────────────────────────────
  @override
  Future<bool> linkToTeacher(LinkTeacherRequest req) async {
    await _delay(700);
    final teacher = _users.values.where((u) => u.teacherCode == req.teacherCode).firstOrNull;
    if (teacher == null) throw Exception('AUTH_013');
    final student = _users.values.where((u) => u.id == req.studentId).firstOrNull;
    if (student == null) throw Exception('AUTH_002');
    if (student.linkedTeacherId == teacher.id) throw Exception('AUTH_015');
    student.linkedTeacherId = teacher.id;
    teacher.linkedStudentIds.add(student.id);
    await logAudit(action: 'link_teacher', deviceId: 'unknown', userId: req.studentId, success: true,
      metadata: {'teacher_id': teacher.id, 'teacher_code': req.teacherCode});
    return true;
  }

  // ── Token Refresh ─────────────────────────────────────────────────────────
  @override
  Future<SessionModel> refreshToken({required String refreshToken, required String deviceId}) async {
    await _delay(400);
    final entry = _refreshTokens.entries.where((e) => e.value == refreshToken).firstOrNull;
    if (entry == null) throw Exception('AUTH_008');
    final user = _users.values.where((u) => u.id == entry.key).firstOrNull;
    if (user == null) throw Exception('AUTH_002');
    return _makeSession(user, deviceId, 'device');
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  @override
  Future<bool> logout({required String accessToken, required String deviceId}) async {
    await _delay(400);
    _tokens.removeWhere((_, v) => v == accessToken);
    await logAudit(action: 'logout', deviceId: deviceId, success: true);
    return true;
  }

  @override
  Future<bool> logoutAllDevices({required String accessToken}) async {
    await _delay(400);
    _tokens.clear(); _refreshTokens.clear();
    await logAudit(action: 'logout_all', deviceId: 'all', success: true);
    return true;
  }

  // ── Get Current User ──────────────────────────────────────────────────────
  @override
  Future<UserModel> getCurrentUser({required String accessToken}) async {
    await _delay(300);
    final entry = _tokens.entries.where((e) => e.value == accessToken).firstOrNull;
    if (entry == null) throw Exception('AUTH_007');
    final user = _users.values.where((u) => u.id == entry.key).firstOrNull;
    if (user == null) throw Exception('AUTH_002');
    return user.toModel();
  }

  @override
  Future<bool> verifyEmail({required String userId, required String token}) async {
    await _delay(500);
    final user = _users.values.where((u) => u.id == userId).firstOrNull;
    if (user == null) throw Exception('AUTH_002');
    user.isEmailVerified = true;
    await logAudit(action: 'verify_email', deviceId: 'unknown', userId: userId, success: true);
    return true;
  }

  // ── Audit ─────────────────────────────────────────────────────────────────
  @override
  Future<void> logAudit({
    required String action, required String deviceId,
    String? userId, bool success = true,
    String? failureCode, Map<String, dynamic>? metadata,
  }) async {
    _auditLog.add({
      'id': _uuid.v4(), 'action': action, 'user_id': userId,
      'device_id': deviceId, 'timestamp': DateTime.now().toIso8601String(),
      'success': success, 'failure_code': failureCode, ...?metadata,
    });
    AppLogger.audit(action, userId: userId, device: deviceId, meta: metadata);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _generateOtp() => (100000 + Random().nextInt(900000)).toString();

  String _generateTeacherCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}

/// Internal mock user record.
class _MockUser {
  final String id;
  final String email;
  String password;
  final String fullName;
  final String role;
  String? teacherCode;
  String? linkedTeacherId;
  List<String> linkedStudentIds = [];
  bool isEmailVerified = false;
  bool suspended = false;

  _MockUser({
    required this.id, required this.email, required this.password,
    required this.fullName, required this.role, this.teacherCode,
  });

  UserModel toModel() => UserModel(
    id: id, email: email, fullName: fullName,
    role: role == 'teacher' ? UserRole.teacher : UserRole.student,
    status: suspended ? AccountStatus.suspended : AccountStatus.active,
    isEmailVerified: isEmailVerified,
    createdAt: DateTime.now(),
    linkedTeacherId: linkedTeacherId,
    teacherCode: teacherCode,
    linkedStudentIds: linkedStudentIds,
  );
}
