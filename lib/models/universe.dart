class Universe {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final int? creatorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Universe({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.creatorId,
    this.createdAt,
    this.updatedAt,
  });

  String? get imageUrl {
    if (image == null) return null;
    return 'https://yodai.wevox.cloud/image_data/$image';
  }

  factory Universe.fromJson(Map<String, dynamic> json) {
    return Universe(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      creatorId: json['creatorId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "image": image,
    "creator_id": creatorId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
