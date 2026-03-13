/// Single place for API base URL.
///
/// - For production / shared APK: use production URL (default).
/// - For testing on a real device with your local API: set [useLocalApi] to true
///   and [localBaseUrl] to http://YOUR_PC_IP:62808 (e.g. http://192.168.1.5:62808).
///   Ensure phone and PC are on the same WiFi and your API server allows connections
///   from the network (e.g. binds to 0.0.0.0).
class ApiConfig {
  ApiConfig._();

  /// Set to true only when testing on device with API running on your PC.
  static const bool useLocalApi = false;

  /// Your PC's IP and port when [useLocalApi] is true (e.g. http://192.168.1.5:62808).
  static const String localBaseUrl = "http://192.168.1.1:62808";

  static const String productionBaseUrl = "https://belamarble.com/API";

  /// Base URL used by the app. Change via [useLocalApi] and [localBaseUrl].
  static String get baseUrl =>
      useLocalApi ? localBaseUrl : productionBaseUrl;
}
