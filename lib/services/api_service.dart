import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // TODO: Replace with your backend URL
  static const String baseUrl = 'https://your-api-url.com/api';

  Future<Map<String, dynamic>> get(
      String endpoint,
      ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
      String endpoint,
      ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(
      http.Response response,
      ) {
    if (response.body.isEmpty) {
      return {};
    }

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    throw Exception(
      data['message'] ?? 'Request failed',
    );
  }
}