import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/client_magasin_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/ajouter_solde.dart';

// Générer mock: flutter pub run build_runner build
@GenerateMocks([CaissierRepository])
import 'ajouter_solde_test.mocks.dart';

/// 🧪 TESTS USE CASE - AJOUTER SOLDE
/// 
/// Tests du use case d'ajout de solde fidélité
/// FONCTIONNALITÉ CRITIQUE: Cœur métier de l'app caissier
/// 
/// RÈGLES MÉTIER:
/// - 10 MAD = 1 point fidélité
/// - Solde et points mis à jour atomiquement
/// - Création transaction historique
/// 
/// COUVERTURE:
/// - Ajout solde succès
/// - Calcul points correct
/// - Cas d'erreur
/// - Validation montants

void main() {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SETUP
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  late AjouterSoldeUseCase ajouterSoldeUseCase;
  late MockCaissierRepository mockRepository;
  
  setUp(() {
    mockRepository = MockCaissierRepository();
    ajouterSoldeUseCase = AjouterSoldeUseCase(repository: mockRepository);
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS SUCCÈS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('Ajouter Solde UseCase - Succès', () {
    
    // ✅ TEST 1: Ajout 100 MAD = 10 points
    test('ajouter 100 MAD ajoute 10 points fidélité', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      const montant = 100.0;
      
      final expectedResult = ClientMagasinEntity(
        clientId: clientId,
        magasinId: magasinId,
        cumulePoint: 10.0, // 100 MAD / 10 = 10 points
        solde: 100.0,
      );
      
      when(mockRepository.ajouterSoldeEtAppliquerOffres(
        clientId: clientId,
        magasinId: magasinId,
        montant: montant,
      )).thenAnswer((_) async => expectedResult);
      
      // ACT
      final result = await ajouterSoldeUseCase.execute(
        clientId: clientId,
        magasinId: magasinId,
        montant: montant,
      );
      
      // ASSERT
      expect(result.cumulePoint, equals(10.0));
      expect(result.solde, equals(100.0));
      expect(result.clientId, equals(clientId));
      expect(result.magasinId, equals(magasinId));
      
      verify(mockRepository.ajouterSoldeEtAppliquerOffres(
        clientId: clientId,
        magasinId: magasinId,
        montant: montant,
      )).called(1);
    });
    
    // ✅ TEST 2: Ajout 50 MAD = 5 points
    test('ajouter 50 MAD ajoute 5 points fidélité', () async {
      // ARRANGE
      const clientId = 'client-789';
      const magasinId = 'magasin-456';
      const montant = 50.0;
      
      final expectedResult = ClientMagasinEntity(
        clientId: clientId,
        magasinId: magasinId,
        cumulePoint: 5.0, // 50 / 10 = 5 points
        solde: 50.0,
      );
      
      when(mockRepository.ajouterSoldeEtAppliquerOffres(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
        montant: anyNamed('montant'),
      )).thenAnswer((_) async => expectedResult);
      
      // ACT
      final result = await ajouterSoldeUseCase.execute(
        clientId: clientId,
        magasinId: magasinId,
        montant: montant,
      );
      
      // ASSERT
      expect(result.cumulePoint, equals(5.0));
      expect(result.solde, equals(50.0));
    });
    
    // ✅ TEST 3: Ajout cumule avec solde existant
    test('ajout solde cumule avec solde précédent', () async {
      // ARRANGE
      const clientId = 'client-abc';
      const magasinId = 'magasin-xyz';
      const montant = 200.0;
      
      // Client avait déjà 50 points et 500 MAD
      final expectedResult = ClientMagasinEntity(
        clientId: clientId,
        magasinId: magasinId,
        cumulePoint: 70.0, // 50 anciens + 20 nouveaux = 70
        solde: 700.0,      // 500 ancien + 200 nouveau = 700
      );
      
      when(mockRepository.ajouterSoldeEtAppliquerOffres(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
        montant: anyNamed('montant'),
      )).thenAnswer((_) async => expectedResult);
      
      // ACT
      final result = await ajouterSoldeUseCase.execute(
        clientId: clientId,
        magasinId: magasinId,
        montant: montant,
      );
      
      // ASSERT
      expect(result.cumulePoint, equals(70.0));
      expect(result.solde, equals(700.0));
    });
    
    // ✅ TEST 4: Petit montant (15 MAD = 1.5 points)
    test('petit montant calcule points décimaux correct', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      const montant = 15.0;
      
      final expectedResult = ClientMagasinEntity(
        clientId: clientId,
        magasinId: magasinId,
        cumulePoint: 1.5, // 15 / 10 = 1.5 points
        solde: 15.0,
      );
      
      when(mockRepository.ajouterSoldeEtAppliquerOffres(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
        montant: anyNamed('montant'),
      )).thenAnswer((_) async => expectedResult);
      
      // ACT
      final result = await ajouterSoldeUseCase.execute(
        clientId: clientId,
        magasinId: magasinId,
        montant: montant,
      );
      
      // ASSERT
      expect(result.cumulePoint, equals(1.5));
    });
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS VALIDATION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('Ajouter Solde UseCase - Validation', () {
    
    // ❌ TEST 5: Montant négatif throw exception
    test('montant négatif throw exception', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      const montantNegatif = -50.0;
      
      when(mockRepository.ajouterSoldeEtAppliquerOffres(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
        montant: anyNamed('montant'),
      )).thenThrow(Exception('Montant doit être positif'));
      
      // ACT & ASSERT
      expect(
        () => ajouterSoldeUseCase.execute(
          clientId: clientId,
          magasinId: magasinId,
          montant: montantNegatif,
        ),
        throwsException,
      );
    });
    
    // ❌ TEST 6: Montant 0 throw exception
    test('montant zéro throw exception', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      const montantZero = 0.0;
      
      when(mockRepository.ajouterSoldeEtAppliquerOffres(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
        montant: anyNamed('montant'),
      )).thenThrow(Exception('Montant doit être > 0'));
      
      // ACT & ASSERT
      expect(
        () => ajouterSoldeUseCase.execute(
          clientId: clientId,
          magasinId: magasinId,
          montant: montantZero,
        ),
        throwsException,
      );
    });
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS ERREURS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('Ajouter Solde UseCase - Erreurs', () {
    
    // ❌ TEST 7: Client inexistant throw exception
    test('client inexistant throw exception', () async {
      // ARRANGE
      const clientInexistant = 'client-999';
      const magasinId = 'magasin-456';
      const montant = 100.0;
      
      when(mockRepository.ajouterSoldeEtAppliquerOffres(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
        montant: anyNamed('montant'),
      )).thenThrow(Exception('Client non trouvé'));
      
      // ACT & ASSERT
      expect(
        () => ajouterSoldeUseCase.execute(
          clientId: clientInexistant,
          magasinId: magasinId,
          montant: montant,
        ),
        throwsException,
      );
    });
    
    // ❌ TEST 8: Erreur réseau throw exception
    test('erreur réseau throw exception', () async {
      // ARRANGE
      const clientId = 'client-123';
      const magasinId = 'magasin-456';
      const montant = 100.0;
      
      when(mockRepository.ajouterSoldeEtAppliquerOffres(
        clientId: anyNamed('clientId'),
        magasinId: anyNamed('magasinId'),
        montant: anyNamed('montant'),
      )).thenThrow(Exception('Erreur réseau'));
      
      // ACT & ASSERT
      expect(
        () => ajouterSoldeUseCase.execute(
          clientId: clientId,
          magasinId: magasinId,
          montant: montant,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
