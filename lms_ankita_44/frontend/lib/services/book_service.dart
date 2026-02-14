import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../utils/auth_helper.dart';

class BookService {
  static const String baseUrl = 'http://localhost:4000/api/books';

  /* ================= GET ALL BOOKS ================= */
  static Future<List<Book>> getAllBooks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode != 200) {
        throw Exception(_getErrorMessage(response));
      }

      final List data = _parseJson(response.body);
      return data.map((e) => Book.fromJson(e)).toList();
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to load books: ${e.toString()}');
    }
  }

  /* ================= GET SINGLE BOOK ================= */
  static Future<Book> getBook(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode != 200) {
        throw Exception(_getErrorMessage(response));
      }

      final data = _parseJson(response.body);
      return Book.fromJson(data);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to load book: ${e.toString()}');
    }
  }

  /* ================= ADD BOOK (LIBRARIAN) ================= */
  static Future<void> addBook({
    required String title,
    required String author,
    String isbn = '',
    String publisher = '',
    int? publishedYear,
    String genre = '',
    String description = '',
    required int quantity,
  }) async {
    try {
      final headers = await AuthHelper.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'author': author,
          'isbn': isbn,
          'publisher': publisher,
          'publishedYear': publishedYear,
          'genre': genre,
          'description': description,
          'quantity': quantity,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_getErrorMessage(response));
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to add book: ${e.toString()}');
    }
  }

  /* ================= UPDATE BOOK (LIBRARIAN) ================= */
  static Future<void> updateBook({
    required String id,
    required String title,
    required String author,
    String isbn = '',
    String publisher = '',
    int? publishedYear,
    String genre = '',
    String description = '',
    required int quantity,
  }) async {
    try {
      final headers = await AuthHelper.getAuthHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'author': author,
          'isbn': isbn,
          'publisher': publisher,
          'publishedYear': publishedYear,
          'genre': genre,
          'description': description,
          'quantity': quantity,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(_getErrorMessage(response));
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to update book: ${e.toString()}');
    }
  }

  /* ================= DELETE BOOK (LIBRARIAN) ================= */
  static Future<void> deleteBook(String id) async {
    try {
      final headers = await AuthHelper.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // Success
      }

      throw Exception(_getErrorMessage(response));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to delete book: ${e.toString()}');
    }
  }

  /* ================= HELPER METHODS ================= */
  static dynamic _parseJson(String body) {
    try {
      return jsonDecode(body);
    } catch (e) {
      // If response is HTML (like error page), provide helpful message
      if (body.trim().startsWith('<!DOCTYPE') ||
          body.trim().startsWith('<html')) {
        throw Exception(
          'Server returned HTML instead of JSON. Please check if the backend server is running on port 4000.',
        );
      }
      throw Exception('Invalid JSON response: ${e.toString()}');
    }
  }

  static String _getErrorMessage(http.Response response) {
    try {
      final error = _parseJson(response.body);
      if (error is Map && error.containsKey('message')) {
        return error['message'] as String;
      }
    } catch (e) {
      // If we can't parse JSON, check if it's HTML
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        return 'Server error. Please check if the backend server is running on port 4000.';
      }
    }

    // Default error message based on status code
    switch (response.statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Request failed with status code ${response.statusCode}';
    }
  }
}
