import 'dart:async';
import 'package:mukhlissmagasin/core/services/subscription_service.dart';

/// Service qui vérifie périodiquement l'abonnement en arrière-plan
class PeriodicSubscriptionChecker {
  final SubscriptionService _subscriptionService = SubscriptionService();
  Timer? _timer;
  String? _currentMagasinId;
  
  // Callback appelé si l'abonnement expire pendant l'utilisation
  Function(AccessResult)? onAccessChanged;

  /// Démarre les vérifications périodiques
  void startPeriodicCheck({
    required String magasinId,
    Duration interval = const Duration(minutes: 30),
    Function(AccessResult)? onAccessChanged,
  }) {
    _currentMagasinId = magasinId;
    this.onAccessChanged = onAccessChanged;

    // Annuler le timer précédent s'il existe
    _timer?.cancel();

    // Créer un nouveau timer
    _timer = Timer.periodic(interval, (timer) async {
      await _checkAccess();
    });

    print('✅ Vérifications périodiques démarrées (toutes les ${interval.inMinutes} min)');
  }

  /// Vérifie l'accès maintenant (manuel)
  Future<AccessResult?> checkNow() async {
    if (_currentMagasinId == null) {
      print('❌ Pas de magasinId configuré');
      return null;
    }
    
    return await _checkAccess();
  }

  /// Vérification interne
  Future<AccessResult> _checkAccess() async {
    final result = await _subscriptionService.checkAccess(_currentMagasinId!);
    
    // Si l'accès a changé (devient bloqué), notifier
    if (!result.canAccess && onAccessChanged != null) {
      print('⚠️ Abonnement expiré détecté pendant l\'utilisation !');
      onAccessChanged!(result);
    }

    return result;
  }

  /// Arrête les vérifications
  void stop() {
    _timer?.cancel();
    _timer = null;
    print('🛑 Vérifications périodiques arrêtées');
  }

  /// Nettoyage
  void dispose() {
    stop();
  }
}
