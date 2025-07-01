// caissier_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/ajouter_solde.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/charger_offres_client.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/echanger_offre.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/charger_recompenses_client_usecase.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/reclamer_recompense_usecase.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_state.dart';

class CaissierCubit extends Cubit<CaissierState> {
  final AjouterSoldeUseCase ajouterSolde;
  final ChargerOffresClientUseCase chargerOffresClient;
  final EchangerOffreUseCase echangerOffre;
  final ChargerRecompensesClientUseCase chargerRecompensesClient;
  final ReclamerRecompenseUseCase reclamerRecompense;

  CaissierCubit({
    required this.ajouterSolde,
    required this.chargerOffresClient,
    required this.echangerOffre,
    required this.chargerRecompensesClient,
    required this.reclamerRecompense,
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

  Future<void> loadClientOffers({
    required String clientId,
    required String magasinId,
  }) async {
    emit(CaissierLoading());
    try {
      final result = await chargerOffresClient.execute(
        clientId: clientId,
        magasinId: magasinId,
      );
      emit(OffresChargees(
        offers: result.offers,
        clientSolde: result.clientSolde,
      ));
    } catch (e) {
      emit(CaissierError(message: e.toString()));
    }
  }

  Future<void> exchangeOffer({
    required String clientId,
    required String magasinId,
    required String offreId,
    required double montantSolde,
    required int points,
  }) async {
    emit(CaissierLoading());
    try {
      await echangerOffre.execute(
        clientId: clientId,
        magasinId: magasinId,
        offreId: offreId,
        montantSolde: montantSolde,
        points: points,
      );
      emit(OffreEchangee(message: 'Offre échangée avec succès'));
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
      emit(RecompenseReclamee(message: 'Récompense réclamée avec succès'));
    } catch (e) {
      emit(CaissierError(message: e.toString()));
    }
  }
}