# 📘 GUIDE TEMPLATE TESTS - CRÉATION DES TESTS RESTANTS

**État actuel:** 127 tests (100% réussite) ✅  
**Objectif:** 187+ tests  
**Restant:** ~60 tests à créer

---

## ✅ **TESTS DÉJÀ CRÉÉS (127 tests)**

```
Auth UseCases (15 tests):
├─ login_usecase_test.dart             (8 tests) ✅
└─ signup_usecase_test.dart            (7 tests) ✅

Cashier UseCases (30 tests):
├─ ajouter_solde_test.dart             (8 tests) ✅
├─ getclient_bycode_test.dart          (6 tests) ✅
├─ charger_recompenses_test.dart       (8 tests) ✅
└─ reclamer_recompense_test.dart       (8 tests) ✅

Entités (25 tests):
├─ client_entity_test.dart             (10 tests) ✅
└─ reward_entity_test.dart             (15 tests) ✅

Services (19 tests):
└─ cache_service_test.dart             (19 tests) ✅

Utils (15 tests):
└─ validation_utils_test.dart          (15 tests) ✅

Business Logic (23 tests):
└─ loyalty_business_logic_test.dart    (23 tests) ✅

TOTAL: 127 tests ✅
```

---

## 🎯 **TESTS À CRÉER (~60 tests)**

### **1. CaissierCubit Tests (40 tests)**

```dart
// Créer: test/unit/cubits/caissier_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_state.dart';

// Dépendances à installer:
// pubspec.yaml dev_dependencies:
//   bloc_test: ^9.1.6

@GenerateMocks([
  AjouterSoldeUseCase,
  GetclientByuniquecode,
  ChargerRecompensesClientUseCase,
  ReclamerRecompenseUseCase,
  GetCurrentMagazinUseCase,
])
import 'caissier_cubit_test.mocks.dart';

void main() {
  late CaissierCubit caissierCubit;
  late MockAjouterSoldeUseCase mockAjouterSolde;
  late MockGetclientByuniquecode mockGetClient;
  // ... autres mocks

  setUp(() {
    mockAjouterSolde = MockAjouterSoldeUseCase();
    mockGetClient = MockGetclientByuniquecode();
    // ... initialiser autres mocks

    caissierCubit = CaissierCubit(
      ajouterSolde: mockAjouterSolde,
      getclientByuniquecode: mockGetClient,
      // ... autres use cases
    );
  });

  tearDown(() {
    caissierCubit.close();
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS INITIAL STATE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Initial State', () {
    test('initial state est CaissierInitial', () {
      expect(caissierCubit.state, isA<CaissierInitial>());
    });
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS SCAN QR
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Scan QR', () {
    blocTest<CaissierCubit, CaissierState>(
      'scan QR succès émet CaissierScanned',
      build: () {
        when(mockGetClient.execute(uniqueCode: any))
            .thenAnswer((_) async => Client(...));
        return caissierCubit;
      },
      act: (cubit) => cubit.scanQR('123456'),
      expect: () => [
        isA<CaissierLoading>(),
        isA<CaissierScanned>(),
      ],
    );

    blocTest<CaissierCubit, CaissierState>(
      'scan QR code invalide émet CaissierError',
      build: () {
        when(mockGetClient.execute(uniqueCode: any))
            .thenThrow(Exception('Client non trouvé'));
        return caissierCubit;
      },
      act: (cubit) => cubit.scanQR('999999'),
      expect: () => [
        isA<CaissierLoading>(),
        isA<CaissierError>(),
      ],
    );

    // ... 6 autres tests scan QR
  });

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // TESTS ADD BALANCE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  group('Add Balance', () {
    blocTest<CaissierCubit, CaissierState>(
      'add balance 100 MAD = 10 points',
      build: () {
        when(mockAjouterSolde.execute(
          clientId: any,
          magasinId: any,
          montant: 100.0,
        )).thenAnswer((_) async => ClientMagasinEntity(
          cumulePoint: 10.0,
          solde: 100.0,
          ...
        ));
        return caissierCubit;
      },
      act: (cubit) => cubit.addBalance(
        clientId: 'client-123',
        magasinId: 'magasin-456',
        montant: 100.0,
      ),
      expect: () => [
        isA<CaissierLoading>(),
        isA<CaissierBalanceAdded>()
            .having((s) => s.pointsGagnes, 'points', equals(10)),
      ],
    );

    // ... 8 autres tests add balance
  });

  // ... etc pour autres groupes
}

// TOTAL TESTS CUBIT: 40
```

### **2. Widget Tests (20 tests)**

**Installer dépendance:**

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
```

**Template Widget Test:**

```dart
// Créer: test/widget/scanner_section_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/caissier_home_screen.dart';

void main() {
  testWidgets('Scanner section affiche bouton scan', (tester) async {
    // ARRANGE
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScannerSection(
            onScan: (code) {},
            isScanning: false,
          ),
        ),
      ),
    );

    // ACT & ASSERT
    expect(find.text('Scanner QR'), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
  });

  testWidgets('Tap bouton scan appelle callback', (tester) async {
    // ARRANGE
    bool callbackCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScanButton(
            onPressed: () => callbackCalled = true,
          ),
        ),
      ),
    );

    // ACT
    await tester.tap(find.byType(ScanButton));
    await tester.pump();

    // ASSERT
    expect(callbackCalled, isTrue);
  });

  // ... 3 autres tests
}

// Répéter pour:
// - rewards_container_test.dart (5 tests)
// - add_balance_section_test.dart (5 tests)
// - error_states_test.dart (5 tests)

// TOTAL WIDGET TESTS: 20
```

---

## 🛠️ **INSTALLATION DÉPENDANCES**

### **Pour tests Cubit:**

```bash
# Ajouter à pubspec.yaml:
dev dependencies:
  bloc_test: ^9.1.6

# Installer
flutter pub get
```

### **Pour génération mocks Cubit:**

```bash
# Générer mocks après avoir ajouté @GenerateMocks
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📐 **PATTERN À SUIVRE**

### **1. UseCase Tests (Exemple parfait: ajouter_solde_test.dart)**

```
✅ Import mock depuis autre test (réutiliser mocks)
✅ Pattern AAA (Arrange, Act, Assert)
✅ Groupes: Succès, Échec, Cas Limites
✅ Verify: Vérifier appels repository
✅ Expect: Valider résultats
```

### **2. Cubit Tests (Pattern BlocTest)**

```
✅ Utiliser bloc_test package
✅ blocTest<MyCubit, MyState>(...)
✅ Tester états émis (expect)
✅ Tester transitions
✅ Mock tous les use cases
```

### **3. Widget Tests**

```
✅ testWidgets(...)
✅ pumpWidget pour render
✅ find.text / find.byType pour chercher
✅ tap pour interactions
✅ pump() après actions
```

---

## ✅ **CHECKLIST CRÉATION TEST**

```
[ ] 1. Créer fichier *_test.dart
[ ] 2. Importer flutter_test
[ ] 3. Importer classe à tester
[ ] 4. Importer/créer mocks
[ ] 5. setUp() pour initialisation
[ ] 6. Grouper tests logiquement
[ ] 7. Pattern AAA pour chaque test
[ ] 8. Vérifier avec verify()
[ ] 9. Lancer: flutter test
[ ] 10. Confirmer 100% réussite
```

---

## 🎯 **ORDRE RECOMMANDÉ**

```
PRIORITÉ 1: CaissierCubit (40 tests)
→ Cœur métier, très important

PRIORITÉ 2: Widgets critiques (5-10 tests)
→ Scanner, Add Balance

PRIORITÉ 3: Autres Widgets (10 tests)
→ Rewards, Error states

TOTAL: ~50-55 tests additionnels
OBJECTIF FINAL: 175-180 tests
```

---

## 🚀 **COMMANDES UTILES**

```bash
# Lancer tous les tests
flutter test

# Lancer fichier spécifique
flutter test test/unit/cubits/caissier_cubit_test.dart

# Avec coverage
flutter test --coverage

# Générer mocks
flutter pub run build_runner build

# Watch mode (relance auto)
flutter test --watch
```

---

## 📊 **PROGRESSION ATTENDUE**

```
ACTUELLEMENT:
✅ 127 tests (100%)

APRÈS CUBIT:
✅ 167 tests (127 + 40)

APRÈS WIDGETS:
✅ 187 tests (167 + 20)

OBJECTIF FINAL:
✅ 187+ tests
✅ Coverage 70%+
✅ Refactoring sécurisé
✅ CI/CD ready
```

---

## 💡 **CONSEILS**

### **Pour gagner du temps:**

1. **Réutiliser mocks:** Import depuis tests existants
2. **Copier patterns:** Adapter tests similaires
3. **Tester progressivement:** Fichier par fichier
4. **Commit souvent:** Sauvegarder progrès

### **Si bloqué:**

1. **Regarder exemples:** login_usecase_test.dart
2. **Vérifier imports:** Mock bien importé?
3. **Régénérer mocks:** build_runner build
4. **Lire erreurs:** Messages très clairs

---

## ✅ **VALIDATION FINALE**

```bash
# Avant refactoring:
flutter test                    # 100% réussite
flutter test --coverage         # Coverage 60%+
flutter analyze                 # 0 erreur
```

---

## 🎯 **VOUS ÊTES PRÊT!**

Vous avez:

- ✅ 127 tests fonctionnels (exemples parfaits)
- ✅ Templates pour tous types de tests
- ✅ Mocks configurés et fonctionnels
- ✅ Patterns à copier/adapter
- ✅ Commandes pour tout automatiser

**Prochaine étape:**

1. Créer caissier_cubit_test.dart (le plus important)
2. Tester progressivement (5-10 tests à la fois)
3. Commit après chaque groupe qui passe

**Besoin d'aide:** Regardez les exemples dans test/unit/usecases/

**Bonne chance!** 🚀
