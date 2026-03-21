import 'package:edu_auth/features/auth/domain/entities/session_entity.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.accessToken, required super.refreshToken,
    required super.accessTokenExpiry, required super.refreshTokenExpiry,
    required super.userId, required super.deviceId, required super.deviceDescription,
  });

  factory SessionModel.fromJson(Map<String, dynamic> j) => SessionModel(
    accessToken:        j['access_token'] as String,
    refreshToken:       j['refresh_token'] as String,
    accessTokenExpiry:  DateTime.parse(j['access_token_expiry'] as String),
    refreshTokenExpiry: DateTime.parse(j['refresh_token_expiry'] as String),
    userId:             j['user_id'] as String,
    deviceId:           j['device_id'] as String,
    deviceDescription:  j['device_description'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'access_token': accessToken, 'refresh_token': refreshToken,
    'access_token_expiry': accessTokenExpiry.toIso8601String(),
    'refresh_token_expiry': refreshTokenExpiry.toIso8601String(),
    'user_id': userId, 'device_id': deviceId, 'device_description': deviceDescription,
  };
}
