class ClientMagasinEntity {
  final String clientId;
  final String magasinId;
  final double cumulePoint;
  final double solde;

  ClientMagasinEntity({
    required this.clientId,
    required this.magasinId,
    required this.cumulePoint,
    required this.solde,
  });

  factory ClientMagasinEntity.fromJson(Map<String, dynamic> json) {
    return ClientMagasinEntity(
      clientId: json['client_id'],
      magasinId: json['magasin_id'],
      cumulePoint: json['cumulpoint']?.toDouble() ?? 0.0,
      solde: json['solde']?.toDouble() ?? 0.0,
    );
  }
}