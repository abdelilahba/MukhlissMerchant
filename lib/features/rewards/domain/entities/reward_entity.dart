// features/rewards/domain/entities/reward_entity.dart
class Reward {
  final String id;
  final String name;
  final int requiredPoints;
  final String? imageUrl; // NEW: URL de l'image prédéfinie
  final String shopId;
  final String? shopName;
  final bool isActive;

  Reward({
    required this.id,
    required this.name,
    required this.requiredPoints,
    this.imageUrl,
    required this.shopId,
    this.shopName,
    required this.isActive,
  });

  // Conversion vers JSON pour Supabase
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'points_required': requiredPoints,
    'magasin_id': shopId,
    'is_active': isActive,
    'image_url': imageUrl,
  };

  // Création depuis JSON
  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    requiredPoints: json['points_required'] ?? 0,
    imageUrl: json['image_url'],
    shopId: json['magasin_id'] ?? '',
    shopName: json['shops']?['name'],
    isActive: json['is_active'],
  );

  Reward copyWith({
    String? id,
    String? title,
    String? description,
    int? requiredPoints,
    String? imageUrl,
    String? shopId,
    bool? isActive,
  }) {
    return Reward(
      id: id ?? this.id,
      name: title ?? name,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      imageUrl: imageUrl ?? this.imageUrl,
      shopId: shopId ?? this.shopId,
      isActive: isActive ?? this.isActive,
    );
  }
}
