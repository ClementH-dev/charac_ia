class Message {
  final int id;
  final String content;
  final bool isSentByHuman;
  final int? conversationId;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.content,
    required this.isSentByHuman,
    this.conversationId,
    required this.createdAt
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      isSentByHuman: json['is_sent_by_human'],
      conversationId: json['conversation_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "content": content,
      "is_sent_by_human": isSentByHuman,
      "conversation_id": conversationId,
      "created_at": createdAt?.toIso8601String(),
    };
  }
}
