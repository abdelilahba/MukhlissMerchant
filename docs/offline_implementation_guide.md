# Guide d'Implémentation du Mode Offline

## 🎯 Pourquoi c'est Important ?

Pour **Mukhliss Merchant**, le mode offline est **critique** :

### Cas d'usage réels :

- ✅ **Connexion instable** : Magasins en zones à faible réseau
- ✅ **Heures de pointe** : Trop de clients, pas le temps d'attendre le réseau
- ✅ **Pannes réseau** : L'app doit continuer à fonctionner
- ✅ **Résilience** : Aucune transaction perdue

**Sans offline :** App inutilisable = perte de clients ❌  
**Avec offline :** App fiable = confiance client ✅

---

## 🏗️ Architecture Offline-First

```
┌────────────────────────────────────────────┐
│            UI (Screens/Widgets)            │
└──────────────────┬─────────────────────────┘
                   │
┌──────────────────▼─────────────────────────┐
│           Repository Pattern               │
│  ┌──────────────┐      ┌────────────────┐ │
│  │ Local Cache  │ ←──→ │ Remote API     │ │
│  │ (Hive/Drift) │      │ (Supabase)     │ │
│  └──────────────┘      └────────────────┘ │
└────────────────────────────────────────────┘
         │                      │
         ▼                      ▼
   💾 Stockage local      ☁️ Base de données
```

### Flux de données :

1. **Lecture (GET):**

   ```
   UI → Repository
       ├─→ Cache local (rapide) ✅
       └─→ API (si online) → Update cache
   ```

2. **Écriture (POST/PUT):**
   ```
   UI → Repository
       ├─→ Enregistrer dans cache
       ├─→ Ajouter à queue de sync
       └─→ Si online: Sync immédiat
           Sinon: Sync quand connexion revient
   ```

---

## 💾 Solution Recommandée : Hive

### Pourquoi Hive ?

- ✅ **Rapide** : NoSQL, très performant
- ✅ **Simple** : API facile
- ✅ **Type-safe** : Avec codegen
- ✅ **Léger** : Pas de dépendances natives
- ✅ **Parfait pour cache**

### Installation

```yaml
# pubspec.yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.0
```

```bash
flutter pub get
```

---

## 📝 Implémentation Étape par Étape

### Étape 1 : Initialiser Hive

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Hive
  await Hive.initFlutter();

  // Ouvrir les boxes nécessaires
  await Hive.openBox('clients');
  await Hive.openBox('rewards');
  await Hive.openBox('pending_sync');

  runApp(MyApp());
}
```

### Étape 2 : Créer le CacheService

Le fichier `lib/core/services/cache_service.dart` existe déjà.

Méthodes clés à avoir :

```dart
class CacheService {
  // Sauvegarder un client
  static Future<void> saveClient(String id, Map data);

  // Récupérer un client
  static Map? getClient(String id);

  // Sauvegarder pour sync plus tard
  static Future<void> addPendingSync(String type, Map data);

  // Récupérer les actions en attente
  static List getPendingSync();
}
```

### Étape 3 : Modifier le Repository

```dart
// lib/features/cashier/data/repositories/caissier_repository_impl.dart

class CaissierRepositoryImpl implements CaissierRepository {
  final CaissierRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo; // Pour vérifier si online

  @override
  Future<ClientEntity> getClientByCode(int code) async {
    // 1. Essayer le cache d'abord
    final cached = CacheService.getClient(code.toString());
    if (cached != null) {
      AppLogger.info('📦 Client depuis cache', tag: 'Repository');
      return ClientModel.fromJson(cached);
    }

    // 2. Si online, récupérer de l'API
    if (await networkInfo.isConnected) {
      try {
        final client = await remoteDataSource.getClientByCode(code);

        // 3. Sauvegarder dans le cache
        await CacheService.saveClient(
          code.toString(),
          client.toJson(),
        );

        return client;
      } catch (e) {
        throw ServerException();
      }
    }

    // 4. Offline et pas en cache
    throw CacheException();
  }

  @override
  Future<void> addBalance({
    required String clientId,
    required double montant,
  }) async {
    if (await networkInfo.isConnected) {
      // Online : envoyer directement
      await remoteDataSource.addBalance(clientId, montant);
    } else {
      // Offline : sauvegarder pour sync plus tard
      await CacheService.addPendingSync(
        type: 'add_balance',
        data: {
          'clientId': clientId,
          'montant': montant,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      AppLogger.info('📤 Balance sauvegardée pour sync', tag: 'Repository');
    }
  }
}
```

### Étape 4 : Service de Synchronisation

```dart
// lib/core/services/sync_service.dart

class SyncService {
  static Future<void> syncPendingActions() async {
    final pending = CacheService.getPendingSync();

    if (pending.isEmpty) {
      AppLogger.info('✅ Rien à synchroniser', tag: 'SyncService');
      return;
    }

    AppLogger.info('🔄 Sync de ${pending.length} actions', tag: 'SyncService');

    for (final action in pending) {
      try {
        final type = action['type'];
        final data = action['data'];

        // Envoyer à l'API selon le type
        if (type == 'add_balance') {
          await _syncAddBalance(data);
        } else if (type == 'claim_reward') {
          await _syncClaimReward(data);
        }

        // Supprimer de la queue si succès
        await CacheService.removePendingSync(action['id']);

      } catch (e) {
        AppLogger.error('❌ Erreur sync: $e', tag: 'SyncService');
        // Garder en queue pour retry
      }
    }
  }

  static Future<void> _syncAddBalance(Map data) async {
    // Appeler l'API Supabase
    await getIt<CaissierRepository>().addBalance(
      clientId: data['clientId'],
      montant: data['montant'],
    );
  }
}
```

### Étape 5 : Déclencher la Sync

```dart
// Dans l'app, écouter la connexion
import 'package:connectivity_plus/connectivity_plus.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Écouter les changements de connexion
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        // Connexion rétablie → sync !
        SyncService.syncPendingActions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(...);
  }
}
```

---

## 🎯 Fonctionnalités à Implémenter

### Phase 1 (Critical) 🔴

- [ ] Cache des clients scannés
- [ ] Queue de sync pour ajout de solde
- [ ] Indicateur offline/online dans l'UI

### Phase 2 (Important) 🟡

- [ ] Cache des récompenses
- [ ] Queue de sync pour réclamation de récompenses
- [ ] Retry automatique en cas d'échec

### Phase 3 (Nice to have) 🟢

- [ ] Prefetch des données au démarrage
- [ ] Compression du cache
- [ ] Analytics offline

---

## 📦 Dépendances Nécessaires

```yaml
dependencies:
  # Cache local
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Détection connexion
  connectivity_plus: ^5.0.2

  # Network check
  internet_connection_checker: ^1.0.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.0
```

---

## ✅ Checklist Implémentation

- [ ] 1. Ajouter dépendances
- [ ] 2. Initialiser Hive dans main()
- [ ] 3. Créer/Compléter CacheService
- [ ] 4. Modifier Repository pour utiliser cache
- [ ] 5. Créer SyncService
- [ ] 6. Écouter connexion et déclencher sync
- [ ] 7. Ajouter indicateur UI (online/offline)
- [ ] 8. Tester mode offline
- [ ] 9. Tester synchronisation

---

## 🚀 Priorisation

| Scénario             | Priorité        | Effort | Impact |
| -------------------- | --------------- | ------ | ------ |
| Cache clients        | 🔴 Critique     | 2h     | Élevé  |
| Sync ajout solde     | 🔴 Critique     | 3h     | Élevé  |
| Cache récompenses    | 🟡 Important    | 1h     | Moyen  |
| UI offline indicator | 🟢 Nice to have | 30min  | Faible |

**Estimation totale :** 1-2 jours de développement

---

## ⚠️ Points d'Attention

1. **Conflits de données** : Si 2 caisses modifient le même client offline
2. **Taille du cache** : Nettoyer régulièrement les vieux caches
3. **Sécurité** : Chiffrer les données sensibles dans Hive
4. **Tests** : Tester tous les scénarios offline

---

**Veux-tu que je t'aide à l'implémenter maintenant ?**
