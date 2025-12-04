# 🧪 GUIDE DES TESTS - MUKHLISS MERCHANT

**Version:** 1.0.0  
**Tests:** 67 (100% réussite)

---

## 🚀 **QUICK START**

### **Exécuter tous les tests:**

```bash
flutter test
```

### **Exécuter un fichier spécifique:**

```bash
flutter test test/unit/services/cache_service_test.dart
```

### **Avec détails:**

```bash
flutter test --reporter expanded
```

### **Avec couverture:**

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📁 **STRUCTURE**

```
test/
├── unit/
│   ├── services/           # Services (Cache, etc.)
│   ├── entities/           # Modèles de données
│   ├── utils/              # Utilitaires (validation)
│   └── business/           # Logique métier
├── widget/                 # Tests UI (à venir)
├── integration/            # Tests integration (à venir)
├── RAPPORT_FINAL_TESTS.md  # Rapport complet
└── README.md               # Ce fichier
```

---

## ✅ **TESTS DISPONIBLES**

### **Services (19 tests)**

- ✅ `cache_service_test.dart` - Cache LRU, TTL, stats

### **Entités (10 tests)**

- ✅ `client_entity_test.dart` - Serialization, validation

### **Utils (15 tests)**

- ✅ `validation_utils_test.dart` - Email, téléphone, format

### **Business (23 tests)**

- ✅ `loyalty_business_logic_test.dart` - Points, récompenses, QR

**TOTAL: 67 tests**

---

## 🎯 **AJOUTER UN NOUVEAU TEST**

### **1. Créer le fichier:**

```bash
touch test/unit/services/mon_service_test.dart
```

### **2. Template de base:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mukhlissmagasin/..../mon_service.dart';

void main() {
  group('MonService - Description', () {

    test('description du test', () {
      // ARRANGE: Préparer
      final service = MonService();

      // ACT: Exécuter
      final resultat = service.maMethode();

      // ASSERT: Vérifier
      expect(resultat, equals(valeurAttendue));
    });

  });
}
```

### **3. Exécuter:**

```bash
flutter test test/unit/services/mon_service_test.dart
```

---

## 📊 **COMMANDES UTILES**

```bash
# Tests avec watch (re-run automatique)
flutter test --watch

# Tests d'un dossier
flutter test test/unit/services/

# Tests avec nom spécifique
flutter test --plain-name "set puis get"

# Coverage HTML
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html

# Verbose
flutter test -r expanded
```

---

## 🐛 **DEBUGGING**

### **Test échoue:**

```dart
// Ajouter prints pour debug
test('mon test', () {
  final result = service.method();
  print('Result: $result');  // Debug
  expect(result, equals(expected));
});
```

### **Erreur compilation:**

```bash
# Clean et rebuild
flutter clean
flutter pub get
flutter test
```

### **Test lent:**

```dart
// Ajouter timeout
test('test lent', () async {
  // ...
}, timeout: Timeout(Duration(seconds: 30)));
```

---

## ✅ **BEST PRACTICES**

### **DO:**

```dart
✅ Nommer tests en français descriptif
✅ Utiliser pattern AAA (Arrange, Act, Assert)
✅ Un test = un concept
✅ Tests indépendants (pas de dépendances entre tests)
✅ Mock external dependencies
✅ Tester happy path ET edge cases
```

### **DON'T:**

```dart
❌ Tests qui dépendent d'autres tests
❌ Tests avec side effects
❌ Tests qui appellent vraies APIs
❌ Tests trop longs/complexes
❌ Oublier les cas limites
❌ Hard-coder valeurs magiques
```

---

## 📈 **OBJECTIFS**

```
✅ Actuel:  67 tests (25% coverage)
⏳ 1 sem:  100 tests (40% coverage)
⏳ 2 sem:  150 tests (60% coverage)
🎯 1 mois: 200 tests (80% coverage)
```

---

## 🆘 **AIDE & RESSOURCES**

### **Documentation:**

- [Flutter Testing](https://docs.flutter.dev/testing)
- [Mockito](https://pub.dev/packages/mockito)
- [Testing Best Practices](https://flutter.dev/docs/cookbook/testing)

### **En cas de problème:**

1. Vérifier logs avec `-r expanded`
2. Regarder les tests similaires
3. Lire la documentation du package

### **Contact:**

→ Documentation: `test/RAPPORT_FINAL_TESTS.md`

---

## 🎉 **CONTRIBUTION**

Pour ajouter des tests:

1. Créer fichier dans bon dossier
2. Suivre pattern existant
3. Tester localement
4. Mettre à jour ce README si besoin

---

**Dernière mise à jour:** 3 Décembre 2025  
**Tests:** 67 / Réussite: 100% ✅
