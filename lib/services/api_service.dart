import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const String baseUrl = 'http://127.0.0.1:8000/api';


  String? token;

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (token != null)
        'Authorization': 'Token $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _headers,
    );

    return _handleResponse(response);
  }

  Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<dynamic> put(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint'),
      headers: _headers,
    );

    return _handleResponse(response);
  }
  Future<dynamic> registerMeshNode({
    required String deviceId,
    required String nodeName,
    required double latitude,
    required double longitude,
    required int batteryLevel,
    required int signalStrength,
  }) async {
    return await post(
      'mesh-nodes/',
      {
        'device_id': deviceId,
        'node_name': nodeName,
        'latitude': latitude,
        'longitude': longitude,
        'battery_level': batteryLevel,
        'signal_strength': signalStrength,
        'status': 'ACTIVE',
      },
    );
  }

  dynamic _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return {};
      }

      throw Exception(
        'Request failed (${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    debugPrint(
      'API ERROR ${response.statusCode}: $data',
    );

    throw Exception(data.toString());
  }
}