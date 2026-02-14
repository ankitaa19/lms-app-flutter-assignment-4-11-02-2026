import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/auth_helper.dart';

class IssueBookService {
  static const baseUrl = 'http://localhost:4000/api/issue';

  static Future<void> issueBook(String bookId, String studentId) async {
    final headers = await AuthHelper.getAuthHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/issue'),
      headers: headers,
      body: jsonEncode({'bookId': bookId, 'studentId': studentId}),
    );

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error['message'] ?? 'Failed to issue book');
    }
  }

  static Future<void> returnBook(String issueId) async {
    final headers = await AuthHelper.getAuthHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/return/$issueId'),
      headers: headers,
    );

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error['message'] ?? 'Failed to return book');
    }
  }

  static Future<List> getAllIssuedBooks() async {
    final headers = await AuthHelper.getAuthHeaders();
    final res = await http.get(Uri.parse(baseUrl), headers: headers);
    if (res.statusCode != 200) {
      throw Exception('Failed to load issued books');
    }
    return jsonDecode(res.body);
  }

  static Future<List> getMyIssuedBooks(String studentId) async {
    final headers = await AuthHelper.getAuthHeaders();
    final res = await http.get(
      Uri.parse('$baseUrl/student/$studentId'),
      headers: headers,
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load my issued books');
    }
    return jsonDecode(res.body);
  }
}
