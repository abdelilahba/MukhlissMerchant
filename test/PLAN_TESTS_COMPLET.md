# 🧪 PLAN COMPLET - TESTS AVANT REFACTORING

**Stratégie:** Créer ~105 tests AVANT le refactoring  
**Objectif:** Protection maximale pendant refactoring  
**Timeline:** 2-3 jours tests + 1 jour refactoring

---

## 📊 **ÉTAT ACTUEL**

```
✅ Tests existants: 82
├─ Cache Service: 19 tests
├─ Client Entity: 10 tests
├─ Reward Entity: 15 tests
├─ Validation Utils: 15 tests
└─ Business Logic: 23 tests

⏳ Tests à créer: 105
├─ Auth UseCases: 15 tests
├─ Cashier UseCases: 30 tests
├─ CaissierCubit: 40 tests
└─ Widgets critiques: 20 tests

OBJECTIF FINAL: 187 tests (100% réussite)
```

---

## 🎯 **PHASE 1: AUTH USECASES (15 tests)**

### **Fichier 1: login_usecase_test.dart**

```dart
Tests Login UseCase (8 tests):
✅ login avec credentials valides → succès
✅ login avec email invalide → erreur
✅ login avec mot de passe incorrect → erreur
✅ login avec champs vides → erreur validation
✅ login avec erreur réseau → erreur network
✅ login retourne user correct
✅ login met à jour token
✅ login gère timeout
```

### **Fichier 2: signup_usecase_test.dart**

```dart
Tests Signup UseCase (7 tests):
✅ signup avec données valides → succès
✅ signup avec email existant → erreur
✅ signup avec email invalide → erreur validation
✅ signup avec mot de passe faible → erreur
✅ signup avec erreur réseau → erreur
✅ signup crée magasin automatiquement
✅ signup retourne user créé
```

**Temps estimé:** 2 heures  
**Difficulté:** Moyenne (mocking API)

---

## 🎯 **PHASE 2: CASHIER USECASES (30 tests)**

### **Fichier 1: ajouter_solde_test.dart (8 tests)**

```dart
✅ ajout solde succès → calcul points correct
✅ ajout 100 MAD → 10 points
✅ ajout solde client inexistant → erreur
✅ ajout montant négatif → erreur validation
✅ ajout montant 0 → erreur
✅ ajout met à jour solde total
✅ ajout créé transaction
✅ ajout avec erreur API → erreur
```

### **Fichier 2: getclient_bycode_test.dart (6 tests)**

```dart
✅ get client par code valide → client trouvé
✅ get client par code invalide → null
✅ get client par code vide → erreur
✅ get client par QR → succès
✅ get client avec erreur réseau → erreur
✅ get client retourne données complètes
```

### **Fichier 3: charger_recompenses_test.dart (8 tests)**

```dart
✅ charger récompenses client → liste
✅ charger avec points suffisants → disponibles
✅ charger avec points insuffisants → non disponibles
✅ charger client sans points → liste vide
✅ charger filtre par magasin → correct
✅ charger trie par points requis → ordre croissant
✅ charger avec erreur API → erreur
✅ charger cache résultats → performance
```

### **Fichier 4: reclamer_recompense_test.dart (8 tests)**

```dart
✅ réclamer avec points suffisants → succès
✅ réclamer déduit points → nouveau total
✅ réclamer avec points insuffisants → erreur
✅ réclamer récompense inexistante → erreur
✅ réclamer récompense inactive → erreur
✅ réclamer créé historique → transaction
✅ réclamer avec erreur API → erreur
✅ réclamer plusieurs fois → erreur limite
```

**Temps estimé:** 3 heures  
**Difficulté:** Moyenne

---

## 🎯 **PHASE 3: CAISSIER CUBIT (40 tests)**

### **caissier_cubit_test.dart (40 tests)**

```dart
INITIAL STATE (2 tests):
✅ initial state est CaissierInitial
✅ initial state a valeurs par défaut

SCAN QR (8 tests):
✅ scan QR succès → CaissierScanned
✅ scan QR charge client → données correctes
✅ scan QR code invalide → CaissierError
✅ scan QR timeout → erreur timeout
✅ scan QR stop → retour initial
✅ scan mode CLIENT vs REWARD → modes différents
✅ scan multiple fois → gère correctement
✅ scan avec cache → performance

ADD BALANCE (10 tests):
✅ add balance succès → CaissierBalanceAdded
✅ add balance calcule points → correct (10 MAD = 1pt)
✅ add balance montant invalide → erreur
✅ add balance client null → erreur
✅ add balance met à jour total → nouveau solde
✅ add balance joue son → audio feedback
✅ add balance montre confetti → celebration
✅ add balance avec récompenses → affiche liste
✅ add balance réinitialise form → clean state
✅ add balance avec erreur → CaissierError

REWARDS (8 tests):
✅ charger récompenses succès → liste
✅ charger récompenses vide → message
✅ réclamer récompense succès → points déduits
✅ réclamer récompense erreur → message
✅ afficher célébration → bottom sheet
✅ filtrer récompenses disponibles → points suffisants
✅ trier récompenses → par points requis
✅ navigation retour → initial state

MAGASIN (4 tests):
✅ charger magasin succès → données
✅ charger magasin erreur → error state
✅ magasin cached → pas rechargement
✅ magasin logo → affichage correct

ERROR HANDLING (8 tests):
✅ erreur network → message user-friendly
✅ erreur timeout → retry possible
✅ erreur validation → message spécifique
✅ erreur inconnue → message générique
✅ erreur affichée → snackbar visible
✅ erreur cleared → retour normal
✅ multiple erreurs → gère queue
✅ erreur pendant loading → stop loading
```

**Temps estimé:** 3 heures  
**Difficulté:** Élevée (state management)

---

## 🎯 **PHASE 4: WIDGETS CRITIQUES (20 tests)**

### **Fichier 1: scanner_section_test.dart (5 tests)**

```dart
✅ affiche scanner quand actif
✅ affiche bouton scan quand inactif
✅ toggle mode manuel/scan → change UI
✅ submit code manuel → appelle callback
✅ affiche erreur si code invalide
```

### **Fichier 2: rewards_container_test.dart (5 tests)**

```dart
✅ affiche liste récompenses → cards visibles
✅ affiche empty state si liste vide
✅ affiche récompenses disponibles en premier
✅ tap récompense → appelle callback
✅ affiche points requis → formaté correct
```

### **Fichier 3: add_balance_section_test.dart (5 tests)**

```dart
✅ input montant → validation
✅ bouton valider activé si montant valide
✅ bouton valider désactivé si montant invalide
✅ affiche calcul points → aperçu
✅ submit form → appelle callback
```

### **Fichier 4: error_states_test.dart (5 tests)**

```dart
✅ affiche AuthenticationError → UI correct
✅ affiche ConnectionError → UI correct
✅ bouton retry → appelle callback
✅ bouton login → navigation
✅ messages localisés → FR/EN/AR
```

**Temps estimé:** 2 heures  
**Difficulté:** Moyenne (testWidgets)

---

## ⏱️ **TIMELINE DÉTAILLÉE**

```
JOUR 1:
09h-11h: Phase 1 Auth (15 tests)
11h-14h: Phase 2 Cashier UC (30 tests)
14h-17h: Phase 3 Cubit (20/40 tests)

JOUR 2:
09h-11h: Phase 3 Cubit fin (20/40 tests)
11h-13h: Phase 4 Widgets (20 tests)
13h-14h: Review & fix

JOUR 3 (REFACTORING):
09h-11h: Phase 1 Scanner widgets
11h-12h: Phase 2 Error states
12h-13h: Pause + tests intermédiaires
14h-15h: Phase 3 Magasin widgets
15h-16h: Phase 4 Rewards widgets
16h-17h: Phase 5 Add balance
17h-17h30: Phase 6 Loading widgets
17h30-18h: Tests finaux + validation

RÉSULTAT:
✅ 187 tests (100% réussite)
✅ Refactoring sécurisé
✅ 0 régression
✅ Code maintenable
```

---

## 🛠️ **OUTILS & SETUP**

### **Dépendances installées:**

```yaml
✅ mockito: ^5.4.4
✅ build_runner: ^2.4.8
✅ flutter_test: sdk
```

### **Génération des mocks:**

```bash
# Pour chaque repository/service
flutter pub run build_runner build --delete-conflicting-outputs
```

### **Exécution tests:**

```bash
# Tous les tests
flutter test

# Un fichier
flutter test test/unit/usecases/auth/login_usecase_test.dart

# Avec coverage
flutter test --coverage
```

---

## ✅ **CHECKLIST VALIDATION**

### **Avant Refactoring:**

```
[ ] 187 tests créés
[ ] 100% tests passent
[ ] Coverage 60%+
[ ] Documentation tests
[ ] Mocks générés
[ ] CI/CD tests auto
```

### **Pendant Refactoring:**

```
[ ] Tests passent après chaque phase
[ ] 0 régression détectée
[ ] Commits incrémentaux
[ ] Review code
```

### **Après Refactoring:**

```
[ ] 187 tests toujours 100%
[ ] App fonctionne identique
[ ] Performance maintenue
[ ] Documentation à jour
```

---

## 🎯 **BÉNÉFICES**

```
TESTS AVANT REFACTORING:
✅ Filet de sécurité complet
✅ Détection régression immédiate
✅ Confiance refactoring totale
✅ Documentation code vivante
✅ Onboarding facilité
✅ Maintenance simplifiée

INVESTISSEMENT:
Temps: 2-3 jours tests
Résultat: Protection à vie!

ROI: INFINI ♾️
```

---

**Prêt à commencer Phase 1: Auth UseCases?** 🚀

Time estimé: 2 heures  
Tests: 15  
Difficulté: ⭐⭐⭐
