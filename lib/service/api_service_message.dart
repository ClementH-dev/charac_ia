import 'dart:convert';
import 'package:charac_ia/models/message.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServiceMessage {
  final String baseUrl = "https://yodai.wevox.cloud";

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<int?> createConversation(int characterId) async {
    try {
      final headers = await _getAuthHeaders();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        throw Exception("Token d'authentification manquant");
      }
      // Décoder le JWT pour obtenir les informations du payload
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      final data = jsonDecode(decodedToken['data']);
      final userId = data['id'];
      if (userId == null) {
        throw Exception("ID utilisateur manquant dans le token");
      }
      // Corps de la requête avec l'ID du personnage et l'ID de l'utilisateur
      final response = await http.post(
        Uri.parse('$baseUrl/conversations'),
        headers: headers,
        body: jsonEncode({
          'character_id': characterId,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final conversationId = data['id'];
        return conversationId; // Retourner l'ID de la nouvelle conversation
      } else {
        throw Exception('Erreur lors de la création de la conversation');
      }
    } catch (e) {
      throw Exception('Erreur dans la création de la conversation: ${e.toString()}');
    }
  }

  Future<Message> getLastMessage(int conversationId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/conversations/$conversationId/messages'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          final lastMessage = data.last;
          return Message.fromJson(lastMessage);
        } else {
          throw Exception("Aucun message trouvé.");
        }
      } else {
        throw Exception('Erreur lors de la récupération des messages');
      }
    } catch (e) {
      throw Exception('Erreur dans la récupération du dernier message: ${e.toString()}');
    }
  }

  Future<List<Message>> getMessages(int conversationId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/conversations/$conversationId/messages'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map<Message>((json) => Message.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Erreur lors de la récupération des messages');
      }
    } catch (e) {
      throw Exception('Erreur dans la récupération des messages: ${e.toString()}');
    }
  }

  Future<void> sendMessage(String content, int conversationId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/conversations/$conversationId/messages'),
        headers: headers,
        body: jsonEncode({
          'content': content,
          'is_sent_by_human': true,
        }),
      );
      if (response.statusCode != 201) {
        throw Exception('Erreur lors de l\'envoi du message');
      }
    } catch (e) {
      throw Exception('Erreur dans l\'envoi du message: ${e.toString()}');
    }
  }
}
