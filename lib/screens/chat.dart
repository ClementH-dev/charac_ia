import 'package:flutter/material.dart';
import '../controller/chat_controller.dart';
import '../models/message.dart';

class ChatPage extends StatefulWidget {
  final String characterName;
  final String? characterImage;
  final int characterId;
  final int? conversationId;

  ChatPage({
    required this.characterName,
    required this.characterId,
    required this.characterImage,
    this.conversationId,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController _chatController = ChatController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late int? _conversationId;
  bool _isTyping = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    if (_conversationId != null) {
      _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      await _chatController.loadMessages(_conversationId!);
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement des messages: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Vider le champ de texte immédiatement
    _messageController.clear();

    // Créer et afficher le message de l'utilisateur immédiatement
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch, // ID temporaire
      content: content,
      isSentByHuman: true,
      conversationId: _conversationId,
      createdAt: DateTime.now(),
    );

    setState(() {
      _chatController.messages.add(userMessage);
      _isTyping = true; // Afficher l'indicateur de frappe
    });

    // Défiler vers le bas pour montrer le nouveau message
    _scrollToBottom();

    try {
      // Si c'est une nouvelle conversation
      if (_conversationId == null) {
        // Créer une nouvelle conversation
        _conversationId = await _chatController.createConversationAndSend(content, widget.characterId);

        if (_conversationId != null) {
          // Obtenir la réponse du bot
          await _getBotResponse();
        }
      } else {
        // Envoyer le message dans une conversation existante
        await _chatController.sendMessage(content, _conversationId!);

        // Obtenir la réponse du bot
        await _getBotResponse();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    } finally {
      setState(() => _isTyping = false);
    }
  }

  Future<void> _getBotResponse() async {
    // Ajouter un délai court pour simuler le temps de réflexion du bot
    await Future.delayed(Duration(milliseconds: 500));

    try {
      if (_conversationId != null) {
        final botMessage = await _chatController.getBotResponse(_conversationId!);

        setState(() {
          // Vérifier si le message n'est pas déjà dans la liste
          if (!_chatController.messages.any((msg) => msg.id == botMessage.id && !msg.isSentByHuman)) {
            _chatController.messages.add(botMessage);
          }
        });

        // Défiler vers le bas pour montrer la réponse
        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la récupération de la réponse: ${e.toString()}")),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.characterImage != null)
              CircleAvatar(
                backgroundImage:
                NetworkImage('https://yodai.wevox.cloud/image_data/${widget.characterImage}'),
              ),
            SizedBox(width: 10),
            Text(widget.characterName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading && _chatController.messages.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _chatController.messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _chatController.messages[index]);
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      "${widget.characterName} est en train d'écrire...",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(width: 8),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[500]!),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          MessageInput(controller: _messageController, onSend: _sendMessage),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;

  ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    bool isUser = message.isSentByHuman;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.orangeAccent : Colors.grey[800],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isUser ? Radius.circular(12) : Radius.zero,
            bottomRight: isUser ? Radius.zero : Radius.circular(12),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  MessageInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey[700]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Envoyer un message...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.send, color: Colors.orangeAccent),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}