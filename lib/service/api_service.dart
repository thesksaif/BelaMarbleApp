import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';

class ApiService {
  static String get baseUrl =>
      ApiConfig.baseUrl.endsWith('/') ? ApiConfig.baseUrl : '${ApiConfig.baseUrl}/';

  static Map<String, String> _headers({String? token}) {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// 🔹 GET
  static Future<dynamic> get(
      String endpoint, {
        String? token,
      }) async {
    final url = Uri.parse(baseUrl + endpoint);

    try {
      final response = await http.get(
        url,
        headers: _headers(token: token),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception("GET Error: $e");
    }
  }

  /// 🔹 POST
  static Future<dynamic> post(
      String endpoint, {
        required Map<String, dynamic> body,
        String? token,
      }) async {
    final url = Uri.parse(baseUrl + endpoint);

    try {
      final response = await http.post(
        url,
        headers: _headers(token: token),
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception("POST Error: $e");
    }
  }

  /// 🔹 PUT
  static Future<dynamic> put(
      String endpoint, {
        required Map<String, dynamic> body,
        String? token,
      }) async {
    final url = Uri.parse(baseUrl + endpoint);

    try {
      final response = await http.put(
        url,
        headers: _headers(token: token),
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception("PUT Error: $e");
    }
  }

  /// 🔹 DELETE
  static Future<dynamic> delete(
      String endpoint, {
        String? token,
      }) async {
    final url = Uri.parse(baseUrl + endpoint);

    try {
      final response = await http.delete(
        url,
        headers: _headers(token: token),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception("DELETE Error: $e");
    }
  }

  /// 🔹 RESPONSE HANDLER (print bhi yahin hoga)
  static dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Something went wrong");
    }
  }
}
