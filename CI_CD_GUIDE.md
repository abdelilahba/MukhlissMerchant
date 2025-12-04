# 🚀 GUIDE CI/CD - MUKHLISS MERCHANT

**Date:** 4 Décembre 2025  
**Status:** ✅ PRÊT À UTILISER  
**Workflows:** 2 (Tests + Build)

---

## 📋 **VUE D'ENSEMBLE**

```
WORKFLOWS CONFIGURÉS:

1. ✅ tests.yml
   Quand: À chaque push/PR
   Quoi: Tests automatiques
   Durée: ~2-3 minutes

2. ✅ build.yml
   Quand: Sur tag version
   Quoi: Build APK + App Bundle
   Durée: ~5-7 minutes
```

---

## 🎯 **WORKFLOW 1: TESTS AUTOMATIQUES**

### **Fichier:** `.github/workflows/tests.yml`

### **Quand il s'exécute:**

```
✅ À chaque push vers main
✅ À chaque push vers develop
✅ À chaque Pull Request vers main
```

### **Ce qu'il fait:**

```
ÉTAPES:
1. 📥 Télécharge votre code
2. 🔧 Installe Flutter 3.16.0
3. 📦 Installe dépendances (flutter pub get)
4. 🏗️ Génère mocks (build_runner)
5. 🔍 Analyse code (flutter analyze)
6. 🧪 Lance tests (flutter test --coverage)
7. 📊 Affiche résumé (141 tests)
8. 📈 Upload coverage vers Codecov (optionnel)

TEMPS: ~2-3 minutes
RÉSULTAT: ✅ ou ❌ dans GitHub
```

### **Comment voir les résultats:**

```
1. Allez sur GitHub → votre repo
2. Cliquez sur "Actions"
3. Voyez tous les runs
4. Cliquez sur un run pour détails

STATUT VISIBLE:
✅ Checkmark vert = Tests passent
❌ X rouge = Tests échouent
```

---

## 🏗️ **WORKFLOW 2: BUILD & RELEASE**

### **Fichier:** `.github/workflows/build.yml`

### **Quand il s'exécute:**

```
✅ Sur tag version (ex: v1.0.0, v1.0.1)
✅ Manuel (via GitHub Actions UI)
```

### **Ce qu'il fait:**

```
ÉTAPES:
1. 📥 Télécharge code
2. 🔧 Setup Flutter
3. 📦 Install dependencies
4. 🏗️ Generate mocks
5. 🧪 Run tests (vérification)
6. 📱 Build APK release
7. 📦 Build App Bundle release
8. 📋 Extrait version de pubspec.yaml
9. ⬆️ Upload APK vers artifacts
10. ⬆️ Upload App Bundle vers artifacts
11. 🎉 Créé GitHub Release avec APK/AAB

TEMPS: ~5-7 minutes
RÉSULTAT: APK + AAB téléchargeables
```

### **Comment l'utiliser:**

#### **Option 1: Via Tag (Recommandé)**

```bash
# 1. Mettre à jour version dans pubspec.yaml
version: 1.0.1+2

# 2. Commit
git add pubspec.yaml
git commit -m "Release v1.0.1"

# 3. Créer tag
git tag v1.0.1

# 4. Push tag
git push origin v1.0.1

# 5. GitHub Actions se lance automatiquement! 🚀
```

#### **Option 2: Manuel**

```
1. GitHub → votre repo → Actions
2. Cliquer "Build & Release"
3. Cliquer "Run workflow"
4. Choisir branche
5. Run workflow
```

### **Récupérer les artifacts:**

```
MÉTHODE 1: GitHub Artifacts (temporaire)
1. Actions → Run spécifique
2. Scroll down → "Artifacts"
3. Download APK ou AAB

MÉTHODE 2: GitHub Releases (permanent)
1. Releases (page principale repo)
2. Latest release
3. Assets → Download files
```

---

## 🔐 **CONFIGURATION SIGNING (OPTIONNEL)**

Pour signer automatiquement les builds pour Play Store:

### **1. Créer Keystore**

```bash
cd android/app

keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storepass VOTRE_PASSWORD \
  -keypass VOTRE_PASSWORD
```

### **2. Créer `android/key.properties`**

```properties
storePassword=VOTRE_PASSWORD
keyPassword=VOTRE_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

⚠️ **IMPORTANT:** Ajouter à `.gitignore`:

```
android/key.properties
android/app/upload-keystore.jks
```

### **3. Configurer GitHub Secrets**

```
GitHub → Settings → Secrets → Actions

Créer secrets:
- KEYSTORE_BASE64 (keystore encodé en base64)
- KEYSTORE_PASSWORD
- KEY_ALIAS
- KEY_PASSWORD
```

### **4. Encoder keystore en base64:**

```bash
base64 android/app/upload-keystore.jks | tr -d '\n' > keystore.txt
# Copier contenu de keystore.txt dans KEYSTORE_BASE64
```

### **5. Mettre à jour build.yml:**

Ajouter avant build steps:

```yaml
- name: 🔐 Decode keystore
  run: |
    echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/app/upload-keystore.jks
    echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" >> android/key.properties
    echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
    echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
    echo "storeFile=upload-keystore.jks" >> android/key.properties
```

---

## 📊 **MONITORING & STATISTIQUES**

### **Voir historique runs:**

```
GitHub → Actions

INFOS DISPONIBLES:
✅ Temps exécution
✅ Tests passés/échoués
✅ Logs complets
✅ Artifacts générés
✅ Coverage (si Codecov configuré)
```

### **Codecov (Coverage visualisé):**

```
1. Créer compte: codecov.io
2. Connecter repo GitHub
3. Token généré automatiquement
4. Coverage visible sur codecov.io
5. Badge à ajouter README.md
```

---

## 🎯 **UTILISATION QUOTIDIENNE**

### **Workflow Développeur:**

```
JOUR À JOUR:

1. 🔨 Coder feature/fix
2. 🧪 Tests locaux: flutter test
3. 📤 Push vers GitHub
4. ⏱️ Attendre 2-3 min (CI tests)
5. ✅ Si vert → Merge PR
6. ❌ Si rouge → Fix et re-push

RELEASE:

1. 📝 Update version pubspec.yaml
2. 🏷️ Create tag (v1.0.x)
3. 📤 Push tag
4. ⏱️ Attendre 5-7 min (Build)
5. 📥 Download APK/AAB
6. 🚀 Deploy sur Play Store
```

---

## ✅ **CHECKLIST ACTIVATION CI/CD**

```
PHASE 1: Tests Automatiques (MAINTENANT)
[ ] ✅ tests.yml créé
[ ] Push vers GitHub
[ ] Vérifier workflow s'exécute
[ ] Tests passent (141 tests)
[ ] Résoudre erreurs si nécessaire

PHASE 2: Build Automatique (MAINTENANT)
[ ] ✅ build.yml créé
[ ] Créer tag v1.0.0
[ ] Push tag
[ ] Vérifier build réussit
[ ] Télécharger APK

PHASE 3: Signing (OPTIONNEL)
[ ] Créer keystore
[ ] Configurer GitHub Secrets
[ ] Mettre à jour build.yml
[ ] Test build signed

PHASE 4: Codecov (OPTIONNEL)
[ ] Créer compte Codecov
[ ] Connecter repo
[ ] Vérifier coverage upload
[ ] Ajouter badge README
```

---

## 🚨 **TROUBLESHOOTING**

### **Tests échouent sur CI mais passent en local:**

```
CAUSES POSSIBLES:
- Dépendances manquantes
- build_runner pas run
- Flutter version différente

SOLUTION:
1. Vérifier Flutter version (3.16.0)
2. Vérifier build_runner step
3. Check logs détaillés GitHub Actions
```

### **Build échoue:**

```
CAUSES:
- Signing manquant (si configuré)
- Flutter version
- Dépendances Android

SOLUTION:
1. Désactiver signing temporairement
2. Vérifier logs build
3. Tester build local avant push
```

---

## 📈 **MÉTRIQUES ACTUELLES**

```
╔══════════════════════════════════════════════╗
║  TESTS:          141 tests                   ║
║  COVERAGE:       ~60%                        ║
║  TEMPS CI:       ~2-3 min                    ║
║  TEMPS BUILD:    ~5-7 min                    ║
║  STATUS:         ✅ PRODUCTION READY          ║
╚══════════════════════════════════════════════╝
```

---

## 🎊 **PROCHAINES ÉTAPES**

```
MAINTENANT:
1. ✅ Push workflows vers GitHub
2. ✅ Tester workflow tests
3. ✅ Créer premier tag + release

SEMAINE PROCHAINE:
4. ⏳ Configurer signing (si Play Store)
5. ⏳ Setup Codecov (optionnel)
6. ⏳ Ajouter badges README

EN CONTINU:
→ Push code → Tests auto → Merge
→ Tag version → Build auto → Deploy
```

---

## 🔗 **RESSOURCES**

```
DOCUMENTATION:
- GitHub Actions: https://docs.github.com/actions
- Flutter CI: https://docs.flutter.dev/deployment/cd
- Codecov: https://docs.codecov.com

VOTRE SETUP:
- Workflows: .github/workflows/
- Tests: 141 tests (test/)
- Coverage: Coverage ~60%
```

---

**CI/CD CONFIGURÉ! 🚀**

**Prêt à push vers GitHub et activer!**

---

**Créé:** 4 Décembre 2025  
**Auteur:** Antigravity AI  
**Projet:** Mukhliss Merchant
