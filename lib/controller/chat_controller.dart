import '../models/message.dart';
import '../service/api_service_message.dart';

class ChatController {
  final ApiServiceMessage apiServiceMessage = ApiServiceMessage();

  List<Message> messages = [];
  String? errorMessage;

  Future<void> loadMessages(int conversationId) async {
    try {
      messages = await apiServiceMessage.getMessages(conversationId);
    } catch (e) {
      errorMessage = "Erreur lors du chargement des messages : ${e.toString()}";
    }
  }

  Future<int?> createConversationAndSend(String content, int characterId) async {
    try {
      // Création de la conversation
      final conversationId = await apiServiceMessage.createConversation(characterId);

      if (conversationId != null) {
        // Si la conversation a été envois message
        await sendMessage(content, conversationId);
        return conversationId;
      } else {
        throw Exception("Erreur lors de la création de la conversation");
      }
    } catch (e) {
      errorMessage = "Erreur lors de la création de la conversation : ${e.toString()}";
      return null;
    }
  }

// Dans ChatController
  Future<Message> sendMessage(String content, int conversationId) async {
    try {
      await apiServiceMessage.sendMessage(content, conversationId);

      // Créer un message local
      return Message(
        id: DateTime.now().millisecondsSinceEpoch,
        content: content,
        isSentByHuman: true,
        conversationId: conversationId,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      errorMessage = "Erreur lors de l'envoi du message : ${e.toString()}";
      rethrow;
    }
  }


  Future<Message> getBotResponse(int conversationId) async {
    try {
      final botMessage = await apiServiceMessage.getLastMessage(conversationId);
      return botMessage;
    } catch (e) {
      throw Exception("Erreur lors de la récupération de la réponse : ${e.toString()}");
    }
  }

}
