// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  final String baseUrl = "https://yodai.wevox.cloud";

  // Méthode POST USER pour l'inscription
  Future<User> createUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 201) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Erreur HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Erreur lors de la création de l'utilisateur: $e");
    }
  }

  // Méthode POST pour la connexion
  Future<String> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      if (token != null) {
        return token;
      } else {
        throw Exception("Token manquant dans la réponse de l'API");
      }
    } else {
      throw Exception("Échec de la connexion: ${response.body}");
    }
  }

}