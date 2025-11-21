// caissier_state.dart
import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/caissier_home_screen.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/scan_client_screen.dart';

import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';
import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class CaissierState {}

class CaissierInitial extends CaissierState {}

class CaissierLoading extends CaissierState {
  
}

class CaissierError extends CaissierState {
  final String message;
  
  CaissierError({required this.message});
}


class SoldeAjoute extends CaissierState {
  final ClientMagasinEntity clientMagasin;
  SoldeAjoute({required this.clientMagasin});
}

class SoldeCodeUniqueAjoute extends CaissierState {
  final ClientMagasinEntity clientMagasin;
  SoldeCodeUniqueAjoute({required this.clientMagasin});
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
  final int pointsDeduits;
  RecompenseReclamee({required this.message,required this.pointsDeduits});
}

class CurrentMagasinLoaded extends CaissierState {
  final MagasinModel magasin;
  CurrentMagasinLoaded({required this.magasin});
}


class CaissierAuthenticationRequired extends CaissierState {
  final String message;
  CaissierAuthenticationRequired({
    this.message = 'Veuillez vous connecter pour continuer'
  });
}

