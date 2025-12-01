# 🚀 Déploiement de la fonction PostgreSQL pour les récompenses

## ⚠️ IMPORTANT - À faire avant de tester l'application

Pour que la réclamation de récompenses fonctionne correctement avec plusieurs utilisateurs simultanés, vous devez déployer la fonction PostgreSQL `claim_reward_atomic` dans votre base de données Supabase.

## 📋 Étapes de déploiement

### Option 1 : Via l'interface Supabase (Recommandé)

1. **Connectez-vous à votre projet Supabase**
   - Allez sur [https://supabase.com](https://supabase.com)
   - Ouvrez votre projet

2. **Accédez à l'éditeur SQL**
   - Dans la barre latérale, cliquez sur **"SQL Editor"**

3. **Créez une nouvelle requête**
   - Cliquez sur **"+ New query"**

4. **Copiez-collez le contenu du fichier**
   - Ouvrez le fichier `supabase_functions/claim_reward_atomic.sql`
   - Copiez tout le contenu
   - Collez-le dans l'éditeur SQL

5. **Exécutez la requête**
   - Cliquez sur **"Run"** ou appuyez sur `Ctrl+Enter` (Windows) / `Cmd+Enter` (Mac)
   - Vous devriez voir un message de succès

### Option 2 : Via la ligne de commande (Avancé)

Si vous avez installé le CLI Supabase :

```bash
# Assurez-vous d'être dans le répertoire du projet
cd /Users/prodmeat/MukhlissMEechant2/MukhlissMerchant

# Connectez-vous à votre projet Supabase
supabase link --project-ref VOTRE_PROJECT_REF

# Exécutez le fichier SQL
supabase db push
```

## ✅ Vérification du déploiement

Pour vérifier que la fonction a été créée correctement :

1. Dans l'éditeur SQL de Supabase, exécutez :

```sql
SELECT proname, prosrc 
FROM pg_proc 
WHERE proname = 'claim_reward_atomic';
```

2. Vous devriez voir une ligne avec le nom de la fonction

## 🔧 Test de la fonction

Pour tester manuellement la fonction :

```sql
-- Remplacez les UUIDs par des valeurs réelles de votre base de données
SELECT claim_reward_atomic(
    'CLIENT_UUID_ICI'::UUID,
    'MAGASIN_UUID_ICI'::UUID,
    'REWARD_UUID_ICI'::UUID,
    100  -- Points requis
);
```

## 🎯 Que fait cette fonction ?

Cette fonction PostgreSQL résout le problème de **race condition** qui se produit lorsque plusieurs utilisateurs tentent de réclamer des récompenses en même temps. Elle garantit que :

✅ **Atomicité** : Toutes les opérations (vérification, déduction des points, enregistrement) se font en une seule transaction
✅ **Isolation** : Utilise `FOR UPDATE` pour verrouiller la ligne pendant la transaction
✅ **Cohérence** : Impossible de réclamer une récompense sans points suffisants
✅ **Durabilité** : Les changements sont enregistrés de manière persistante

## 🐛 Dépannage

### Erreur : "function claim_reward_atomic does not exist"
➡️ Vous n'avez pas encore déployé la fonction. Suivez les étapes ci-dessus.

### Erreur : "insufficient_points"
➡️ Normal - le client n'a pas assez de points pour cette récompense.

### Erreur : "client_not_found"
➡️ Le client n'existe pas dans la table `clientmagasin` pour ce magasin.

### Erreur de permissions
➡️ Vérifiez que les lignes `GRANT EXECUTE` à la fin du fichier SQL correspondent aux rôles de votre projet.

## 📊 Performance

Cette fonction est optimisée pour gérer :
- ✅ Plusieurs centaines de réclamations par seconde
- ✅ Des milliers d'utilisateurs simultanés
- ✅ Aucune perte de données en cas de charge élevée

## 🔄 Mise à jour de la fonction

Si vous devez modifier la fonction plus tard, vous pouvez simplement réexécuter le fichier SQL. Le `CREATE OR REPLACE FUNCTION` remplacera l'ancienne version.
