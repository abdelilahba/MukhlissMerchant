import 'package:flutter_test/flutter_test.dart';

/// 🧪 TESTS BUSINESS LOGIC - CALCULS & RÈGLES MÉTIER
///
/// Tests des calculs de points, réductions, etc.

void main() {
  group('Calcul Points Fidélité', () {
    // ✅ TEST 1: Calcul points basique
    test('10 MAD = 1 point', () {
      expect(_calculatePoints(100), equals(10));
      expect(_calculatePoints(250), equals(25));
      expect(_calculatePoints(1000), equals(100));
    });

    // ✅ TEST 2: Montant inférieur au seuil
    test('montant < 10 MAD donne 0 points', () {
      expect(_calculatePoints(5), equals(0));
      expect(_calculatePoints(9.99), equals(0));
    });

    // ✅ TEST 3: Arrondissement vers le bas
    test('arrondit vers le bas', () {
      expect(_calculatePoints(95), equals(9)); // Pas 10
      expect(_calculatePoints(199), equals(19)); // Pas 20
    });

    // ✅ TEST 4: Bonus points (promotions)
    test('bonus 50% double les points', () {
      expect(_calculatePointsWithBonus(100, 50), equals(15)); // 10 + 50%
      expect(_calculatePointsWithBonus(200, 50), equals(30)); // 20 + 50%
    });

    // ✅ TEST 5: Bonus 100% double
    test('bonus 100% double les points', () {
      expect(_calculatePointsWithBonus(100, 100), equals(20)); // 10 * 2
    });
  });

  group('Vérification Récompense', () {
    // ✅ TEST 6: Points suffisants
    test('peut réclamer si points suffisants', () {
      expect(_canClaimReward(pointsClient: 100, pointsReward: 50), isTrue);
      expect(_canClaimReward(pointsClient: 50, pointsReward: 50), isTrue);
    });

    // ✅ TEST 7: Points insuffisants
    test('ne peut pas réclamer si points insuffisants', () {
      expect(_canClaimReward(pointsClient: 30, pointsReward: 50), isFalse);
      expect(_canClaimReward(pointsClient: 0, pointsReward: 10), isFalse);
    });

    // ✅ TEST 8: Stock disponible
    test('ne peut pas réclamer si stock 0', () {
      expect(
        _canClaimReward(pointsClient: 100, pointsReward: 50, stock: 0),
        isFalse,
      );
    });

    // ✅ TEST 9: Stock disponible
    test('peut réclamer si stock > 0', () {
      expect(
        _canClaimReward(pointsClient: 100, pointsReward: 50, stock: 5),
        isTrue,
      );
    });
  });

  group('Calcul Réduction', () {
    // ✅ TEST 10: Réduction pourcentage
    test('applique réduction en %', () {
      expect(_applyDiscount(100, 10), equals(90.0));
      expect(_applyDiscount(200, 25), equals(150.0));
      expect(_applyDiscount(1000, 50), equals(500.0));
    });

    // ✅ TEST 11: Réduction 0%
    test('0% de réduction = prix original', () {
      expect(_applyDiscount(100, 0), equals(100.0));
    });

    // ✅ TEST 12: Réduction 100%
    test('100% de réduction = gratuit', () {
      expect(_applyDiscount(100, 100), equals(0.0));
    });

    // ✅ TEST 13: Prix minimum
    test('prix ne peut pas être négatif', () {
      expect(_applyDiscount(100, 150), equals(0.0)); // Max 100%
    });
  });

  group('Niveau Fidélité', () {
    // ✅ TEST 14: Bronze (0-99 points)
    test('0-99 points = Bronze', () {
      expect(_calculateLevelName(0), equals('Bronze'));
      expect(_calculateLevelName(50), equals('Bronze'));
      expect(_calculateLevelName(99), equals('Bronze'));
    });

    // ✅ TEST 15: Silver (100-499)
    test('100-499 points = Silver', () {
      expect(_calculateLevelName(100), equals('Silver'));
      expect(_calculateLevelName(250), equals('Silver'));
      expect(_calculateLevelName(499), equals('Silver'));
    });

    // ✅ TEST 16: Gold (500-999)
    test('500-999 points = Gold', () {
      expect(_calculateLevelName(500), equals('Gold'));
      expect(_calculateLevelName(750), equals('Gold'));
      expect(_calculateLevelName(999), equals('Gold'));
    });

    // ✅ TEST 17: Platinum (1000+)
    test('1000+ points = Platinum', () {
      expect(_calculateLevelName(1000), equals('Platinum'));
      expect(_calculateLevelName(5000), equals('Platinum'));
    });
  });

  group('Validation QR Code', () {
    // ✅ TEST 18: QR code valide (6 chiffres)
    test('QR code 6 chiffres est valide', () {
      expect(_isValidQRCode('123456'), isTrue);
      expect(_isValidQRCode('000000'), isTrue);
      expect(_isValidQRCode('999999'), isTrue);
    });

    // ✅ TEST 19: QR code invalide (longueur)
    test('QR code longueur incorrecte est invalide', () {
      expect(_isValidQRCode('12345'), isFalse); // Trop court
      expect(_isValidQRCode('1234567'), isFalse); // Trop long
      expect(_isValidQRCode(''), isFalse); // Vide
    });

    // ✅ TEST 20: QR code invalide (caractères)
    test('QR code avec lettres est invalide', () {
      expect(_isValidQRCode('12345A'), isFalse);
      expect(_isValidQRCode('ABCDEF'), isFalse);
      expect(_isValidQRCode('12-456'), isFalse);
    });
  });

  group('Calculs avancés', () {
    // ✅ TEST 21: Points après dépense
    test('calcule points restants après achat récompense', () {
      const pointsInitial = 100;
      const coutRecompense = 30;

      final reste = pointsInitial - coutRecompense;
      expect(reste, equals(70));
    });

    // ✅ TEST 22: Moyenne dépenses
    test('calcule moyenne dépenses client', () {
      final achats = [100.0, 200.0, 150.0];
      final moyenne = achats.reduce((a, b) => a + b) / achats.length;

      expect(moyenne, equals(150.0));
    });

    // ✅ TEST 23: Total points multiples transactions
    test('cumule points sur plusieurs transactions', () {
      final transactions = [100, 250, 500]; // MAD
      final totalPoints = transactions
          .map((montant) => _calculatePoints(montant.toDouble()))
          .reduce((a, b) => a + b);

      expect(totalPoints, equals(85)); // 10 + 25 + 50
    });
  });
}

// ========== FONCTIONS MÉTIER ==========

int _calculatePoints(double amount) {
  if (amount < 10) return 0;
  return (amount / 10).floor();
}

int _calculatePointsWithBonus(double amount, int bonusPercent) {
  final basePoints = _calculatePoints(amount);
  final bonus = (basePoints * bonusPercent / 100).round();
  return basePoints + bonus;
}

bool _canClaimReward({
  required int pointsClient,
  required int pointsReward,
  int stock = 999,
}) {
  if (stock <= 0) return false;
  return pointsClient >= pointsReward;
}

double _applyDiscount(double price, int discountPercent) {
  if (discountPercent >= 100) return 0.0;
  if (discountPercent <= 0) return price;

  final discount = price * discountPercent / 100;
  return price - discount;
}

String _calculateLevelName(int points) {
  if (points >= 1000) return 'Platinum';
  if (points >= 500) return 'Gold';
  if (points >= 100) return 'Silver';
  return 'Bronze';
}

bool _isValidQRCode(String code) {
  if (code.length != 6) return false;
  return RegExp(r'^\d{6}$').hasMatch(code);
}
