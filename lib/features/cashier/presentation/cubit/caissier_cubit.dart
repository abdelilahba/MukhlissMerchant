// caissier_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/ajouter_solde.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/charger_recompenses_usecase.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/getcurrent_magazin.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/reclamer_recompense_usecase.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_state.dart';
import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';


class CaissierCubit extends Cubit<CaissierState> {
  final AjouterSoldeUseCase ajouterSolde;
  final ChargerRecompensesClientUseCase chargerRecompensesClient;
  final ReclamerRecompenseUseCase reclamerRecompense;
   final GetCurrentMagazin getCurrentMagazin;
  CaissierCubit({
    required this.ajouterSolde,
    required this.chargerRecompensesClient,
    required this.reclamerRecompense,
    required this.getCurrentMagazin,
  }) : super(CaissierInitial());

  Future<void> ajouterSoldeClient({
    required String clientId,
    required String magasinId,
    required double montant,
  }) async {
    emit(CaissierLoading());
    try {
      final clientMagasin = await ajouterSolde.execute(
        clientId: clientId,
        magasinId: magasinId,
        montant: montant,
      );
      emit(SoldeAjoute(clientMagasin: clientMagasin));
    } catch (e) {
      emit(CaissierError(message: e.toString()));
    }
  }

  



  Future<void> loadClientRewards({
    required String clientId,
    required String magasinId,
  }) async {
    emit(CaissierLoading());
    try {
      final result = await chargerRecompensesClient.execute(
        clientId: clientId,
        magasinId: magasinId,
      );
      emit(RecompensesChargees(
        rewards: result.rewards,
        clientPoints: result.clientPoints,
      ));
    } catch (e) {
      emit(CaissierError(message: e.toString()));
    }
  }

  Future<void> claimReward({
    required String clientId,
    required String magasinId,
    required String rewardId,
    required int pointsRequired,
  }) async {
    emit(CaissierLoading());
    try {
      await reclamerRecompense.execute(
        clientId: clientId,
        magasinId: magasinId,
        rewardId: rewardId,
        pointsRequired: pointsRequired,
      );
      emit(RecompenseReclamee(message: 'Récompense réclamée avec succès',pointsDeduits:pointsRequired));
    } catch (e) {
      emit(CaissierError(message: e.toString()));
    }
  }

// Dans CaissierCubit
Future<MagasinModel> getCurrentMagasin() async {
  emit(CaissierLoading());
  try {
    MagasinModel magasin = await getCurrentMagazin.execute();
    emit(CurrentMagasinLoaded(magasin: magasin));
    return magasin;
  } catch (e) {
    emit(CaissierError(message: e.toString()));
    throw Exception('Failed to load current magasin: $e');
  }
}

}