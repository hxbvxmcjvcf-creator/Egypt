// lib/core/utils/secure_storage.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:edu_auth/core/logging/app_logger.dart';

/// Encrypted storage wrapper. All tokens/session data go here.
/// Web-safe: skips iOS/Android-specific options on web platform.
class SecureStorage {
  SecureStorage._();

  static FlutterSecureStorage get _s {
    if (kIsWeb) {
      // Web uses localStorage under the hood (no native keychain)
      return const FlutterSecureStorage();
    }
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }

  static Future<void> write(String key, String value) async {
    try {
      await _s.write(key: key, value: value);
    } catch (e, st) {
      AppLogger.error('SecureStorage write [$key]', error: e, st: st);
      rethrow;
    }
  }

  static Future<String?> read(String key) async {
    try {
      return await _s.read(key: key);
    } catch (e, st) {
      AppLogger.error('SecureStorage read [$key]', error: e, st: st);
      return null;
    }
  }

  static Future<void> delete(String key) async {
    try {
      await _s.delete(key: key);
    } catch (e, st) {
      AppLogger.error('SecureStorage delete [$key]', error: e, st: st);
    }
  }

  static Future<void> clearAll() async {
    try {
      await _s.deleteAll();
    } catch (e, st) {
      AppLogger.error('SecureStorage clearAll', error: e, st: st);
    }
  }

  static Future<bool> hasKey(String key) async {
    try {
      return await _s.containsKey(key: key);
    } catch (_) {
      return false;
    }
  }
}
