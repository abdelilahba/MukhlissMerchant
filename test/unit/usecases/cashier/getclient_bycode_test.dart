import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/Client_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/getclient_byuniquecode.dart';

// Utilise le même mock que ajouter_solde_test
import 'ajouter_solde_test.mocks.dart';

/// 🧪 TESTS USE CASE - GET CLIENT BY CODE
/// 
/// Tests du use case de récupération client par code unique (QR)
/// FONCTIONNALITÉ: Scanner QR client pour identifier
/// 
/// IMPLÉMENTATION:
/// - Code unique = 6 chiffres
/// - Scan QR ou saisie manuelle
/// - Retourne objet Client complet
/// 
/// COUVERTURE:
/// - Client trouvé
/// - Client non trouvé
/// - Code invalide
/// - Erreurs réseau

void main() {
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SETUP
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  late GetclientByuniquecode getclientByuniquecode;
  late MockCaissierRepository mockRepository;
  
  setUp(() {
    mockRepository = MockCaissierRepository();
    getclientByuniquecode = GetclientByuniquecode(repository: mockRepository);
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS SUCCÈS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('Get Client By Code - Succès', () {
    
    // ✅ TEST 1: Récupérer client avec code valide
    test('get client avec code valide retourne Client', () async {
      // ARRANGE
      const uniqueCode = 123456;
      final expectedClient = Client(
        id: 'client-abc',
        nom: 'Ahmed',
        prenom: 'Alami',
        email: 'ahmed.alami@gmail.com',
        telephone: '+212612345678',
        adresse: 'Casablanca',
        code_unique: uniqueCode,
      );
      
      when(mockRepository.getClientByCodeUnique(uniqueCode: uniqueCode))
          .thenAnswer((_) async => expectedClient);
      
      // ACT
      final result = await getclientByuniquecode.execute(
        uniqueCode: uniqueCode,
      );
      
      // ASSERT
      expect(result, isNotNull);
      expect(result.id, equals('client-abc'));
      expect(result.nom, equals('Ahmed'));
      expect(result.code_unique, equals(uniqueCode));
      
      verify(mockRepository.getClientByCodeUnique(uniqueCode: uniqueCode))
          .called(1);
    });
    
    // ✅ TEST 2: Client avec toutes les informations
    test('get client retourne toutes les données client', () async {
      // ARRANGE
      const uniqueCode = 654321;
      final completeClient = Client(
        id: 'client-xyz',
        nom: 'Bennani',
        prenom: 'Fatima',
        email: 'fatima.bennani@gmail.com',
        telephone: '+212698765432',
        adresse: '45 Boulevard Mohammed V, Rabat',
        code_unique: uniqueCode,
      );
      
      when(mockRepository.getClientByCodeUnique(uniqueCode: anyNamed('uniqueCode')))
          .thenAnswer((_) async => completeClient);
      
      // ACT
      final result = await getclientByuniquecode.execute(
        uniqueCode: uniqueCode,
      );
      
      // ASSERT
      expect(result.nom, equals('Bennani'));
      expect(result.prenom, equals('Fatima'));
      expect(result.email, equals('fatima.bennani@gmail.com'));
      expect(result.telephone, equals('+212698765432'));
      expect(result.adresse, contains('Rabat'));
    });
    
    // ✅ TEST 3: Code 6 chiffres typique
    test('get client avec code 6 chiffres standard', () async {
      // ARRANGE
      const uniqueCode = 100000; // Premier code 6 chiffres
      final client = Client(
        id: 'client-001',
        nom: 'Test',
        prenom: 'User',
        email: 'test@mukhliss.com',
        telephone: '+212600000000',
        adresse: 'Test Address',
        code_unique: uniqueCode,
      );
      
      when(mockRepository.getClientByCodeUnique(uniqueCode: anyNamed('uniqueCode')))
          .thenAnswer((_) async => client);
      
      // ACT
      final result = await getclientByuniquecode.execute(
        uniqueCode: uniqueCode,
      );
      
      // ASSERT
      expect(result.code_unique, equals(100000));
      expect(result.code_unique.toString().length, equals(6));
    });
  });
  
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS ÉCHEC
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  
  group('Get Client By Code - Échec', () {
    
    // ❌ TEST 4: Code inexistant throw exception
    test('code inexistant throw exception', () async {
      // ARRANGE
      const codeInexistant = 999999;
      
      when(mockRepository.getClientByCodeUnique(uniqueCode: anyNamed('uniqueCode')))
          .thenThrow(Exception('Client non trouvé'));
      
      // ACT & ASSERT
      expect(
        () => getclientByuniquecode.execute(uniqueCode: codeInexistant),
        throwsException,
      );
    });
    
    // ❌ TEST 5: Erreur réseau throw exception
    test('erreur réseau throw exception', () async {
      // ARRANGE
      const uniqueCode = 123456;
      
      when(mockRepository.getClientByCodeUnique(uniqueCode: anyNamed('uniqueCode')))
          .thenThrow(Exception('Erreur réseau'));
      
      // ACT & ASSERT
      expect(
        () => getclientByuniquecode.execute(uniqueCode: uniqueCode),
        throwsA(isA<Exception>()),
      );
    });
    
    // ❌ TEST 6: Timeout exception
    test('timeout throw exception', () async {
      // ARRANGE
      const uniqueCode = 123456;
      
      when(mockRepository.getClientByCodeUnique(uniqueCode: anyNamed('uniqueCode')))
          .thenThrow(Exception('Timeout'));
      
      // ACT & ASSERT
      expect(
        () => getclientByuniquecode.execute(uniqueCode: uniqueCode),
        throwsException,
      );
    });
  });
}
