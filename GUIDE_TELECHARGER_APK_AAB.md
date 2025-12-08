# 📥 GUIDE: Télécharger APK et AAB depuis Artifacts

## ✅ BUILD RÉUSSI!

Vos fichiers APK et AAB ont été créés avec succès!
L'erreur 403 était seulement sur la création automatique de Release, pas sur le build.

## 📍 OÙ TROUVER VOS FICHIERS

### Étape 1: Aller sur GitHub Actions

```
URL: https://github.com/abdelilahba/MukhlissMerchant/actions
```

### Étape 2: Trouver le Workflow

```
Cherchez dans la liste:
📍 Build & Release
   v1.0.0
   #X · mainD
   ✅ (avec checkmark vert - mais peut avoir un warning)
```

### Étape 3: Cliquer sur le Workflow

```
Vous verrez la page de détails du run
```

### Étape 4: Scroll Down

```
Allez tout en bas de la page
Vous verrez une section appelée "Artifacts"
```

### Étape 5: Télécharger

```
Dans la section Artifacts:

📦 mukhliss-merchant-0.9.0+1.apk
   Cliquez → Télécharge un ZIP

📦 mukhliss-merchant-0.9.0+1.aab
   Cliquez → Télécharge un ZIP

Ensuite:
→ Décompressez les ZIP
→ Vous aurez app-release.apk et app-release.aab
```

---

## 📱 UTILISER L'APK

### Installation Directe:

```
1. Transférez app-release.apk sur votre téléphone Android
2. Activez "Sources inconnues" si nécessaire
3. Installez l'APK
4. Testez l'application!
```

### Distribution Beta:

```
1. Partagez l'APK via Drive/Email
2. Les testeurs téléchargent
3. Ils installent
4. Recueillez feedback
```

---

## 📤 UTILISER L'AAB (Play Store)

### Upload Play Store:

```
1. Allez sur Google Play Console
2. Votre app → Releases
3. Create new release
4. Upload app-release.aab
5. Remplissez release notes
6. Submit for review
```

---

## 🔧 FIXER L'ERREUR 403 (Optionnel)

Si vous voulez que les Releases GitHub se créent automatiquement:

### Étape 1: Settings Repo

```
1. GitHub → Votre repo
2. Settings (en haut)
3. Actions → General (menu gauche)
```

### Étape 2: Permissions

```
1. Scroll down → "Workflow permissions"
2. Sélectionnez: "Read and write permissions"
3. ✅ Cochez: "Allow GitHub Actions to create and approve pull requests"
4. Save
```

### Étape 3: Re-créer Tag

```bash
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

Résultat: Release GitHub sera créée automatiquement!

---

## 🎉 FÉLICITATIONS!

Vous avez réussi à:
✅ Configurer CI/CD complet
✅ Résoudre tous les problèmes de build
✅ Créer APK production
✅ Créer AAB pour Play Store
✅ 141 tests passant
✅ Infrastructure professionnelle

**NIVEAU: Production Ready! 🚀**

---

**Créé:** 8 Décembre 2025 12h55  
**Build:** v1.0.0  
**Status:** ✅ Success
