class MagasinModel {
  final String id;
  final String nomEnseigne;
  final String siret;
  final String adresse;
  final String ville;
  final String codePostal;
  final String telephone;
  final String description;
  final Map<String, dynamic> geom;
  final int categorieId;

  MagasinModel({
    required this.id,
    required this.nomEnseigne,
    required this.siret,
    required this.adresse,
    required this.ville,
    required this.codePostal,
    required this.telephone,
    required this.description,
    required this.geom,
    required this.categorieId,
  });

  factory MagasinModel.fromJson(Map<String, dynamic> json) {
    return MagasinModel(
      id: json['id'],
      nomEnseigne: json['nom_enseigne'],
      siret: json['siret'],
      adresse: json['adresse'],
      ville: json['ville'],
      codePostal: json['code_postal'],
      telephone: json['telephone'],
      description: json['description'],
      geom: json['geom'],
      categorieId: json['categorie_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom_enseigne': nomEnseigne,
      'siret': siret,
      'adresse': adresse,
      'ville': ville,
      'code_postal': codePostal,
      'telephone': telephone,
      'description': description,
      'geom': geom,
      'categorie_id': categorieId,
    };
  }

  double get latitude => geom['coordinates'][1].toDouble();
  double get longitude => geom['coordinates'][0].toDouble();

  // Pour la conversion vers/depuis les coordonnées
  MagasinModel copyWithGeoPoint(double lat, double lng) {
    return MagasinModel(
      id: id,
      nomEnseigne: nomEnseigne,
      siret: siret,
      adresse: adresse,
      ville: ville,
      codePostal: codePostal,
      telephone: telephone,
      description: description,
      geom: {
        'type': 'Point',
        'coordinates': [lng, lat],
      },
      categorieId: categorieId,
    );
  }
}