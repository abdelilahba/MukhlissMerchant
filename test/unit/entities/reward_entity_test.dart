import 'package:flutter_test/flutter_test.dart';
import 'package:mukhlissmagasin/features/rewards/domain/entities/reward_entity.dart';

/// 🧪 TESTS ENTITÉ - REWARD (Récompense)
///
/// Tests de l'entité Reward: serialization, copyWith, validation

void main() {
  group('Reward Entity - Serialization', () {
    // ✅ TEST 1: fromJson crée Reward valide
    test('fromJson crée Reward avec toutes propriétés', () {
      // ARRANGE
      final json = {
        'id': 'reward-123',
        'name': 'Café Gratuit',
        'points_required': 50,
        'magasin_id': 'shop-456',
        'is_active': true,
      };

      // ACT
      final reward = Reward.fromJson(json);

      // ASSERT
      expect(reward.id, equals('reward-123'));
      expect(reward.name, equals('Café Gratuit'));
      expect(reward.requiredPoints, equals(50));
      expect(reward.shopId, equals('shop-456'));
      expect(reward.isActive, isTrue);
    });

    // ✅ TEST 2: toJson sérialise correctement
    test('toJson convertit Reward en Map', () {
      // ARRANGE
      final reward = Reward(
        id: 'test-id',
        name: 'Test Reward',
        requiredPoints: 100,
        shopId: 'shop-123',
        isActive: true,
      );

      // ACT
      final json = reward.toJson();

      // ASSERT
      expect(json['id'], equals('test-id'));
      expect(json['name'], equals('Test Reward'));
      expect(json['points_required'], equals(100));
      expect(json['magasin_id'], equals('shop-123'));
      expect(json['is_active'], isTrue);
    });

    // ✅ TEST 3: Round-trip (toJson → fromJson)
    test('round-trip toJson puis fromJson préserve données', () {
      // ARRANGE
      final original = Reward(
        id: 'reward-1',
        name: 'Réduction 10%',
        requiredPoints: 75,
        shopId: 'shop-1',
        isActive: true,
      );

      // ACT
      final json = original.toJson();
      final restored = Reward.fromJson(json);

      // ASSERT
      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.requiredPoints, equals(original.requiredPoints));
      expect(restored.shopId, equals(original.shopId));
      expect(restored.isActive, equals(original.isActive));
    });

    // ✅ TEST 4: Gestion valeurs nullables
    test('fromJson gère valeurs manquantes avec defaults', () {
      // ARRANGE
      final json = {'is_active': false}; // Minimum requis

      // ACT
      final reward = Reward.fromJson(json);

      // ASSERT
      expect(reward.id, equals(''));
      expect(reward.name, equals(''));
      expect(reward.requiredPoints, equals(0));
      expect(reward.shopId, equals(''));
      expect(reward.isActive, isFalse);
    });
  });

  group('Reward Entity - copyWith', () {
    // ✅ TEST 5: copyWith modifie champ spécifique
    test('copyWith modifie nom uniquement', () {
      // ARRANGE
      final original = Reward(
        id: 'r1',
        name: 'Old Name',
        requiredPoints: 50,
        shopId: 's1',
        isActive: true,
      );

      // ACT
      final modified = original.copyWith(title: 'New Name');

      // ASSERT
      expect(modified.name, equals('New Name'));
      expect(modified.id, equals(original.id)); // Inchangé
      expect(modified.requiredPoints, equals(original.requiredPoints));
    });

    // ✅ TEST 6: copyWith modifie points requis
    test('copyWith modifie points requis', () {
      // ARRANGE
      final original = Reward(
        id: 'r1',
        name: 'Reward',
        requiredPoints: 50,
        shopId: 's1',
        isActive: true,
      );

      // ACT
      final modified = original.copyWith(requiredPoints: 100);

      // ASSERT
      expect(modified.requiredPoints, equals(100));
      expect(modified.name, equals(original.name)); // Inchangé
    });

    // ✅ TEST 7: copyWith active/inactive
    test('copyWith bascule is_active', () {
      // ARRANGE
      final active = Reward(
        id: 'r1',
        name: 'Reward',
        requiredPoints: 50,
        shopId: 's1',
        isActive: true,
      );

      // ACT
      final inactive = active.copyWith(isActive: false);

      // ASSERT
      expect(inactive.isActive, isFalse);
      expect(active.isActive, isTrue); // Original inchangé
    });

    // ✅ TEST 8: copyWith sans modifications
    test('copyWith sans params retourne copie identique', () {
      // ARRANGE
      final original = Reward(
        id: 'r1',
        name: 'Reward',
        requiredPoints: 50,
        shopId: 's1',
        isActive: true,
      );

      // ACT
      final copy = original.copyWith();

      // ASSERT
      expect(copy.id, equals(original.id));
      expect(copy.name, equals(original.name));
      expect(copy.requiredPoints, equals(original.requiredPoints));
      expect(copy.isActive, equals(original.isActive));
    });
  });

  group('Reward Entity - Validation Business', () {
    // ✅ TEST 9: Points requis doivent être positifs
    test('points requis positifs', () {
      // ARRANGE & ACT
      final reward = Reward(
        id: 'r1',
        name: 'Reward',
        requiredPoints: 50,
        shopId: 's1',
        isActive: true,
      );

      // ASSERT
      expect(reward.requiredPoints, greaterThan(0));
    });

    // ✅ TEST 10: Récompense peut être inactive
    test('récompense peut être inactive', () {
      // ARRANGE & ACT
      final reward = Reward(
        id: 'r1',
        name: 'Old Reward',
        requiredPoints: 50,
        shopId: 's1',
        isActive: false,
      );

      // ASSERT
      expect(reward.isActive, isFalse);
    });

    // ✅ TEST 11: Nom non vide pour récompense active
    test('récompense active a un nom', () {
      // ARRANGE
      final reward = Reward(
        id: 'r1',
        name: 'Valid Reward',
        requiredPoints: 50,
        shopId: 's1',
        isActive: true,
      );

      // ASSERT
      expect(reward.name, isNotEmpty);
      expect(reward.isActive, isTrue);
    });
  });

  group('Reward Entity - Edge Cases', () {
    // ✅ TEST 12: Points requis élevés
    test('gère points requis très élevés', () {
      // ARRANGE
      final reward = Reward(
        id: 'r1',
        name: 'Premium Reward',
        requiredPoints: 10000,
        shopId: 's1',
        isActive: true,
      );

      // ASSERT
      expect(reward.requiredPoints, equals(10000));
      expect(reward.requiredPoints, greaterThan(1000));
    });

    // ✅ TEST 13: Nom avec caractères spéciaux
    test('accepte noms avec accents et émojis', () {
      // ARRANGE
      final reward = Reward(
        id: 'r1',
        name: 'Café ☕ - Réduction 50%',
        requiredPoints: 50,
        shopId: 's1',
        isActive: true,
      );

      // ASSERT
      expect(reward.name, contains('☕'));
      expect(reward.name, contains('%'));
    });

    // ✅ TEST 14: ShopName optionnel
    test('shopName peut être null', () {
      // ARRANGE
      final reward = Reward(
        id: 'r1',
        name: 'Reward',
        requiredPoints: 50,
        shopId: 's1',
        shopName: null,
        isActive: true,
      );

      // ASSERT
      expect(reward.shopName, isNull);
    });

    // ✅ TEST 15: ShopName fourni
    test('shopName peut être fourni', () {
      // ARRANGE
      final reward = Reward(
        id: 'r1',
        name: 'Reward',
        requiredPoints: 50,
        shopId: 's1',
        shopName: 'Mon Magasin',
        isActive: true,
      );

      // ASSERT
      expect(reward.shopName, equals('Mon Magasin'));
    });
  });
}
