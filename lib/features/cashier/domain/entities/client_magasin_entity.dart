/// Entité représentant la relation client-magasin.
///
/// Stocke les informations spécifiques à un client
/// dans un magasin particulier (points, solde).
///
/// ### Exemple:
/// ```dart
/// final relation = ClientMagasinEntity(
///   clientId: 'client_123',
///   magasinId: 'magasin_456',
///   cumulePoint: 150,
///   solde: 500.0,
/// );
/// print('Points: ${relation.cumulePoint}');
/// print('Solde: ${relation.formattedSolde}'); // 500.00 DH
/// ```
library;

/// Entité de relation Client-Magasin.
///
/// Représente le compte fidélité d'un client
/// dans un magasin spécifique.
class ClientMagasinEntity {
  /// ID du client
  final String clientId;

  /// ID du magasin
  final String magasinId;

  /// Points cumulés dans ce magasin
  final double cumulePoint;

  /// Solde total dépensé (en MAD)
  final double solde;

  /// Crée une instance de [ClientMagasinEntity].
  const ClientMagasinEntity({
    required this.clientId,
    required this.magasinId,
    required this.cumulePoint,
    required this.solde,
  });

  /// Points en entier (arrondi inférieur).
  int get pointsAsInt => cumulePoint.floor();

  /// Solde formaté avec devise.
  String get formattedSolde => '${solde.toStringAsFixed(2)} DH';

  /// Points formatés.
  String get formattedPoints => '$pointsAsInt pts';

  /// Le client a-t-il des points?
  bool get hasPoints => cumulePoint > 0;

  /// Le client a-t-il un solde?
  bool get hasSolde => solde > 0;

  /// Crée un [ClientMagasinEntity] depuis un JSON.
  factory ClientMagasinEntity.fromJson(Map<String, dynamic> json) {
    return ClientMagasinEntity(
      clientId: json['client_id'] ?? '',
      magasinId: json['magasin_id'] ?? '',
      cumulePoint: (json['cumulpoint'] ?? 0).toDouble(),
      solde: (json['solde'] ?? 0).toDouble(),
    );
  }

  /// Convertit en JSON pour Supabase.
  Map<String, dynamic> toJson() => {
        'client_id': clientId,
        'magasin_id': magasinId,
        'cumulpoint': cumulePoint,
        'solde': solde,
      };

  /// Crée une copie avec des valeurs modifiées.
  ClientMagasinEntity copyWith({
    String? clientId,
    String? magasinId,
    double? cumulePoint,
    double? solde,
  }) {
    return ClientMagasinEntity(
      clientId: clientId ?? this.clientId,
      magasinId: magasinId ?? this.magasinId,
      cumulePoint: cumulePoint ?? this.cumulePoint,
      solde: solde ?? this.solde,
    );
  }

  /// Crée une nouvelle entité avec des points ajoutés.
  ClientMagasinEntity withAddedPoints(double points) {
    return copyWith(cumulePoint: cumulePoint + points);
  }

  /// Crée une nouvelle entité avec du solde ajouté.
  ClientMagasinEntity withAddedSolde(double amount) {
    return copyWith(solde: solde + amount);
  }

  /// Crée une nouvelle entité avec des points déduits.
  ClientMagasinEntity withDeductedPoints(double points) {
    final newPoints = cumulePoint - points;
    return copyWith(cumulePoint: newPoints < 0 ? 0 : newPoints);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientMagasinEntity &&
          runtimeType == other.runtimeType &&
          clientId == other.clientId &&
          magasinId == other.magasinId;

  @override
  int get hashCode => Object.hash(clientId, magasinId);

  @override
  String toString() =>
      'ClientMagasin(client: $clientId, magasin: $magasinId, points: $cumulePoint, solde: $solde)';
}
