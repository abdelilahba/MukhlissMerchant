# 🎯 Mukhliss Merchant - CI/CD Quick Start

![Tests](https://github.com/VOTRE_USERNAME/VOTRE_REPO/workflows/Tests%20Automatiques/badge.svg)
![Build](https://github.com/VOTRE_USERNAME/VOTRE_REPO/workflows/Build%20%26%20Release/badge.svg)

## ⚡ Quick Commands

### Tests Locaux

```bash
flutter test                    # Run tous les tests (141 tests)
flutter test --coverage         # Avec coverage
flutter analyze                 # Analyser code
```

### Build Local

```bash
flutter build apk --release     # Build APK
flutter build appbundle         # Build App Bundle
```

### CI/CD Commands

```bash
# Trigger tests automatiques
git push origin main

# Créer release
git tag v1.0.0
git push origin v1.0.0

# Manual workflow
# GitHub → Actions → Run workflow
```

## 📊 Test Coverage

- **Total Tests:** 141
- **Coverage:** ~60%
- **Temps Exec:** ~3 secondes

### Tests Par Module

```
✅ Auth UseCases:      15 tests (100%)
✅ Cashier UseCases:   30 tests (100%)
✅ CaissierCubit:      14 tests (~50%)
✅ Entités:            25 tests (70%)
✅ Services:           19 tests (80%)
✅ Utils:              15 tests (100%)
✅ Business Logic:     23 tests (70%)
```

## 🚀 Workflows

### 1. Tests Automatiques

- **Trigger:** Push/PR vers main
- **Durée:** ~2-3 minutes
- **Steps:** Install → Generate mocks → Analyze → Test

### 2. Build & Release

- **Trigger:** Tag (v\*) ou Manual
- **Durée:** ~5-7 minutes
- **Output:** APK + App Bundle

## 📖 Documentation

- **Guide Complet:** [CI_CD_GUIDE.md](./CI_CD_GUIDE.md)
- **Tests:** [test/README.md](./test/README.md)
- **Rapport Tests:** [test/RAPPORT_TESTS_FINAL_COMPLET.md](./test/RAPPORT_TESTS_FINAL_COMPLET.md)

## ✅ Status

```
✅ 141 tests (100% passing)
✅ CI/CD configuré
✅ Build automatique
✅ Coverage ~60%
✅ Production Ready
```

---

**Dernière mise à jour:** 4 Décembre 2025
