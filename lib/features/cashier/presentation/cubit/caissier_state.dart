// caissier_state.dart
import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';

abstract class CaissierState {}

class CaissierInitial extends CaissierState {}

class CaissierLoading extends CaissierState {}

class CaissierError extends CaissierState {
  final String message;
  CaissierError({required this.message});
}

class SoldeAjoute extends CaissierState {
  final ClientMagasinEntity clientMagasin;
  SoldeAjoute({required this.clientMagasin});
}

class OffresChargees extends CaissierState {
  final List<Offer> offers;
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

class RecompensesChargees extends CaissierState {
  final List<Reward> rewards;
  final int clientPoints;
  RecompensesChargees({
    required this.rewards,
    required this.clientPoints,
  });
}

class RecompenseReclamee extends CaissierState {
  final String message;
  RecompenseReclamee({required this.message});
}