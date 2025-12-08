/// Entité représentant un client du programme de fidélité.
///
/// Un client est un utilisateur final qui accumule des points
/// dans différents magasins et peut réclamer des récompenses.
///
/// ### Exemple:
/// ```dart
/// final client = Client(
///   id: 'uuid',
///   prenom: 'Mohamed',
///   nom: 'Alami',
///   email: 'mohamed@example.com',
///   telephone: '+212600000000',
///   adresse: 'Casablanca',
///   code_unique: 12345678,
/// );
/// print(client.fullName); // Mohamed Alami
/// ```
library;

/// Entité Client.
///
/// Représente un client du programme de fidélité
/// avec ses informations personnelles.
class Client {
  /// Identifiant unique (UUID)
  final String id;

  /// Prénom du client
  final String prenom;

  /// Nom de famille du client
  final String nom;

  /// Adresse email
  final String email;

  /// Numéro de téléphone
  final String telephone;

  /// Adresse postale
  final String adresse;

  /// Code unique de fidélité (8 chiffres)
  // ignore: non_constant_identifier_names
  final int code_unique;

  /// Crée une instance de [Client].
  const Client({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.adresse,
    // ignore: non_constant_identifier_names
    required this.code_unique,
  });

  /// Nom complet du client.
  String get fullName => '$prenom $nom'.trim();

  /// Initiales du client (pour avatar).
  String get initials {
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    final n = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$p$n';
  }

  /// Le client a-t-il un email valide?
  bool get hasValidEmail =>
      email.isNotEmpty && email.contains('@') && email.contains('.');

  /// Le client a-t-il un téléphone?
  bool get hasPhone => telephone.isNotEmpty;

  /// Crée un [Client] depuis un JSON.
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? '',
      prenom: json['prenom'] ?? '',
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      adresse: json['adresse'] ?? '',
      code_unique: json['code_unique'] ?? 0,
    );
  }

  /// Convertit en JSON pour Supabase.
  Map<String, dynamic> toJson() => {
        'id': id,
        'prenom': prenom,
        'nom': nom,
        'email': email,
        'telephone': telephone,
        'adresse': adresse,
        'code_unique': code_unique,
      };

  /// Crée une copie avec des valeurs modifiées.
  Client copyWith({
    String? id,
    String? prenom,
    String? nom,
    String? email,
    String? telephone,
    String? adresse,
    int? codeUnique,
  }) {
    return Client(
      id: id ?? this.id,
      prenom: prenom ?? this.prenom,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      code_unique: codeUnique ?? code_unique,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Client && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Client(id: $id, name: $fullName, code: $code_unique)';
}
