// lib/core/logging/app_logger.dart
import 'package:logger/logger.dart';
import 'package:edu_auth/core/config/environment_config.dart';

/// Centralised logger — logger ^2.0.2, Dart 3.1 compatible.
class AppLogger {
  AppLogger._();

  static final Logger _dev = Logger(
    printer: PrettyPrinter(
      methodCount:      2,
      errorMethodCount: 8,
      lineLength:       100,
      colors:           true,
      printEmojis:      true,
    ),
    level: Level.debug,
  );

  static final Logger _prod = Logger(
    printer: PrettyPrinter(methodCount: 0, printEmojis: false),
    level: Level.warning,
  );

  static Logger get _l => EnvironmentConfig.isProduction ? _prod : _dev;

  static void debug(String msg, {dynamic error, StackTrace? st}) =>
      _l.d(msg, error: error, stackTrace: st);

  static void info(String msg, {dynamic error, StackTrace? st}) =>
      _l.i(msg, error: error, stackTrace: st);

  static void warn(String msg, {dynamic error, StackTrace? st}) =>
      _l.w(msg, error: error, stackTrace: st);

  static void error(String msg, {dynamic error, StackTrace? st}) =>
      _l.e(msg, error: error, stackTrace: st);

  static void fatal(String msg, {dynamic error, StackTrace? st}) =>
      _l.e('FATAL: $msg', error: error, stackTrace: st);

  static void network(String method, String url, {int? status}) =>
      _l.d('[$method] $url${status != null ? " → $status" : ""}');

  static void security(String event, {String? userId, String? device}) =>
      _l.w('🔐 SECURITY: $event | user=$userId | device=$device');

  static void audit(String action,
      {String? userId, String? device, Map<String, dynamic>? meta}) =>
      _l.i('📋 AUDIT: $action | user=$userId | device=$device | meta=$meta');
}
