class ApiEndpoints {
  // Base prefixes
  static const String apiV1 = '/api/v1';

  // Auth endpoints
  static const String auth = '$apiV1/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String refresh = '$auth/refresh';
  static const String me = '$auth/me';
  static const String updateProfile = '$auth/me/profile';

  // Farms endpoints
  static const String farms = '$apiV1/farms';

  // Crops & Stages
  static const String crops = '$apiV1/crops';
  static const String cropStages = '$apiV1/crops/stages';

  // Disease Detection
  static const String disease = '$apiV1/disease';
  static const String detectDisease = '$disease/detect';
  static const String remedies = '$disease/remedies';

  // Weather & Risk
  static const String weather = '$apiV1/weather';
  static const String weatherAlerts = '$weather/alerts';

  // AI Agricultural Assistant
  static const String assistant = '$apiV1/assistant';
  static const String chat = '$assistant/chat';

  // Recommendations
  static const String recommendations = '$apiV1/recommendations';

  // Finance & Economics
  static const String finance = '$apiV1/finance';

  // Nearby Agricultural Stores
  static const String stores = '$apiV1/stores';

  // Notifications
  static const String notifications = '$apiV1/notifications';
}
