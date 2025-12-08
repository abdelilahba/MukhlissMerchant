import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/client_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/ajouter_solde.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/ajouter_solde_clientcode.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/charger_recompenses_usecase.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/getclient_byuniquecode.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/getcurrent_magazin.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/reclamer_recompense_usecase.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_state.dart';
import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';

// Générer mocks: flutter pub run build_runner build
@GenerateMocks([
  AjouterSoldeUseCase,
  ChargerRecompensesClientUseCase,
  ReclamerRecompenseUseCase,
  GetCurrentMagazin,
  AjouterSoldeClientcode,
  GetclientByuniquecode,
])
import 'caissier_cubit_test.mocks.dart';

/// 🧪 TESTS CAISSIER CUBIT
///
/// Tests complets du CaissierCubit (cœur métier app)
/// Pattern: BlocTest pour tester state management
///
/// COUVERTURE:
/// - Initial state
/// - Ajouter solde client
/// - Ajouter solde via code unique
/// - Charger récompenses
/// - Réclamer récompense
/// - Current magasin
/// - Get client by code
/// - Error handling

void main() {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SETUP
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  late CaissierCubit caissierCubit;
  late MockAjouterSoldeUseCase mockAjouterSolde;
  late MockChargerRecompensesClientUseCase mockChargerRecompenses;
  late MockReclamerRecompenseUseCase mockReclamerRecompense;
  late MockGetCurrentMagazin mockGetCurrentMagazin;
  late MockAjouterSoldeClientcode mockAjouterSoldeClientcode;
  late MockGetclientByuniquecode mockGetclientByuniquecode;

  setUp(() {
    mockAjouterSolde = MockAjouterSoldeUseCase();
    mockChargerRecompenses = MockChargerRecompensesClientUseCase();
    mockReclamerRecompense = MockReclamerRecompenseUseCase();
    mockGetCurrentMagazin = MockGetCurrentMagazin();
    mockAjouterSoldeClientcode = MockAjouterSoldeClientcode();
    mockGetclientByuniquecode = MockGetclientByuniquecode();

    caissierCubit = CaissierCubit(
      ajouterSolde: mockAjouterSolde,
      chargerRecompensesClient: mockChargerRecompenses,
      reclamerRecompense: mockReclamerRecompense,
      getCurrentMagazin: mockGetCurrentMagazin,
      ajouterSoldeClientcode: mockAjouterSoldeClientcode,
      getclientByuniquecode: mockGetclientByuniquecode,
    );
  });

  tearDown(() {
    caissierCubit.close();
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS INITIAL STATE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Initial State', () {
    test('initial state est CaissierInitial', () {
      expect(caissierCubit.state, isA<CaissierInitial>());
    });
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS AJOUTER SOLDE CLIENT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Ajouter Solde Client', () {
    const clientId = 'client-123';
    const magasinId = 'magasin-456';
    const montant = 100.0;

    blocTest<CaissierCubit, CaissierState>(
      'ajouterSoldeClient succès émet Loading puis SoldeAjoute',
      build: () {
        when(mockAjouterSolde.execute(
          clientId: anyNamed('clientId'),
          magasinId: anyNamed('magasinId'),
          montant: anyNamed('montant'),
        )).thenAnswer((_) async => ClientMagasinEntity(
              clientId: clientId,
              magasinId: magasinId,
              cumulePoint: 10.0, // 100 MAD = 10 points
              solde: 100.0,
            ));
        return caissierCubit;
      },
      act: (cubit) => cubit.ajouterSoldeClient(
        clientId: clientId,
        magasinId: magasinId,
        montant: montant,
      ),
      expect: () => [
        isA<CaissierLoading>(),
        isA<SoldeAjoute>()
            .having(
              (s) => s.clientMagasin.cumulePoint,
              'cumulePoint',
              equals(10.0),
            )
            .having(
              (s) => s.clientMagasin.solde,
              'solde',
              equals(100.0),
            ),
      ],
      verify: (_) {
        verify(mockAjouterSolde.execute(
          clientId: clientId,
          magasinId: magasinId,
          montant: montant,
        )).called(1);
      },
    );

    blocTest<CaissierCubit, CaissierState>(
      'ajouterSoldeClient avec erreur émet Loading puis Error',
      build: () {
        when(mockAjouterSolde.execute(
          clientId: anyNamed('clientId'),
          magasinId: anyNamed('magasinId'),
          montant: anyNamed('montant'),
        )).thenThrow(Exception('Erreur réseau'));
        return caissierCubit;
      },
      act: (cubit) => cubit.ajouterSoldeClient(
        clientId: clientId,
        magasinId: magasinId,
        montant: montant,
      ),
      expect: () => [
        isA<CaissierLoading>(),
        isA<CaissierError>()
            .having((s) => s.message, 'message', contains('Erreur réseau')),
      ],
    );
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS AJOUTER SOLDE VIA CODE UNIQUE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Ajouter Solde Via Code Unique', () {
    const uniqueCode = 123456;
    const magasinId = 'magasin-456';
    const montant = 50.0;

    blocTest<CaissierCubit, CaissierState>(
      'ajouterSoldeViaCodeUnique succès émet SoldeCodeUniqueAjoute',
      build: () {
        when(mockAjouterSoldeClientcode.execute(
          magasinId: anyNamed('magasinId'),
          uniqueCode: anyNamed('uniqueCode'),
          montant: anyNamed('montant'),
        )).thenAnswer((_) async => ClientMagasinEntity(
              clientId: 'client-abc',
              magasinId: magasinId,
              cumulePoint: 5.0, // 50 MAD = 5 points
              solde: 50.0,
            ));
        return caissierCubit;
      },
      act: (cubit) => cubit.ajouterSoldeViaCodeUnique(
        uniqueCode: uniqueCode,
        magasinId: magasinId,
        montant: montant,
      ),
      expect: () => [
        isA<CaissierLoading>(),
        isA<SoldeCodeUniqueAjoute>().having(
          (s) => s.clientMagasin.cumulePoint,
          'cumulePoint',
          equals(5.0),
        ),
      ],
    );

    blocTest<CaissierCubit, CaissierState>(
      'ajouterSoldeViaCodeUnique code invalide émet Error',
      build: () {
        when(mockAjouterSoldeClientcode.execute(
          magasinId: anyNamed('magasinId'),
          uniqueCode: anyNamed('uniqueCode'),
          montant: anyNamed('montant'),
        )).thenThrow(Exception('Client non trouvé'));
        return caissierCubit;
      },
      act: (cubit) => cubit.ajouterSoldeViaCodeUnique(
        uniqueCode: 999999,
        magasinId: magasinId,
        montant: montant,
      ),
      expect: () => [
        isA<CaissierLoading>(),
        isA<CaissierError>(),
      ],
    );
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS CHARGER RÉCOMPENSES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Charger Récompenses', () {
    const clientId = 'client-123';
    const magasinId = 'magasin-456';

    final rewards = [
      Reward(
        id: 'reward-1',
        name: 'Café Gratuit',
        requiredPoints: 10,
        shopId: magasinId,
        isActive: true,
      ),
      Reward(
        id: 'reward-2',
        name: 'Réduction 10%',
        requiredPoints: 25,
        shopId: magasinId,
        isActive: true,
      ),
    ];

    blocTest<CaissierCubit, CaissierState>(
      'loadClientRewards succès émet RecompensesChargees avec liste',
      build: () {
        when(mockChargerRecompenses.execute(
          clientId: anyNamed('clientId'),
          magasinId: anyNamed('magasinId'),
        )).thenAnswer((_) async => ChargerRecompensesClientResult(
              rewards: rewards,
              clientPoints: 50,
            ));
        return caissierCubit;
      },
      act: (cubit) => cubit.loadClientRewards(
        clientId: clientId,
        magasinId: magasinId,
      ),
      expect: () => [
        isA<CaissierLoading>(),
        isA<RecompensesChargees>()
            .having((s) => s.rewards.length, 'rewards length', equals(2))
            .having((s) => s.clientPoints, 'clientPoints', equals(50)),
      ],
    );

    blocTest<CaissierCubit, CaissierState>(
      'loadClientRewards avec liste vide émet RecompensesChargees vide',
      build: () {
        when(mockChargerRecompenses.execute(
          clientId: anyNamed('clientId'),
          magasinId: anyNamed('magasinId'),
        )).thenAnswer((_) async => ChargerRecompensesClientResult(
              rewards: [],
              clientPoints: 0,
            ));
        return caissierCubit;
      },
      act: (cubit) => cubit.loadClientRewards(
        clientId: clientId,
        magasinId: magasinId,
      ),
      expect: () => [
        isA<CaissierLoading>(),
        isA<RecompensesChargees>()
            .having((s) => s.rewards, 'rewards', isEmpty)
            .having((s) => s.clientPoints, 'clientPoints', equals(0)),
      ],
    );

    blocTest<CaissierCubit, CaissierState>(
      'loadClientRewards avec erreur émet Error',
      build: () {
        when(mockChargerRecompenses.execute(
          clientId: anyNamed('clientId'),
          magasinId: anyNamed('magasinId'),
        )).thenThrow(Exception('Erreur chargement'));
        return caissierCubit;
      },
      act: (cubit) => cubit.loadClientRewards(
        clientId: clientId,
        magasinId: magasinId,
      ),
      expect: () => [
        isA<CaissierLoading>(),
        isA<CaissierError>(),
      ],
    );
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS RÉCLAMER RÉCOMPENSE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Réclamer Récompense', () {
    const clientId = 'client-123';
    const magasinId = 'magasin-456';
    const rewardId = 'reward-cafe';
    const pointsRequired = 10;
    const pointsAvant = 50;

    blocTest<CaissierCubit, CaissierState>(
      'claimReward succès émet RecompenseReclamee avec points restants',
      build: () {
        // Mock chargerRecompenses pour retourner points avant
        when(mockChargerRecompenses.execute(
          clientId: anyNamed('clientId'),
          magasinId: anyNamed('magasinId'),
        )).thenAnswer((_) async => ChargerRecompensesClientResult(
              rewards: [],
              clientPoints: pointsAvant,
            ));

        // Mock reclamerRecompense
        when(mockReclamerRecompense.execute(
          clientId: anyNamed('clientId'),
          magasinId: anyNamed('magasinId'),
          rewardId: anyNamed('rewardId'),
          pointsRequired: anyNamed('pointsRequired'),
        )).thenAnswer((_) async => Future.value());

        return caissierCubit;
      },
      act: (cubit) => cubit.claimReward(
        clientId: clientId,
        magasinId: magasinId,
        rewardId: rewardId,
        pointsRequired: pointsRequired,
      ),
      expect: () => [
        isA<RecompenseReclamee>()
            .having(
              (s) => s.pointsDeduits,
              'pointsRestants',
              equals(40), // 50 - 10 = 40
            )
            .having(
              (s) => s.message,
              'message',
              contains('succès'),
            ),
      ],
    );

    blocTest<CaissierCubit, CaissierState>(
      'claimReward avec points insuffisants émet Error',
      build: () {
        when(mockChargerRecompenses.execute(
          clientId: anyNamed('clientId'),
          magasinId: anyNamed('magasinId'),
        )).thenAnswer((_) async => ChargerRecompensesClientResult(
              rewards: [],
              clientPoints: 5, // Seulement 5 points
            ));

        when(mockReclamerRecompense.execute(
          clientId: anyNamed('clientId'),
          magasinId: anyNamed('magasinId'),
          rewardId: anyNamed('rewardId'),
          pointsRequired: anyNamed('pointsRequired'),
        )).thenThrow(Exception('Points insuffisants'));

        return caissierCubit;
      },
      act: (cubit) => cubit.claimReward(
        clientId: clientId,
        magasinId: magasinId,
        rewardId: rewardId,
        pointsRequired: pointsRequired,
      ),
      expect: () => [
        isA<CaissierError>().having(
            (s) => s.message, 'message', contains('Points insuffisants')),
      ],
    );
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS GET CURRENT MAGASIN
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Get Current Magasin', () {
    final magasin = MagasinModel(
      id: 'magasin-123',
      nomEnseigne: 'Boutique Test',
      adresse: 'Casablanca',
      telephone: '+212600000000',
      siret: '12345678901234',
      ville: 'Casablanca',
      codePostal: '20000',
      description: 'Test magasin',
      geom: {
        'type': 'Point',
        'coordinates': [-7.5, 33.5]
      },
      categorieId: 1,
      imageUrl: '',
      email: 'test@mukhliss.com',
    );

    blocTest<CaissierCubit, CaissierState>(
      'getCurrentMagasin succès émet CurrentMagasinLoaded',
      build: () {
        when(mockGetCurrentMagazin.execute()).thenAnswer((_) async => magasin);
        return caissierCubit;
      },
      act: (cubit) => cubit.getCurrentMagasin(),
      expect: () => [
        isA<CaissierLoading>(),
        isA<CurrentMagasinLoaded>()
            .having((s) => s.magasin.id, 'magasinId', equals('magasin-123'))
            .having((s) => s.magasin.nomEnseigne, 'nomEnseigne',
                equals('Boutique Test')),
      ],
    );

    blocTest<CaissierCubit, CaissierState>(
      'getCurrentMagasin sans auth émet AuthenticationRequired',
      build: () {
        when(mockGetCurrentMagazin.execute())
            .thenThrow(Exception('Aucun utilisateur connecté'));
        return caissierCubit;
      },
      act: (cubit) async {
        try {
          await cubit.getCurrentMagasin();
        } catch (e) {
          // Exception attendue
        }
      },
      expect: () => [
        isA<CaissierLoading>(),
        isA<CaissierAuthenticationRequired>(),
      ],
    );
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS GET CLIENT BY CODE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Get Client By Code', () {
    const uniqueCode = 123456;

    final client = Client(
      id: 'client-abc',
      nom: 'Ahmed',
      prenom: 'Alami',
      email: 'ahmed@gmail.com',
      telephone: '+212612345678',
      adresse: 'Casablanca',
      code_unique: uniqueCode,
    );

    test('getClientByUniqueCode succès retourne Client', () async {
      // ARRANGE
      when(mockGetclientByuniquecode.execute(uniqueCode: uniqueCode))
          .thenAnswer((_) async => client);

      // ACT
      final result = await caissierCubit.getClientByUniqueCode(uniqueCode);

      // ASSERT
      expect(result, isNotNull);
      expect(result.id, equals('client-abc'));
      expect(result.nom, equals('Ahmed'));
      verify(mockGetclientByuniquecode.execute(uniqueCode: uniqueCode))
          .called(1);
    });

    test('getClientByUniqueCode code invalide throw exception', () async {
      // ARRANGE
      when(mockGetclientByuniquecode.execute(
              uniqueCode: anyNamed('uniqueCode')))
          .thenThrow(Exception('Client non trouvé'));

      // ACT & ASSERT
      expect(
        () => caissierCubit.getClientByUniqueCode(999999),
        throwsException,
      );
    });
  });
}
