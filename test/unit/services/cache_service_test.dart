import 'package:flutter_test/flutter_test.dart';
import 'package:mukhlissmagasin/core/services/cache_service.dart';

/// 🧪 TESTS UNITAIRES POUR CACHE_SERVICE
///
/// Ces tests vérifient que le système de cache fonctionne correctement
/// Chaque test suit le pattern AAA:
/// - ARRANGE: Préparer les données
/// - ACT: Exécuter l'action
/// - ASSERT: Vérifier le résultat

void main() {
  // 📦 GROUPE 1: Tests de base (set, get, clear)
  group('CacheService - Opérations de base', () {
    // ✅ TEST 1: set() puis get() retourne la valeur
    test('set puis get retourne la valeur stockée', () async {
      // ARRANGE: Créer un cache vide
      final cache = CacheService<String, String>();

      // ACT: Stocker une valeur
      await cache.set('nom', 'Mohamed');
      final resultat = await cache.get('nom');

      // ASSERT: Vérifier qu'on récupère bien la valeur
      expect(resultat, equals('Mohamed'));
    });

    // ✅ TEST 2: get() sur clé inexistante retourne null
    test('get sur clé inexistante retourne null', () async {
      // ARRANGE
      final cache = CacheService<String, String>();

      // ACT
      final resultat = await cache.get('cle_qui_existe_pas');

      // ASSERT
      expect(resultat, isNull);
    });

    // ✅ TEST 3: set() écrase l'ancienne valeur
    test('set écrase ancienne valeur avec même clé', () async {
      // ARRANGE
      final cache = CacheService<String, String>();

      // ACT
      await cache.set('ville', 'Rabat');
      await cache.set('ville', 'Casablanca'); // Écrase
      final resultat = await cache.get('ville');

      // ASSERT
      expect(resultat, equals('Casablanca'));
    });

    // ✅ TEST 4: clear() vide tout le cache
    test('clear supprime toutes les entrées', () async {
      // ARRANGE
      final cache = CacheService<String, String>();
      await cache.set('key1', 'value1');
      await cache.set('key2', 'value2');
      await cache.set('key3', 'value3');

      // ACT
      await cache.clear();

      // ASSERT
      expect(await cache.get('key1'), isNull);
      expect(await cache.get('key2'), isNull);
      expect(await cache.get('key3'), isNull);
    });

    // ✅ TEST 5: Plusieurs valeurs peuvent coexister
    test('stocke et récupère plusieurs valeurs', () async {
      // ARRANGE
      final cache = CacheService<String, int>();

      // ACT
      await cache.set('age', 25);
      await cache.set('score', 100);
      await cache.set('level', 5);

      // ASSERT
      expect(await cache.get('age'), equals(25));
      expect(await cache.get('score'), equals(100));
      expect(await cache.get('level'), equals(5));
    });
  });

  // ⏱️ GROUPE 2: Tests TTL (Time To Live)
  group('CacheService - TTL et expiration', () {
    // ✅ TEST 6: Entrée expire après TTL
    test('entrée expire après le TTL', () async {
      // ARRANGE: Cache avec TTL court (100ms)
      final cache = CacheService<String, String>(
        defaultTtl: Duration(milliseconds: 100),
      );

      // ACT
      await cache.set('temp', 'valeur temporaire');

      // Vérifier immédiatement (devrait être là)
      expect(await cache.get('temp'), equals('valeur temporaire'));

      // Attendre expiration
      await Future.delayed(Duration(milliseconds: 150));

      // ASSERT: Devrait être expiré
      expect(await cache.get('temp'), isNull);
    });

    // ✅ TEST 7: TTL personnalisé par entrée
    test('TTL personnalisé override le TTL par défaut', () async {
      // ARRANGE
      final cache = CacheService<String, String>(
        defaultTtl: Duration(hours: 1), // TTL défaut long
      );

      // ACT: Set avec TTL court custom
      await cache.set('ephemere', 'data', ttl: Duration(milliseconds: 50));

      // Attendre
      await Future.delayed(Duration(milliseconds: 100));

      // ASSERT: Devrait être expiré malgré TTL défaut long
      expect(await cache.get('ephemere'), isNull);
    });

    // ✅ TEST 8: Entrée non expirée reste accessible
    test('entrée non expirée reste accessible', () async {
      // ARRANGE
      final cache = CacheService<String, String>(
        defaultTtl: Duration(seconds: 10), // Long TTL
      );

      // ACT
      await cache.set('stable', 'valeur');

      // Attendre un peu (mais moins que TTL)
      await Future.delayed(Duration(milliseconds: 100));

      // ASSERT: Devrait toujours être là
      expect(await cache.get('stable'), equals('valeur'));
    });
  });

  // 🔢 GROUPE 3: Tests taille maximale et éviction LRU
  group('CacheService - Taille max et LRU', () {
    // ✅ TEST 9: Respect de la taille maximale
    test('cache respecte la taille maximale', () async {
      // ARRANGE: Cache avec max 3 entrées
      final cache = CacheService<String, int>(maxSize: 3);

      // ACT: Ajouter 4 entrées
      await cache.set('key1', 1);
      await cache.set('key2', 2);
      await cache.set('key3', 3);
      await cache.set('key4', 4); // Devrait évincer key1

      // ASSERT
      expect(await cache.get('key1'), isNull); // Évincé (LRU)
      expect(await cache.get('key2'), equals(2));
      expect(await cache.get('key3'), equals(3));
      expect(await cache.get('key4'), equals(4));
    });

    // ✅ TEST 10: LRU - Least Recently Used
    test('éviction LRU garde les plus récemment utilisés', () async {
      // ARRANGE
      final cache = CacheService<String, String>(maxSize: 2);

      // ACT
      await cache.set('old', 'ancienne');
      await cache.set('new', 'nouvelle');

      // Accéder à 'old' (devient récent)
      await cache.get('old');

      // Ajouter une 3ème entrée
      await cache.set('newest', 'plus récente');

      // ASSERT: 'new' devrait être évincé (pas 'old')
      expect(await cache.get('old'), equals('ancienne')); // Gardé
      expect(await cache.get('new'), isNull); // Évincé
      expect(await cache.get('newest'), equals('plus récente'));
    });
  });

  // 🔄 GROUPE 4: Tests getOrLoad (Cache avec fallback)
  group('CacheService - getOrLoad', () {
    // ✅ TEST 11: getOrLoad charge si absent
    test('getOrLoad appelle loader si clé absente', () async {
      // ARRANGE
      final cache = CacheService<String, String>();
      int loaderCalls = 0;

      // ACT
      final result = await cache.getOrLoad('user', () async {
        loaderCalls++;
        return 'User Data';
      });

      // ASSERT
      expect(result, equals('User Data'));
      expect(loaderCalls, equals(1)); // Loader appelé
    });

    // ✅ TEST 12: getOrLoad utilise cache si présent
    test('getOrLoad utilise cache si disponible', () async {
      // ARRANGE
      final cache = CacheService<String, String>();
      int loaderCalls = 0;

      // Pré-remplir cache
      await cache.set('user', 'Cached User');

      // ACT
      final result = await cache.getOrLoad('user', () async {
        loaderCalls++;
        return 'Fresh User';
      });

      // ASSERT
      expect(result, equals('Cached User')); // Valeur du cache
      expect(loaderCalls, equals(0)); // Loader PAS appelé
    });

    // ✅ TEST 13: getOrLoad met en cache après chargement
    test('getOrLoad met en cache la valeur chargée', () async {
      // ARRANGE
      final cache = CacheService<String, int>();

      // ACT: Premier appel (charge)
      await cache.getOrLoad('count', () async => 42);

      // Second appel (devrait venir du cache)
      final result = await cache.get('count');

      // ASSERT
      expect(result, equals(42)); // Maintenant en cache
    });
  });

  // 🔄 GROUPE 5: Tests types différents
  group('CacheService - Types de données', () {
    // ✅ TEST 14: Cache d'entiers
    test('fonctionne avec des entiers', () async {
      final cache = CacheService<String, int>();

      await cache.set('count', 42);
      expect(await cache.get('count'), equals(42));
    });

    // ✅ TEST 15: Cache de doubles
    test('fonctionne avec des doubles', () async {
      final cache = CacheService<String, double>();

      await cache.set('price', 99.99);
      expect(await cache.get('price'), equals(99.99));
    });

    // ✅ TEST 16: Cache de listes
    test('fonctionne avec des listes', () async {
      final cache = CacheService<String, List<String>>();

      final villes = ['Rabat', 'Casa', 'Fes'];
      await cache.set('villes', villes);

      final result = await cache.get('villes');
      expect(result, equals(villes));
      expect(result?.length, equals(3));
    });

    // ✅ TEST 17: Cache de maps
    test('fonctionne avec des maps', () async {
      final cache = CacheService<String, Map<String, dynamic>>();

      final user = {'nom': 'Ahmed', 'age': 30};
      await cache.set('user1', user);

      final result = await cache.get('user1');
      expect(result?['nom'], equals('Ahmed'));
      expect(result?['age'], equals(30));
    });
  });

  // 🎯 GROUPE 6: Tests edge cases
  group('CacheService - Cas limites', () {
    // ✅ TEST 18: Clé vide
    test('accepte clé vide', () async {
      final cache = CacheService<String, String>();

      await cache.set('', 'empty key value');
      expect(await cache.get(''), equals('empty key value'));
    });

    // ✅ TEST 19: Grande quantité de données
    test('gère grande quantité de données', () async {
      final cache = CacheService<int, String>(maxSize: 1000);

      // Ajouter 500 entrées
      for (int i = 0; i < 500; i++) {
        await cache.set(i, 'value$i');
      }

      // Vérifier quelques valeurs
      expect(await cache.get(0), equals('value0'));
      expect(await cache.get(250), equals('value250'));
      expect(await cache.get(499), equals('value499'));
    });
  });
}
