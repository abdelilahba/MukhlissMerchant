// caissier_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/client_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/ajouter_solde.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/ajouter_solde_clientcode.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/charger_recompenses_usecase.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/getclient_byuniquecode.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/getcurrent_magazin.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/reclamer_recompense_usecase.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_state.dart';
import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';

class CaissierCubit extends Cubit<CaissierState> {
  final AjouterSoldeUseCase ajouterSolde;
  final ChargerRecompensesClientUseCase chargerRecompensesClient;
  final ReclamerRecompenseUseCase reclamerRecompense;
  final GetCurrentMagazin getCurrentMagazin;
  final AjouterSoldeClientcode ajouterSoldeClientcode;
  final GetclientByuniquecode getclientByuniquecode;

  CaissierCubit({
    required this.ajouterSolde,
    required this.chargerRecompensesClient,
    required this.reclamerRecompense,
    required this.getCurrentMagazin,
    required this.ajouterSoldeClientcode,
    required this.getclientByuniquecode,
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

  Future<void> ajouterSoldeViaCodeUnique({
    required int uniqueCode,
    required String magasinId,
    required double montant,
  }) async {
    emit(CaissierLoading());
    try {

           final clientMagasin = await ajouterSoldeClientcode.execute(
        magasinId: magasinId,
        uniqueCode: uniqueCode,
        montant: montant,
      );

      emit(SoldeCodeUniqueAjoute(clientMagasin: clientMagasin));
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
      emit(
        RecompensesChargees(
          rewards: result.rewards,
          clientPoints: result.clientPoints,
        ),
      );
    } catch (e) {
      emit(CaissierError(message: e.toString()));
    }
  }

  // ✅ CORRECTION : Méthode claimReward modifiée pour calculer les points restants
  Future<void> claimReward({
    required String clientId,
    required String magasinId,
    required String rewardId,
    required int pointsRequired,
  }) async {
    // ❌ NE PAS émettre CaissierLoading() ici !
    // L'UI affiche déjà un dialogue de chargement élégant
    // emit(CaissierLoading());
    
    try {
      // ✅ 1. Récupérer d'abord les points actuels du client
      final result = await chargerRecompensesClient.execute(
        clientId: clientId,
        magasinId: magasinId,
      );
      final pointsAvantEchange = result.clientPoints;



      // ✅ 2. Réclamer la récompense
      await reclamerRecompense.execute(
        clientId: clientId,
        magasinId: magasinId,
        rewardId: rewardId,
        pointsRequired: pointsRequired,
      );

      // ✅ 3. Calculer les points RESTANTS après l'échange
      final pointsRestants = pointsAvantEchange - pointsRequired;

      // ✅ 4. Émettre l'état avec les points RESTANTS (pas les points déduits)
      emit(
        RecompenseReclamee(
          message: 'Récompense réclamée avec succès',
          pointsDeduits:
              pointsRestants, // Note: bien que nommé "pointsDeduits", c'est les points RESTANTS
        ),
      );
    } catch (e) {
      emit(CaissierError(message: e.toString()));
    }
  }

  Future<MagasinModel> getCurrentMagasin() async {
    emit(CaissierLoading());
    try {
      MagasinModel magasin = await getCurrentMagazin.execute();
      emit(CurrentMagasinLoaded(magasin: magasin));
      return magasin;
    } catch (e) {
      // ✅ Vérifier si c'est une erreur d'authentification
      if (e.toString().contains('Aucun utilisateur connecté')) {
        emit(CaissierAuthenticationRequired());
        rethrow;
      }

      emit(CaissierError(message: e.toString()));
      rethrow;
    }
  }

  Future<Client> getClientByUniqueCode(int uniqueCode) async {
    try {
      return await getclientByuniquecode.execute(uniqueCode: uniqueCode);
    } catch (e) {
      rethrow;
    }
  }
}
