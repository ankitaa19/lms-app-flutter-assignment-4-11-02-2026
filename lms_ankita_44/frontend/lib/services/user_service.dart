import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  // 🔥 IMPORTANT:
  // If using Android emulator → use 10.0.2.2 instead of localhost
  // static const String baseUrl = 'http://10.0.2.2:4000/api/auth';

  static const String baseUrl = 'http://localhost:4000/api/auth';

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final result = jsonDecode(response.body);
    
    // Store user data in SharedPreferences
    if (result['message'] == 'Login successful' && result['user'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(result['user']));
    }
    
    return result;
  }

  // ================= REGISTER =================
  static Future<Map<String, dynamic>> register(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    return jsonDecode(response.body);
  }

  // ================= GET ALL STUDENTS =================
  static Future<List<User>> getStudents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/students'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load students');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('Invalid student data');
    }

    // 🔥 Convert JSON → User model
    return decoded.map<User>((e) => User.fromJson(e)).toList();
  }

  // ================= GET CURRENT USER =================
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      
      if (userDataString == null) {
        return null;
      }
      
      final userData = jsonDecode(userDataString) as Map<String, dynamic>;
      return User.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  // ================= CLEAR USER DATA =================
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('token');
  }
}
