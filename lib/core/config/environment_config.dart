/// Environment configuration.
/// Pass values at build time via --dart-define; NEVER hardcode secrets.
enum AppEnvironment { development, staging, production }

class EnvironmentConfig {
  EnvironmentConfig._();

  static AppEnvironment get environment {
    const env = String.fromEnvironment('APP_ENV', defaultValue: 'development');
    switch (env) {
      case 'production': return AppEnvironment.production;
      case 'staging':    return AppEnvironment.staging;
      default:           return AppEnvironment.development;
    }
  }

  static bool get isProduction => environment == AppEnvironment.production;
  static bool get isDevelopment => environment == AppEnvironment.development;

  /// When true, MockAuthService is injected — no real network calls.
  static bool get useMockServices {
    const v = String.fromEnvironment('USE_MOCK', defaultValue: 'true');
    return v == 'true';
  }

  static String get baseUrl {
    switch (environment) {
      case AppEnvironment.production:
        return const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.eduplatform.com/v1');
      case AppEnvironment.staging:
        return const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://staging.eduplatform.com/v1');
      case AppEnvironment.development:
        return const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000/v1');
    }
  }

  static int get connectTimeoutMs => isProduction ? 15000 : 30000;
  static int get receiveTimeoutMs => isProduction ? 15000 : 30000;
}
