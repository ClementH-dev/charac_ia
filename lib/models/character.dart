class Character {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final int universeId;
  final int creatorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  int? conversationId;

  Character({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.universeId,
    required this.creatorId,
    this.createdAt,
    this.updatedAt,
  });

  String? get imageUrl {
    if (image == null) return null;
    return 'https://yodai.wevox.cloud/image_data/$image';
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      universeId: json['universe_id'],
      creatorId: json['creator_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "image": image,
      "universe_id": universeId,
      "creator_id": creatorId,
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    };
  }
}
