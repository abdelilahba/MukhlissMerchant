abstract class CaissierState {}

class CaissierInitial extends CaissierState {}

class CaissierLoading extends CaissierState {}

class SoldeAjoute extends CaissierState {
  final dynamic clientMagasin;

  SoldeAjoute({required this.clientMagasin});
}

class OffresChargees extends CaissierState {
  final List<dynamic> offers;
  final double clientSolde;

  OffresChargees({
    required this.offers,
    required this.clientSolde,
  });
}

class OffreEchangee extends CaissierState {
  final String message;

  OffreEchangee({required this.message});
}

class CaissierError extends CaissierState {
  final String message;

  CaissierError({required this.message});
}