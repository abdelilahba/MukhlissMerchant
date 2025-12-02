# 🧪 GUIDE DE TEST - Système d'Abonnement

## ✅ ÉTAT ACTUEL

- ✅ Tables SQL créées (à exécuter)
- ✅ Service Flutter créé
- ✅ Guard de protection créé
- ✅ main.dart intégré
- ✅ Documentation complète

---

## 🚀 ÉTAPES POUR TESTER

### 1. EXÉCUTER LE SQL SUR SUPABASE (10 min)

```bash
1. Ouvrir https://supabase.com/dashboard
2. Sélectionner votre projet
3. SQL Editor → New Query
4. Copier TOUT le contenu de : supabase_functions/subscription_system.sql
5. Cliquer "RUN"
6. Vérifier : Database → Tables → magasin_subscriptions doit exister
```

---

### 2. CRÉER UN ABONNEMENT TEST (5 min)

Dans Supabase SQL Editor, exécutez :

```sql
-- Remplacez 'VOTRE-MAGASIN-UUID' par un vrai UUID de votre table magasins
SELECT activate_magasin(
    'VOTRE-MAGASIN-UUID'::UUID,
    CURRENT_DATE + INTERVAL '30 days',  -- Expire dans 30 jours
    'test',
    0.00,
    NULL
);
```

**Comment trouver votre UUID de magasin ?**

```sql
SELECT id, nom FROM magasins LIMIT 10;
```

---

### 3. COMPILER L'APP (5 min)

```bash
# Nettoyer
flutter clean

# Installer les dépendances
flutter pub get

# Compiler (Android)
flutter build apk --release

# OU Compiler (debug pour tester)
flutter run
```

---

### 4. TESTER LES SCÉNARIOS

#### Scénario A : Abonnement Actif ✅

```
1. Ouvrez l'app
2. Vérifiez les logs :
   ✅ Magasin ID récupéré: xxx
   ✅ Cache invalidé pour client xxx
3. L'app doit s'ouvrir normalement
4. Pas d'écran de blocage
```

---

#### Scénario B : Abonnement Expiré ❌

```sql
-- Dans Supabase : Mettre l'abonnement dans le passé
UPDATE magasin_subscriptions
SET end_date = CURRENT_DATE - INTERVAL '1 day'
WHERE magasin_id = 'VOTRE-UUID'::UUID;
```

```
1. Redémarrez l'app
2. Écran de blocage doit s'afficher :
   "⏰ Abonnement Expiré"
3. Message : "Abonnement expiré le XX/XX/XXXX"
4. Bouton de contact visible
```

---

#### Scénario C : Expire Bientôt (5 jours) ⚠️

```sql
UPDATE magasin_subscriptions
SET end_date = CURRENT_DATE + INTERVAL '5 days'
WHERE magasin_id = 'VOTRE-UUID'::UUID;
```

```
1. Redémarrez l'app
2. App s'ouvre normalement
3. Bandeau ORANGE en haut :
   "⚠️ Abonnement expire dans 5 jours [Renouveler]"
```

---

#### Scénario D : Compte Suspendu 🚫

```sql
SELECT suspend_magasin(
    'VOTRE-UUID'::UUID,
    'Test de suspension'
);
```

```
1. Redémarrez l'app
2. Écran de blocage :
   "🚫 Compte Suspendu"
3. Message : "Compte suspendu : Test de suspension"
```

---

#### Scénario E : Réactiver

```sql
SELECT reactivate_magasin('VOTRE-UUID'::UUID);
```

```
1. Redémarrez l'app
2. App fonctionne normalement ✅
```

---

## 🔍 VÉRIFICATIONS

### Vérifier les logs d'accès

```sql
SELECT 
    created_at,
    event_type,
    user_email,
    denial_reason
FROM app_access_logs
WHERE magasin_id = 'VOTRE-UUID'::UUID
ORDER BY created_at DESC
LIMIT 20;
```

Vous devriez voir :
- `app_opened` - Quand l'app s'ouvre
- `access_granted` - Quand l'accès est OK
- `access_denied` - Quand l'accès est refusé

---

### Vérifier le statut

```sql
SELECT * FROM check_app_access('VOTRE-UUID'::UUID);
```

Retourne :
- `can_access` : true/false
- `status` : 'active', 'expired', 'suspended'
- `message` : Message affiché
- `expires_on` : Date d'expiration
- `days_remaining` : Jours restants

---

## 📱 TESTS SUR TABLETTE

### Installer l'APK

```bash
# Générer l'APK
flutter build apk --release

# APK sera dans :
build/app/outputs/flutter-apk/app-release.apk

# Transférer sur tablette
adb install build/app/outputs/flutter-apk/app-release.apk

# OU
# Copier manuellement via USB
```

---

### Tester sans internet

```
1. Activez le mode avion sur la tablette
2. Ouvrez l'app
3. Devrait afficher : "Erreur de connexion"
4. Désactivez le mode avion
5. Cliquez "Réessayer"
6. Doit fonctionner
```

---

## 🐛 DÉBOGAGE

### Problème : "Aucun magasin trouvé"

**Cause :** La requête `_getMagasinId()` ne trouve pas le magasin

**Solution :**
```dart
// Dans main.dart, ligne ~180, modifiez la requête selon votre structure :
final response = await SupabaseService.client
    .from('magasins')
    .select('id')
    .eq('id', user.id)  // ← Adaptez cette condition
    .maybeSingle();
```

---

### Problème : Erreur SQL "table does not exist"

**Cause :** Le SQL n'a pas été exécuté

**Solution :**
1. Vérifiez que vous avez exécuté `subscription_system.sql`
2. Allez dans Database → Tables
3. Vous devez voir : `magasin_subscriptions`, `subscription_payments`, `app_access_logs`

---

### Problème : SubscriptionGuard ne s'affiche pas

**Cause :** Import manquant ou erreur de compilation

**Solution :**
```bash
# Nettoyer et recompiler
flutter clean
flutter pub get
flutter run
```

---

## 📊 STATISTIQUES À VÉRIFIER

### Après les tests, vérifiez :

```sql
-- Nombre de tentatives d'accès
SELECT COUNT(*) FROM app_access_logs;

-- Par type
SELECT event_type, COUNT(*) 
FROM app_access_logs 
GROUP BY event_type;

-- Dernier accès par magasin
SELECT 
    magasin_id,
    MAX(created_at) as dernier_acces
FROM app_access_logs
WHERE event_type = 'app_opened'
GROUP BY magasin_id;
```

---

## ✅ CHECKLIST FINALE

Avant de push :

- [ ] SQL exécuté sur Supabase
- [ ] Tables créées (vérifiez dans Dashboard)
- [ ] Abonnement test créé
- [ ] App compile sans erreur
- [ ] Scénario A testé : Accès OK ✅
- [ ] Scénario B testé : Expiration bloque ❌
- [ ] Scénario C testé : Warning affiché ⚠️
- [ ] Scénario D testé : Suspension bloque 🚫
- [ ] Logs d'accès enregistrés
- [ ] Documentation lue

---

## 🎉 PRÊT POUR LA PRODUCTION

Quand tout fonctionne :

```bash
git status
git add .
git commit -m "feat: Système d'abonnement manuel complet

✨ Fonctionnalités
- Tables SQL avec fonctions automatiques
- Vérification d'accès en temps réel
- Écrans de blocage élégants
- Avertissements d'expiration
- Logging complet des accès

📝 Fichiers créés
- supabase_functions/subscription_system.sql
- lib/core/services/subscription_service.dart
- lib/core/guards/subscription_guard.dart
- GUIDE_ABONNEMENT.md
- supabase_functions/exemples_abonnement.sql

🔧 Modifications
- lib/main.dart : Intégration SubscriptionGuard

✅ Testé sur :
- Abonnement actif
- Abonnement expiré
- Suspension
- Réactivation"

git push origin mainD
```

---

## 📞 SUPPORT

Si vous avez des questions :
1. Consultez `GUIDE_ABONNEMENT.md`
2. Vérifiez `supabase_functions/exemples_abonnement.sql`
3. Regardez les logs dans Supabase Dashboard

Bon test ! 🚀
