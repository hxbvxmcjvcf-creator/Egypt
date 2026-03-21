// lib/core/utils/device_info_util.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:edu_auth/core/constants/app_constants.dart';
import 'secure_storage.dart';

/// Collects device metadata for audit logging and new-device detection.
/// Web-safe: uses kIsWeb guard before calling dart:io Platform APIs.
class DeviceInfoUtil {
  DeviceInfoUtil._();
  static final _plugin = DeviceInfoPlugin();
  static const _uuid = Uuid();

  /// Returns or creates a persistent device ID.
  static Future<String> getDeviceId() async {
    String? id = await SecureStorage.read(AppConstants.kDeviceId);
    if (id == null) {
      id = _uuid.v4();
      await SecureStorage.write(AppConstants.kDeviceId, id);
    }
    return id;
  }

  /// Returns a human-readable device description.
  static Future<String> getDeviceDescription() async {
    try {
      if (kIsWeb) {
        final info = await _plugin.webBrowserInfo;
        return '${info.browserName.name} on ${info.platform ?? 'Web'}';
      }
      // Mobile: use conditional import via dart:io
      return await _getMobileDescription();
    } catch (_) {
      return 'Unknown Device';
    }
  }

  static Future<String> _getMobileDescription() async {
    try {
      // ignore: import_of_legacy_library_into_null_safe
      final plugin = DeviceInfoPlugin();
      // We check platform via DeviceInfoPlugin to avoid dart:io on web
      final androidInfo = await _tryAndroid(plugin);
      if (androidInfo != null) return androidInfo;
      final iosInfo = await _tryIos(plugin);
      if (iosInfo != null) return iosInfo;
      return 'Unknown Device';
    } catch (_) {
      return 'Unknown Device';
    }
  }

  static Future<String?> _tryAndroid(DeviceInfoPlugin plugin) async {
    try {
      final info = await plugin.androidInfo;
      return '${info.manufacturer} ${info.model} (Android ${info.version.release})';
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _tryIos(DeviceInfoPlugin plugin) async {
    try {
      final info = await plugin.iosInfo;
      return '${info.name} (${info.systemName} ${info.systemVersion})';
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, String>> getDeviceMeta() async {
    final platform = kIsWeb ? 'web' : 'mobile';
    return {
      'device_id':   await getDeviceId(),
      'device_desc': await getDeviceDescription(),
      'platform':    platform,
    };
  }
}
