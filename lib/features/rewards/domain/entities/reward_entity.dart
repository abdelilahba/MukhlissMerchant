// features/rewards/domain/entities/reward_entity.dart
class Reward {
  final String id;
  final String name;
  final int requiredPoints;
  final String? imagePath;
  final String shopId;
  final String? shopName; // Optionnel (rempli via jointure SQL)

  Reward({
    required this.id,
    required this.name,
    required this.requiredPoints,
    this.imagePath,
    required this.shopId,
    this.shopName,
  });

  // Conversion vers JSON pour Supabase
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'points_required': requiredPoints,
    'image_url': imagePath,
    'magasin_id': shopId,
  };

  // Création depuis JSON (pour les requêtes)
  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    requiredPoints: json['points_required'] ?? 0,
    imagePath: json['image_url'],
    shopId: json['magasin_id'] ?? '',
    shopName: json['shops']?['name'],
  );

  Reward copyWith({
    String? id,
    String? title,
    String? description,
    int? requiredPoints,
    String? imageUrl,
    String? shopId, // Nouveau paramètre optionnel
  }) {
    return Reward(
      id: id ?? this.id,
      name: title ?? this.name,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      imagePath: imageUrl ?? this.imagePath,
      shopId:
          shopId ??
          this.shopId, // Conservation de la valeur existante si non fournie
    );
  }
}
