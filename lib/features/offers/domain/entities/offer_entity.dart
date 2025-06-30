class Offer {
  final String id;
  final double minAmount;
  final int pointsGiven;
  final String magasinId; // Nouveau champ

  Offer({
    required this.id,
    required this.minAmount,
    required this.pointsGiven,
    required this.magasinId, // Ajouté
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'min_amount': minAmount,
      'points_given': pointsGiven,
      'magasin_id': magasinId, // Ajouté
    };
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as String,
      minAmount: (json['min_amount'] as num).toDouble(),
      pointsGiven: json['points_given'] as int,
      magasinId: json['magasin_id'] as String, // Ajouté
    );
  }

  Offer copyWith({
    String? id,
    double? minAmount,
    int? pointsGiven,
    String? magasinId, // Ajouté
  }) {
    return Offer(
      id: id ?? this.id,
      minAmount: minAmount ?? this.minAmount,
      pointsGiven: pointsGiven ?? this.pointsGiven,
      magasinId: magasinId ?? this.magasinId, // Ajouté
    );
  }
}