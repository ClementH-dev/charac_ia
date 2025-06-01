// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';

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

  Future<List<Character>> getCharacters(int universeId) async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/universes/$universeId/characters'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Character.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des personnages (${response.statusCode})');
    }
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/conversations'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Erreur lors de la récupération des conversations');
    }
  }

  Future<void> addCharacter(name, int universeId) async {
    try{
      final headers = await _getAuthHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/universes/$universeId/characters'),
        headers: headers,
        body: jsonEncode({
          'name': name
        }),
      );
      if (response.statusCode != 201) {
        throw Exception('Erreur lors de la création du personnage');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du personnage: ${e.toString()}');
    }
  }
}