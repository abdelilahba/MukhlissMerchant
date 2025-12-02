# 🔐 Système d'Abonnement Manuel - Guide Complet

## 📋 Vue d'ensemble

Ce système permet de gérer les abonnements des magasins de manière **MANUELLE** :
- Paiements par **espèces** ou **virement bancaire**
- Activation/désactivation par vous (admin)
- Vérification en temps réel via Supabase
- Blocage automatique si expiré

---

## 🚀 Installation (3 étapes)

### ÉTAPE 1 : Créer les tables SQL

1. Allez sur https://supabase.com/dashboard
2. Sélectionnez votre projet
3. Cliquez sur "SQL Editor"
4. Copiez le contenu de `supabase_functions/subscription_system.sql`
5. Cliquez "RUN"

✅ **Vérification** : Vous devriez voir les tables créées dans Database → Tables

---

### ÉTAPE 2 : Intégrer dans l'app Flutter

Modifiez votre fichier `lib/main.dart` :

```dart
import 'package:mukhlissmagasin/core/guards/subscription_guard.dart';
import 'package:mukhlissmagasin/core/services/supabase_service.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<String>(
        future: _getCurrentMagasinId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: Text('Erreur: Magasin non trouvé')),
            );
          }

          // 🔒 Wrapper avec SubscriptionGuard
          return SubscriptionGuard(
            magasinId: snapshot.data!,
            child: CaissierHomeScreen(), // Votre écran principal
          );
        },
      ),
    );
  }

  Future<String> _getCurrentMagasinId() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) throw Exception('Non authentifié');
    
    // Récupérer le magasin de l'utilisateur
    final response = await SupabaseService.client
        .from('magasins')
        .select('id')
        .eq('id', user.id)
        .single();
    
    return response['id'] as String;
  }
}
```

---

### ÉTAPE 3 : Tester

1. Compilez et lancez l'app
2. Si aucun abonnement → Écran de blocage s'affiche
3. Activez un magasin (voir commandes SQL ci-dessous)
4. Redémarrez l'app → Accès autorisé ✅

---

## 💼 Gestion des Abonnements (SQL)

### ✅ Activer un nouveau magasin

```sql
-- Exemple : Activer pour 1 mois
SELECT activate_magasin(
    'uuid-du-magasin'::UUID,
    CURRENT_DATE + INTERVAL '1 month',  -- Date de fin
    'mensuel',                           -- Type de plan
    500.00,                              -- Prix
    'votre-admin-uuid'::UUID            -- Votre ID
);
```

---

### 💰 Enregistrer un paiement

```sql
-- Exemple : Client paie 500 DH pour 1 mois
SELECT record_payment_and_renew(
    'uuid-du-magasin'::UUID,
    500.00,                    -- Montant
    'espèces',                 -- Méthode ('espèces', 'virement_bancaire', 'cheque')
    1,                         -- Nombre de mois
    'RECU-2024-12-001',       -- Référence du reçu
    'Payé en espèces le 01/12/2024',  -- Notes
    'votre-admin-uuid'::UUID  -- Votre ID
);
```

---

### 🚫 Suspendre un magasin

```sql
-- Exemple : Suspendre pour impayé
SELECT suspend_magasin(
    'uuid-du-magasin'::UUID,
    'Facture impayée depuis 30 jours'  -- Raison
);
```

L'app sera **immédiatement bloquée** sur cet appareil.

---

### ✅ Réactiver un magasin

```sql
SELECT reactivate_magasin('uuid-du-magasin'::UUID);
```

L'app sera **immédiatement débloquée**.

---

## 📊 Voir les abonnements

### Liste de tous les magasins avec leur statut

```sql
SELECT * FROM v_magasins_subscription_status;
```

Colonnes importantes :
- `magasin_name` : Nom du magasin
- `status` : 'active', 'expired', 'suspended'
- `end_date` : Date d'expiration
- `days_remaining` : Jours restants
- `alert_status` : 'OK', 'Expire bientôt', 'Expiré'

---

### Voir les paiements d'un magasin

```sql
SELECT 
    payment_date,
    amount,
    payment_method,
    payment_reference,
    period_start,
    period_end,
    notes
FROM subscription_payments
WHERE magasin_id = 'uuid-du-magasin'::UUID
ORDER BY payment_date DESC;
```

---

### Voir les accès récents

```sql
SELECT 
    created_at,
    event_type,
    user_email,
    denial_reason
FROM app_access_logs
WHERE magasin_id = 'uuid-du-magasin'::UUID
ORDER BY created_at DESC
LIMIT 50;
```

---

## 🎯 Workflows Courants

### Nouveau Client

```
1. Client vous contacte
2. Vous négociez le prix (500 DH/mois par exemple)
3. Client paie en espèces
4. VOUS exécutez :
   SELECT activate_magasin(...)
5. Vous envoyez l'APK au client
6. Client installe et ouvre l'app
7. App vérifie → Accès autorisé ✅
```

---

### Renouvellement

```
1. Magasin expire dans 7 jours
2. App affiche un bandeau orange "Expire bientôt"
3. Client vous contacte pour renouveler
4. Client paie 500 DH
5. VOUS exécutez :
   SELECT record_payment_and_renew(...)
6. Abonnement prolongé automatiquement ✅
```

---

### Impayé

```
1. Abonnement expire aujourd'hui
2. App se bloque automatiquement ❌
3. Client appelle : "L'app ne marche plus !"
4. Vous : "Renouvelez votre abonnement"
5. Client paie
6. VOUS exécutez :
   SELECT record_payment_and_renew(...)
7. App débloquée immédiatement ✅
```

---

### Fraude Détectée

```
1. Vous détectez une utilisation frauduleuse
2. VOUS exécutez :
   SELECT suspend_magasin(..., 'Fraude détectée')
3. App bloquée immédiatement ❌
4. Message : "Compte suspendu - Fraude détectée"
```

---

## 🔍 Questions Fréquentes

### Q: Comment récupérer l'UUID d'un magasin ?

```sql
SELECT id, nom FROM magasins WHERE nom LIKE '%nom%';
```

---

### Q: Peut-on tester avec un abonnement gratuit ?

Oui ! Créez un abonnement avec `plan_price = 0` :

```sql
SELECT activate_magasin(
    'uuid-magasin'::UUID,
    CURRENT_DATE + INTERVAL '1 month',
    'essai_gratuit',
    0.00,  -- Gratuit
    NULL
);
```

---

### Q: Comment prolonger de plusieurs mois d'un coup ?

```sql
-- Exemple : 12 mois (1 an)
SELECT record_payment_and_renew(
    'uuid-magasin'::UUID,
    5000.00,    -- Prix annuel
    'virement_bancaire',
    12,         -- 12 mois
    'VIRT-2024-12-001',
    'Abonnement annuel',
    'votre-uuid'::UUID
);
```

---

### Q: L'app vérifie à chaque ouverture ?

**OUI !** À chaque fois que l'utilisateur ouvre l'app :
1. App appelle `check_app_access()`
2. Supabase vérifie la date d'expiration
3. Si expiré → Blocage immédiat
4. Si OK → Accès autorisé

**C'est impossible à contourner** car la vérification est côté serveur.

---

## 📱 Écrans de l'App

### Accès refusé (expiré)
```
⏰
Abonnement Expiré

Abonnement expiré le 15/11/2024.
Veuillez renouveler.

[Date d'expiration: 15 Novembre 2024]

📞 +212 XXX XXX XXX
📧 support@mukhliss.ma
```

---

### Accès refusé (suspendu)
```
🚫
Compte Suspendu

Compte suspendu : Facture impayée depuis 30 jours

📞 +212 XXX XXX XXX
📧 support@mukhliss.ma
```

---

### Avertissement (expire bientôt)
```
[Bandeau orange en haut]
⚠️ Abonnement expire dans 3 jours  [Renouveler]
```

---

## ⚙️ Configuration

### Changer le numéro de téléphone

Modifiez dans `lib/core/guards/subscription_guard.dart` :

```dart
Text(
  '📞 +212 600 123 456',  // ← Votre numéro
  ...
),
```

---

### Changer l'email de support

```dart
Text(
  '📧 votre-email@example.com',  // ← Votre email
  ...
),
```

---

## 🎉 C'est Tout !

Votre système d'abonnement est prêt !

**Testez maintenant :**
1. Exécutez le SQL sur Supabase
2. Intégrez le Guard dans votre app
3. Activez un magasin test
4. Compilez et testez l'app

**Besoin d'aide ?** Consultez les documents :
- `SYSTEME_ABONNEMENT.md` - Vue détaillée
- `supabase_functions/subscription_system.sql` - Code SQL complet
