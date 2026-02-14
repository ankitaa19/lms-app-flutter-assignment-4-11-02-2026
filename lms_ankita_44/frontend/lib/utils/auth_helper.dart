import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  /// Get headers with authorization token for API requests
  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get headers without authorization (for public endpoints)
  static Map<String, String> getPublicHeaders() {
    return {'Content-Type': 'application/json'};
  }
}
