class Client {
  final String id;
  final String prenom;
  final String email;
  final String nom;
  final String telephone ;
  final String adresse;
  final int code_unique;

  Client({
    required this.id,
    required this.prenom,
    required this.email,
    required this.nom,
    required this.telephone,
    required this.adresse,
    required this.code_unique,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      prenom: json['prenom'],
      email: json['email'],
      nom: json['nom'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      code_unique: json['code_unique'],
    );
  }
}