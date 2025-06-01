import 'package:charac_ia/models/message.dart';
import 'package:charac_ia/service/api_service_message.dart';
import '../models/character.dart';
import '../service/api_service_characters.dart';

class CharacterController {
  final ApiService apiService = ApiService();
  final ApiServiceMessage apiServiceMessage = ApiServiceMessage();

  List<Character> characters = [];
  List<Map<String, dynamic>> conversations = [];
  Map<int, Message> lastMessages = {};
  String? errorMessage;

  // 🔹 Récupérer la liste des personnages
  Future<void> getCharactersByUniverse(int universeId) async {
    try{
      characters = await apiService.getCharacters(universeId);
      errorMessage = null;
    }catch (e) {
      errorMessage = "Échec du chargement des personnages : ${e.toString()}";
      characters = [];
    }
  }

  Future<void> loadUserConversations() async {
    try {
      conversations = await apiService.getConversations();
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des conversations';
    }
  }

  Future<void> loadLastMessagesForConversations() async {
    lastMessages = {};

    for (var convo in conversations) {
      final convoId = convo['id'] as int;
      final charId = convo['character_id'] as int;

      try {
        final message = await apiServiceMessage.getLastMessage(convoId);
        lastMessages[charId] = message;

        final character = characters.where((c) => c.id == charId).cast<Character?>().firstOrNull;

        if (character != null) {
          character.conversationId = convoId;
        }


      } catch (e) {
        errorMessage = "Échec du chargement du message : ${e.toString()}";
      }
    }
  }

  Future<void> createCharacter(name, idUniverse) async {
    try{
      await apiService.addCharacter(name, idUniverse);
    }catch(e) {
      errorMessage = "Échec de la création du personnage : ${e.toString()}";
    }
  }

}