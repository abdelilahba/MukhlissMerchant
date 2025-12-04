import 'package:flutter_test/flutter_test.dart';

/// 🧪 TESTS UTILS - VALIDATION & FORMATAGE
///
/// Tests des fonctions utilitaires de validation et formatage

void main() {
  group('Validation - Email', () {
    // ✅ TEST 1: Email valide
    test('email valide retourne true', () {
      expect(_isValidEmail('test@example.com'), isTrue);
      expect(_isValidEmail('user.name@domain.co.ma'), isTrue);
      expect(_isValidEmail('contact+tag@company.com'), isTrue);
    });

    // ✅ TEST 2: Email invalide
    test('email invalide retourne false', () {
      expect(_isValidEmail('invalidemail'), isFalse);
      expect(_isValidEmail('missing@domain'), isFalse);
      expect(_isValidEmail('@nodomain.com'), isFalse);
      expect(_isValidEmail('no-at-sign.com'), isFalse);
    });

    // ✅ TEST 3: Email vide
    test('email vide retourne false', () {
      expect(_isValidEmail(''), isFalse);
      expect(_isValidEmail('   '), isFalse);
    });
  });

  group('Validation - Téléphone marocain', () {
    // ✅ TEST 4: Téléphone valide
    test('téléphone marocain valide', () {
      expect(_isValidPhoneMA('0612345678'), isTrue);
      expect(_isValidPhoneMA('0712345678'), isTrue);
      expect(_isValidPhoneMA('0698765432'), isTrue);
    });

    // ✅ TEST 5: Téléphone invalide
    test('téléphone invalide', () {
      expect(
        _isValidPhoneMA('1234567890'),
        isFalse,
      ); // Ne commence pas par 06/07
      expect(_isValidPhoneMA('06123'), isFalse); // Trop court
      expect(_isValidPhoneMA('061234567890'), isFalse); // Trop long
      expect(_isValidPhoneMA('0512345678'), isFalse); // Commence par 05
    });

    // ✅ TEST 6: Téléphone avec espaces
    test('téléphone avec espaces non accepté', () {
      expect(_isValidPhoneMA('06 12 34 56 78'), isFalse);
      expect(_isValidPhoneMA('06-12-34-56-78'), isFalse);
    });
  });

  group('Formatage - Montant', () {
    // ✅ TEST 7: Format montant simple
    test('formate montant avec séparateurs', () {
      expect(_formatAmount(1000), equals('1,000'));
      expect(_formatAmount(1000000), equals('1,000,000'));
      expect(_formatAmount(100), equals('100'));
    });

    // ✅ TEST 8: Format montant avec décimales
    test('formate montant avec décimales', () {
      expect(_formatAmountWithDecimals(99.99), equals('99.99'));
      expect(_formatAmountWithDecimals(1000.50), equals('1,000.50'));
    });

    // ✅ TEST 9: Montant négatif
    test('montant négatif avec signe', () {
      expect(_formatAmount(-500), equals('-500'));
    });
  });

  group('Formatage - Date', () {
    // ✅ TEST 10: Format date français
    test('formate date en français', () {
      final date = DateTime(2025, 12, 3);
      expect(_formatDateFR(date), equals('03/12/2025'));
    });

    // ✅ TEST 11: Format date relative
    test('date relative (il y a X jours)', () {
      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));
      final weekAgo = today.subtract(Duration(days: 7));

      expect(_formatRelativeDate(today), contains('aujourd\'hui'));
      expect(_formatRelativeDate(yesterday), contains('hier'));
      expect(_formatRelativeDate(weekAgo), contains('7 jours'));
    });
  });

  group('Validation - Montant', () {
    // ✅ TEST 12: Montant positif
    test('montant doit être positif', () {
      expect(_isValidAmount(100), isTrue);
      expect(_isValidAmount(0.01), isTrue);
      expect(_isValidAmount(0), isFalse);
      expect(_isValidAmount(-10), isFalse);
    });

    // ✅ TEST 13: Montant maximum
    test('montant ne dépasse pas maximum', () {
      expect(_isValidAmount(1000, max: 10000), isTrue);
      expect(_isValidAmount(15000, max: 10000), isFalse);
    });
  });

  group('Formatage - Texte', () {
    // ✅ TEST 14: Capitalisation
    test('capitalise première lettre', () {
      expect(_capitalize('hello'), equals('Hello'));
      expect(_capitalize('WORLD'), equals('WORLD'));
      expect(_capitalize(''), equals(''));
    });

    // ✅ TEST 15: Trim et clean
    test('nettoie espaces multiples', () {
      expect(_cleanText('  hello   world  '), equals('hello world'));
      expect(_cleanText('test'), equals('test'));
    });
  });
}

// ========== FONCTIONS UTILITAIRES POUR TESTS ==========
// (Dans une vraie app, ces fonctions seraient dans lib/core/utils/)

bool _isValidEmail(String email) {
  if (email.trim().isEmpty) return false;
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  return emailRegex.hasMatch(email);
}

bool _isValidPhoneMA(String phone) {
  if (phone.length != 10) return false;
  if (!phone.startsWith('06') && !phone.startsWith('07')) return false;
  return RegExp(r'^0[67]\d{8}$').hasMatch(phone);
}

String _formatAmount(int amount) {
  final str = amount.abs().toString();
  final buffer = StringBuffer();
  for (int i = str.length - 1, count = 0; i >= 0; i--, count++) {
    if (count > 0 && count % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  final result = buffer.toString().split('').reversed.join();
  return amount < 0 ? '-$result' : result;
}

String _formatAmountWithDecimals(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  final intPart = _formatAmount(int.parse(parts[0]));
  return '$intPart.${parts[1]}';
}

String _formatDateFR(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  return '$day/$month/$year';
}

String _formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inDays == 0) return 'aujourd\'hui';
  if (diff.inDays == 1) return 'hier';
  return 'il y a ${diff.inDays} jours';
}

bool _isValidAmount(double amount, {double? max}) {
  if (amount <= 0) return false;
  if (max != null && amount > max) return false;
  return true;
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String _cleanText(String text) {
  return text.trim().replaceAll(RegExp(r'\s+'), ' ');
}
