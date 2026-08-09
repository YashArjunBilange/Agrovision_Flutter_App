class AppConfig {
  static const String appName = 'AgroVision';
  static const String appVersion = '1.0.0';

  // Base API URL for FastAPI backend
  // By default, points to the live deployed Render backend or localhost in debug
  static const String defaultBaseUrl = 'http://192.168.0.102:8000';
  
  static String baseUrl = defaultBaseUrl;

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
