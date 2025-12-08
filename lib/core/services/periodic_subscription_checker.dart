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
    Duration interval = const Duration(seconds: 10),
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

  }

  /// Vérifie l'accès maintenant (manuel)
  Future<AccessResult?> checkNow() async {
    if (_currentMagasinId == null) {
      return null;
    }
    
    return await _checkAccess();
  }

  /// Vérification interne
  Future<AccessResult> _checkAccess() async {
    final result = await _subscriptionService.checkAccess(_currentMagasinId!);
    
    // Si l'accès a changé (devient bloqué), notifier
    if (!result.canAccess && onAccessChanged != null) {
      onAccessChanged!(result);
    }

    return result;
  }

  /// Arrête les vérifications
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Nettoyage
  void dispose() {
    stop();
  }
}
