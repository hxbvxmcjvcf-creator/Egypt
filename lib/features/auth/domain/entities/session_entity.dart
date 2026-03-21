import 'package:equatable/equatable.dart';

/// Represents an authenticated session.
class SessionEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiry;
  final DateTime refreshTokenExpiry;
  final String userId;
  final String deviceId;
  final String deviceDescription;

  const SessionEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiry,
    required this.refreshTokenExpiry,
    required this.userId,
    required this.deviceId,
    required this.deviceDescription,
  });

  bool get isAccessTokenExpired  => DateTime.now().isAfter(accessTokenExpiry);
  bool get isRefreshTokenExpired => DateTime.now().isAfter(refreshTokenExpiry);
  bool get isValid => !isRefreshTokenExpired;

  @override
  List<Object?> get props => [accessToken, userId, deviceId];
}
