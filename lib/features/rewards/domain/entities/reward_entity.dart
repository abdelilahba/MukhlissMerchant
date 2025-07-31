// features/rewards/domain/entities/reward_entity.dart
class Reward {
  final String id;
  final String name;
  final int requiredPoints;

  final String shopId;
  final String? shopName; // Optionnel (rempli via jointure SQL)
  final bool isActive;
  Reward({
    required this.id,
    required this.name,
    required this.requiredPoints,

    required this.shopId,
    this.shopName,
    required this.isActive
  });

  // Conversion vers JSON pour Supabase
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'points_required': requiredPoints,
   
    'magasin_id': shopId,
    'is_active':isActive
  };

  // Création depuis JSON (pour les requêtes)
  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    requiredPoints: json['points_required'] ?? 0,
   
    shopId: json['magasin_id'] ?? '',
    shopName: json['shops']?['name'],
    isActive: json['is_active']
  );

  Reward copyWith({
    String? id,
    String? title,
    String? description,
    int? requiredPoints,
   
    String? shopId,
    bool? isActive // Nouveau paramètre optionnel
  }) {
    return Reward(
      id: id ?? this.id,
      name: title ?? this.name,
      requiredPoints: requiredPoints ?? this.requiredPoints,
    
      shopId:
          shopId ??
          this.shopId, // Conservation de la valeur existante si non fournie
      isActive: isActive ?? this.isActive
    );
  }
}
