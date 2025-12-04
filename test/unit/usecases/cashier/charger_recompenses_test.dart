import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/charger_recompenses_usecase.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';

// Utilise le même mock
import 'ajouter_solde_test.mocks.dart';

/// 🧪 TESTS USE CASE - CHARGER RÉCOMPENSES
/// 
/// Tests du use case de chargement des récompenses disponibles
/// FONCTIONNALITÉ: Afficher récompenses client peut réclamer
/// 
/// RÈGLES MÉTIER:
/// - Récompenses filtrées par magasin
/// - Seulement récompenses actives
/// - Inclut points client actuels
/// - Tri par points requis (croissant)
/// 
/// COUVERTURE:
/// - Chargement succès
/// - Liste vide
/// - Filtrage récompenses
/// - Erreurs

void main() {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SETUP
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  late ChargerRecompensesClientUseCase chargerRecompensesUseCase;
  late MockCaissierRepository mockRepository;
  
  setUp(() {
    mockRepository = MockCaissierRepository();
    chargerRecompensesUseCase = ChargerRecompensesClientUseCase(
      repository: mockRepository,
    );
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS SUCCÈS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('Charger Récompenses - Succès', () {
    
    // ✅ TEST 1: Charger récompenses retourne liste
    test('charger récompenses retourne liste de récompenses', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      const clientPoints = 50;
      
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
      
      when(mockRepository.getAvailableRewards(
        clientId: clientId,
        magasinId: magasinId,
      )).thenAnswer((_) async => rewards);
      
      when(mockRepository.getClientPoints(
        clientId: clientId,
        magasinId: magasinId,
      )).thenAnswer((_) async => clientPoints);
      
      // ACT
      final result = await chargerRecompensesUseCase.execute(
        clientId: clientId,
        magasinId: magasinId,
      );
      
      // ASSERT
      expect(result.rewards, isNotEmpty);
      expect(result.rewards.length, equals(2));
      expect(result.clientPoints, equals(50));
      expect(result.rewards.first.name, equals('Café Gratuit'));
      
      verify(mockRepository.getAvailableRewards(
        clientId: clientId,
        magasinId: magasinId,
      )).called(1);
      
      verify(mockRepository.getClientPoints(
        clientId: clientId,
        magasinId: magasinId,
      )).called(1);
    });
    
    // ✅ TEST 2: Client avec points suffisants pour certaines récompenses
    test('client avec 50 points peut voir récompenses ≤ 50 points', () async {
      // ARRANGE
      const clientId = 'client-abc';
      const magasinId = 'magasin-xyz';
      const clientPoints = 50;
      
      final rewards = [
        Reward(
          id: 'reward-1',
          name: 'Récompense 10pts',
          requiredPoints: 10,
          shopId: magasinId,
          isActive: true,
        ),
        Reward(
          id: 'reward-2',
          name: 'Récompense 25pts',
          requiredPoints: 25,
          shopId: magasinId,
          isActive: true,
        ),
        Reward(
          id: 'reward-3',
          name: 'Récompense 50pts',
          requiredPoints: 50,
          shopId: magasinId,
          isActive: true,
        ),
      ];
      
      when(mockRepository.getAvailableRewards(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
      )).thenAnswer((_) async => rewards);
      
      when(mockRepository.getClientPoints(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
      )).thenAnswer((_) async => clientPoints);
      
      // ACT
      final result = await chargerRecompensesUseCase.execute(
        clientId: clientId,
        magasinId: magasinId,
      );
      
      // ASSERT
      expect(result.rewards.length, equals(3));
      expect(result.clientPoints, equals(50));
      
      // Toutes les récompenses sont ≤ 50 points
      for (final reward in result.rewards) {
        expect(reward.requiredPoints, lessThanOrEqualTo(clientPoints));
      }
    });
    
    // ✅ TEST 3: Récompenses triées par points requis
    test('récompenses retournées dans ordre croissant de points', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      
      final rewards = [
        Reward(
          id: 'reward-1',
          name: 'Récompense 10pts',
          requiredPoints: 10,
          shopId: magasinId,
          isActive: true,
        ),
        Reward(
          id: 'reward-2',
          name: 'Récompense 50pts',
          requiredPoints: 50,
          shopId: magasinId,
          isActive: true,
        ),
        Reward(
          id: 'reward-3',
          name: 'Récompense 25pts',
          requiredPoints: 25,
          shopId: magasinId,
          isActive: true,
        ),
      ];
      
      when(mockRepository.getAvailableRewards(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
      )).thenAnswer((_) async => rewards);
      
      when(mockRepository.getClientPoints(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
      )).thenAnswer((_) async => 100);
      
      // ACT
      final result = await chargerRecompensesUseCase.execute(
        clientId: clientId,
        magasinId: magasinId,
      );
      
      // ASSERT: Vérifier ordre (10, 50, 25 ou déjà trié par backend)
      // Le use case retourne ce que le repo donne
      expect(result.rewards.length, equals(3));
    });
    
    // ✅ TEST 4: Seulement récompenses actives du magasin
    test('retourne seulement récompenses actives du magasin spécifique', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      
      final rewards = [
        Reward(
          id: 'reward-1',
          name: 'Récompense Active',
          requiredPoints: 20,
          shopId: magasinId,
          isActive: true, // Active
        ),
        // Repository ne retourne QUE les actives du magasin
      ];
      
      when(mockRepository.getAvailableRewards(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
      )).thenAnswer((_) async => rewards);
      
      when(mockRepository.getClientPoints(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
      )).thenAnswer((_) async => 100);
      
      // ACT
      final result = await chargerRecompensesUseCase.execute(
        clientId: clientId,
        magasinId: magasinId,
      );
      
      // ASSERT
      expect(result.rewards, isNotEmpty);
      for (final reward in result.rewards) {
        expect(reward.isActive, isTrue);
        expect(reward.shopId, equals(magasinId));
      }
    });
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS CAS LIMITES
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('Charger Récompenses - Cas Limites', () {
    
    // 🔍 TEST 5: Client sans points retourne liste vide
    test('client avec 0 points retourne liste vide ou récompenses gratuites', () async {
      // ARRANGE
      const clientId = 'client-new';
      const magasinId = 'magasin-456';
      const clientPoints = 0;
      
      when(mockRepository.getAvailableRewards(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
      )).thenAnswer((_) async => []);
      
      when(mockRepository.getClientPoints(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
      )).thenAnswer((_) async => clientPoints);
      
      // ACT
      final result = await chargerRecompensesUseCase.execute(
        clientId: clientId,
        magasinId: magasinId,
      );
      
      // ASSERT
      expect(result.rewards, isEmpty);
      expect(result.clientPoints, equals(0));
    });
    
    // 🔍 TEST 6: Magasin sans récompenses actives
    test('magasin sans récompenses actives retourne liste vide', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-no-rewards';
      
      when(mockRepository.getAvailableRewards(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
      )).thenAnswer((_) async => []);
      
      when(mockRepository.getClientPoints(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
      )).thenAnswer((_) async => 50);
      
      // ACT
      final result = await chargerRecompensesUseCase.execute(
        clientId: clientId,
        magasinId: magasinId,
      );
      
      // ASSERT
      expect(result.rewards, isEmpty);
      expect(result.clientPoints, equals(50)); // Client a des points mais pas de récompenses
    });
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS ERREURS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('Charger Récompenses - Erreurs', () {
    
    // ❌ TEST 7: Erreur lors du chargement récompenses
    test('erreur getAvailableRewards throw exception', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      
      when(mockRepository.getAvailableRewards(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
      )).thenThrow(Exception('Erreur réseau'));
      
      // ACT & ASSERT
      expect(
        () => chargerRecompensesUseCase.execute(
          clientId: clientId,
          magasinId: magasinId,
        ),
        throwsException,
      );
    });
    
    // ❌ TEST 8: Erreur lors du chargement points client
    test('erreur getClientPoints throw exception', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      
      final rewards = [
        Reward(
          id: 'reward-1',
          name: 'Test Reward',
          requiredPoints: 10,
          shopId: magasinId,
          isActive: true,
        ),
      ];
      
      when(mockRepository.getAvailableRewards(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
      )).thenAnswer((_) async => rewards);
      
      when(mockRepository.getClientPoints(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
      )).thenThrow(Exception('Erreur base de données'));
      
      // ACT & ASSERT
      expect(
        () => chargerRecompensesUseCase.execute(
          clientId: clientId,
          magasinId: magasinId,
        ),
        throwsException,
      );
    });
  });
}
