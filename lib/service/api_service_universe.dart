// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/universe.dart';

class ApiService {
  final String baseUrl = "https://yodai.wevox.cloud";

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<Universe>> getUniverses() async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/universes'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList.map((json) => Universe.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des univers (${response.statusCode})');
    }
  }

  Future<void> addUniverse(name) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/universes'),
        headers: headers,
        body: jsonEncode({
          'name': name
        }),
      );
      if (response.statusCode != 201) {
        throw Exception('Erreur lors de la création de l\'univers');
      }
    } catch (e) {
      throw Exception('Erreur dans la création de l\'univers: ${e.toString()}');
    }
  }
}