import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/reclamer_recompense_usecase.dart';

// Utilise le même mock
import 'ajouter_solde_test.mocks.dart';

/// 🧪 TESTS USE CASE - RÉCLAMER RÉCOMPENSE
/// 
/// Tests du use case de réclamation de récompense
/// FONCTIONNALITÉ CRITIQUE: Client échange points contre récompense
/// 
/// RÈGLES MÉTIER:
/// - Client doit avoir ≥ points requis
/// - Points déduits atomiquement
/// - Récompense doit être active
/// - Historique transaction créé
/// 
/// COUVERTURE:
/// - Réclamation succès
/// - Points insuffisants
/// - Récompense invalide
/// - Erreurs

void main() {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SETUP
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  late ReclamerRecompenseUseCase reclamerRecompenseUseCase;
  late MockCaissierRepository mockRepository;
  
  setUp(() {
    mockRepository = MockCaissierRepository();
    reclamerRecompenseUseCase = ReclamerRecompenseUseCase(
      repository: mockRepository,
    );
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS SUCCÈS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('Réclamer Récompense - Succès', () {
    
    // ✅ TEST 1: Réclamer récompense avec points suffisants
    test('réclamer récompense avec points suffisants réussit', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      const rewardId = 'reward-cafe';
      const pointsRequired = 10;
      
      when(mockRepository.claimReward(
        clientId: clientId,
        magasinId: magasinId,
        rewardId: rewardId,
        pointsRequired: pointsRequired,
      )).thenAnswer((_) async => Future.value());
      
      // ACT
      await reclamerRecompenseUseCase.execute(
        clientId: clientId,
        magasinId: magasinId,
        rewardId: rewardId,
        pointsRequired: pointsRequired,
      );
      
      // ASSERT: Vérifier que claimReward a été appelé
      verify(mockRepository.claimReward(
        clientId: clientId,
        magasinId: magasinId,
        rewardId: rewardId,
        pointsRequired: pointsRequired,
      )).called(1);
    });
    
    // ✅ TEST 2: Réclamer récompense 50 points
    test('réclamer récompense haut de gamme (50 points)', () async {
      // ARRANGE
      const clientId = 'client-premium';
      const magasinId = 'magasin-456';
      const rewardId = 'reward-premium';
      const pointsRequired = 50;
      
      when(mockRepository.claimReward(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
        rewardId: anyNamed('rewardId'),
        pointsRequired: anyNamed('pointsRequired'),
      )).thenAnswer((_) async => Future.value());
      
      // ACT
      await reclamerRecompenseUseCase.execute(
        clientId: clientId,
        magasinId: magasinId,
        rewardId: rewardId,
        pointsRequired: pointsRequired,
      );
      
      // ASSERT
      verify(mockRepository.claimReward(
        clientId: clientId,
        magasinId: magasinId,
        rewardId: rewardId,
        pointsRequired: 50,
      )).called(1);
    });
    
    // ✅ TEST 3: Réclamation passe tous les paramètres
    test('réclamation passe clientId, magasinId, rewardId et points au repository', () async {
      // ARRANGE
      const clientId = 'client-abc';
      const magasinId = 'magasin-xyz';
      const rewardId = 'reward-123';
      const pointsRequired = 25;
      
      when(mockRepository.claimReward(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
        rewardId: anyNamed('rewardId'),
        pointsRequired: anyNamed('pointsRequired'),
      )).thenAnswer((_) async => Future.value());
      
      // ACT
      await reclamerRecompenseUseCase.execute(
        clientId: clientId,
        magasinId: magasinId,
        rewardId: rewardId,
        pointsRequired: pointsRequired,
      );
      
      // ASSERT: Vérifier tous les paramètres
      verify(mockRepository.claimReward(
        clientId: clientId,
        magasinId: magasinId,
        rewardId: rewardId,
        pointsRequired: pointsRequired,
      )).called(1);
      
      verifyNoMoreInteractions(mockRepository);
    });
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS ÉCHEC
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('Réclamer Récompense - Échec', () {
    
    // ❌ TEST 4: Points insuffisants throw exception
    test('points insuffisants throw exception', () async {
      // ARRANGE
      const clientId = 'client-pauvre';
      const magasinId = 'magasin-456';
      const rewardId = 'reward-cher';
      const pointsRequired = 100; // Client n'a que 50 points
      
      when(mockRepository.claimReward(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
        rewardId: anyNamed('rewardId'),
        pointsRequired: anyNamed('pointsRequired'),
      )).thenThrow(Exception('Points insuffisants'));
      
      // ACT & ASSERT
      expect(
        () => reclamerRecompenseUseCase.execute(
          clientId: clientId,
          magasinId: magasinId,
          rewardId: rewardId,
          pointsRequired: pointsRequired,
        ),
        throwsException,
      );
    });
    
    // ❌ TEST 5: Récompense inexistante throw exception
    test('récompense inexistante throw exception', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      const rewardId = 'reward-inexistant';
      const pointsRequired = 10;
      
      when(mockRepository.claimReward(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
        rewardId: anyNamed('rewardId'),
        pointsRequired: anyNamed('pointsRequired'),
      )).thenThrow(Exception('Récompense non trouvée'));
      
      // ACT & ASSERT
      expect(
        () => reclamerRecompenseUseCase.execute(
          clientId: clientId,
          magasinId: magasinId,
          rewardId: rewardId,
          pointsRequired: pointsRequired,
        ),
        throwsException,
      );
    });
    
    // ❌ TEST 6: Récompense inactive throw exception
    test('récompense inactive throw exception', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      const rewardId = 'reward-inactive';
      const pointsRequired = 10;
      
      when(mockRepository.claimReward(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
        rewardId: anyNamed('rewardId'),
        pointsRequired: anyNamed('pointsRequired'),
      )).thenThrow(Exception('Récompense non active'));
      
      // ACT & ASSERT
      expect(
        () => reclamerRecompenseUseCase.execute(
          clientId: clientId,
          magasinId: magasinId,
          rewardId: rewardId,
          pointsRequired: pointsRequired,
        ),
        throwsException,
      );
    });
    
    // ❌ TEST 7: Erreur réseau throw exception
    test('erreur réseau throw exception', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      const rewardId = 'reward-cafe';
      const pointsRequired = 10;
      
      when(mockRepository.claimReward(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
        rewardId: anyNamed('rewardId'),
        pointsRequired: anyNamed('pointsRequired'),
      )).thenThrow(Exception('Erreur réseau'));
      
      // ACT & ASSERT
      expect(
        () => reclamerRecompenseUseCase.execute(
          clientId: clientId,
          magasinId: magasinId,
          rewardId: rewardId,
          pointsRequired: pointsRequired,
        ),
        throwsA(isA<Exception>()),
      );
    });
    
    // ❌ TEST 8: Erreur base de données throw exception
    test('erreur base de données throw exception', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      const rewardId = 'reward-cafe';
      const pointsRequired = 10;
      
      when(mockRepository.claimReward(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
        rewardId: anyNamed('rewardId'),
        pointsRequired: anyNamed('pointsRequired'),
      )).thenThrow(Exception('Database error'));
      
      // ACT & ASSERT
      expect(
        () => reclamerRecompenseUseCase.execute(
          clientId: clientId,
          magasinId: magasinId,
          rewardId: rewardId,
          pointsRequired: pointsRequired,
        ),
        throwsException,
      );
    });
  });
}
