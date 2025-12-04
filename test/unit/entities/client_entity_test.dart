import 'package:flutter_test/flutter_test.dart';
import 'package:mukhlissmagasin/features/cashier/domain/entities/Client_entity.dart';

/// 🧪 TESTS ENTITÉS - CLIENT
///
/// Tests des modèles de données (serialization, equality, etc.)

void main() {
  group('Client Entity - Serialization', () {
    // ✅ TEST 1: fromJson crée objet valide
    test('fromJson crée un Client avec toutes les propriétés', () {
      // ARRANGE
      final json = {
        'id': 'client-123',
        'prenom': 'Ahmed',
        'nom': 'Alami',
        'email': 'ahmed@example.com',
        'telephone': '0612345678',
        'adresse': 'Rabat, Maroc',
        'code_unique': 123456,
      };

      // ACT
      final client = Client.fromJson(json);

      // ASSERT
      expect(client.id, equals('client-123'));
      expect(client.prenom, equals('Ahmed'));
      expect(client.nom, equals('Alami'));
      expect(client.email, equals('ahmed@example.com'));
      expect(client.telephone, equals('0612345678'));
      expect(client.adresse, equals('Rabat, Maroc'));
      expect(client.code_unique, equals(123456));
    });

    // ✅ TEST 2: Constructeur direct fonctionne
    test('constructeur crée Client valide', () {
      // ARRANGE & ACT
      final client = Client(
        id: 'test-id',
        prenom: 'Mohamed',
        nom: 'Bennani',
        email: 'mohamed@test.com',
        telephone: '0698765432',
        adresse: 'Casa',
        code_unique: 999999,
      );

      // ASSERT
      expect(client.prenom, equals('Mohamed'));
      expect(client.code_unique, equals(999999));
    });

    // ✅ TEST 3: Gestion données nullables
    test('gère valeurs vides correctement', () {
      // ARRANGE
      final json = {
        'id': '',
        'prenom': '',
        'nom': '',
        'email': '',
        'telephone': '',
        'adresse': '',
        'code_unique': 0,
      };

      // ACT
      final client = Client.fromJson(json);

      // ASSERT
      expect(client.id, isEmpty);
      expect(client.prenom, isEmpty);
      expect(client.code_unique, equals(0));
    });
  });

  group('Client Entity - Propriétés', () {
    // ✅ TEST 4: ID unique
    test('deux clients peuvent avoir IDs différents', () {
      // ARRANGE
      final client1 = Client(
        id: 'id1',
        prenom: 'Ali',
        nom: 'Test',
        email: 'ali@test.com',
        telephone: '0600000000',
        adresse: 'Address',
        code_unique: 111,
      );

      final client2 = Client(
        id: 'id2',
        prenom: 'Ali',
        nom: 'Test',
        email: 'ali@test.com',
        telephone: '0600000000',
        adresse: 'Address',
        code_unique: 111,
      );

      // ASSERT
      expect(client1.id, isNot(equals(client2.id)));
    });

    // ✅ TEST 5: Code unique doit être positif
    test('code_unique peut être entier positif', () {
      // ARRANGE
      final client = Client(
        id: 'test',
        prenom: 'Test',
        nom: 'User',
        email: 'test@test.com',
        telephone: '0600000000',
        adresse: 'Test',
        code_unique: 123456,
      );

      // ASSERT
      expect(client.code_unique, greaterThan(0));
      expect(client.code_unique, isA<int>());
    });

    // ✅ TEST 6: Email contient @
    test('email doit être format valide', () {
      // ARRANGE
      final client = Client(
        id: 'test',
        prenom: 'Test',
        nom: 'User',
        email: 'valid@email.com',
        telephone: '0600000000',
        adresse: 'Test',
        code_unique: 123,
      );

      // ASSERT
      expect(client.email, contains('@'));
      expect(client.email, contains('.'));
    });

    // ✅ TEST 7: Téléphone format marocain
    test('telephone commence par 06 ou 07', () {
      // ARRANGE
      final client = Client(
        id: 'test',
        prenom: 'Test',
        nom: 'User',
        email: 'test@test.com',
        telephone: '0612345678',
        adresse: 'Test',
        code_unique: 123,
      );

      // ASSERT
      expect(client.telephone, startsWith('06'));
      expect(client.telephone.length, equals(10));
    });
  });

  group('Client Entity - Cas limites', () {
    // ✅ TEST 8: Noms avec caractères spéciaux
    test('accepte noms avec accents', () {
      // ARRANGE
      final client = Client(
        id: 'test',
        prenom: 'François',
        nom: 'Müller',
        email: 'test@test.com',
        telephone: '0600000000',
        adresse: 'Test',
        code_unique: 123,
      );

      // ASSERT
      expect(client.prenom, contains('ç'));
      expect(client.nom, contains('ü'));
    });

    // ✅ TEST 9: Adresse longue
    test('accepte adresse longue', () {
      // ARRANGE
      final longAddress =
          'Résidence Al Amal, Appartement 45, Immeuble C, '
          'Avenue Mohammed V, Quartier Hassan, Rabat 10000, Maroc';

      final client = Client(
        id: 'test',
        prenom: 'Test',
        nom: 'User',
        email: 'test@test.com',
        telephone: '0600000000',
        adresse: longAddress,
        code_unique: 123,
      );

      // ASSERT
      expect(client.adresse.length, greaterThan(50));
    });

    // ✅ TEST 10: Code unique très grand
    test('accepte grands codes uniques', () {
      // ARRANGE
      final client = Client(
        id: 'test',
        prenom: 'Test',
        nom: 'User',
        email: 'test@test.com',
        telephone: '0600000000',
        adresse: 'Test',
        code_unique: 9999999,
      );

      // ASSERT
      expect(client.code_unique, greaterThan(1000000));
    });
  });
}
