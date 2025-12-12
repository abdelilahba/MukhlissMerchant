import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mukhlissmagasin/core/services/subscription_service.dart';
import 'package:mukhlissmagasin/core/services/periodic_subscription_checker.dart';

/// Widget qui protège l'accès à l'app
/// Vérifie l'abonnement au démarrage ET périodiquement
class SubscriptionGuard extends StatefulWidget {
  final Widget child;
  final String magasinId;

  const SubscriptionGuard({
    super.key,
    required this.child,
    required this.magasinId,
  });

  @override
  State<SubscriptionGuard> createState() => _SubscriptionGuardState();
}

class _SubscriptionGuardState extends State<SubscriptionGuard> {
  final _subscriptionService = SubscriptionService();
  final _periodicChecker = PeriodicSubscriptionChecker();
  
  bool _isChecking = true;
  AccessResult? _accessResult;

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _startPeriodicChecks();
  }

  @override
  void dispose() {
    _periodicChecker.dispose();
    super.dispose();
  }

  Future<void> _checkAccess() async {
    setState(() => _isChecking = true);
    
    final result = await _subscriptionService.checkAccess(widget.magasinId);
    
    if (mounted) {
      setState(() {
        _accessResult = result;
        _isChecking = false;
      });
    }
  }

  /// ✅ NOUVEAU : Démarre les vérifications périodiques
  void _startPeriodicChecks() {
    _periodicChecker.startPeriodicCheck(
      magasinId: widget.magasinId,
      interval: const Duration(seconds: 30), // Vérifie toutes les 30 secondes (30 min en prod)
      onAccessChanged: (result) {
        // Si l'abonnement expire pendant l'utilisation
        if (!result.canAccess && mounted) {
          // ✅ ARRÊTER les vérifications pour éviter les popups multiples
          _periodicChecker.stop();
          
          // Afficher la popup une seule fois
          _showExpirationDialog(result);
        }
      },
    );
  }

  /// ✅ AMÉLIO 1: Affiche popup avec fermeture automatique
  void _showExpirationDialog(AccessResult result) {
    int countdown = 10; // Compte à rebours de 10 secondes
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          // Démarrer le compte à rebours
          Future.delayed(const Duration(seconds: 1), () {
            if (countdown > 0 && context.mounted) {
              setState(() => countdown--);
              // Appel récursif toutes les secondes
              if (countdown > 0) {
                Future.delayed(const Duration(seconds: 1), () {
                  if (context.mounted) {
                    setState(() => countdown--);
                  }
                });
              }
            }
          });

          // Fermeture automatique après 10 secondes
          if (countdown == 0) {
            Future.delayed(Duration.zero, () {
              if (!context.mounted) return;
              Navigator.of(context).pop();
              SystemNavigator.pop(); // Ferme l'application
            });
          }

          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red[700], size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Abonnement Expiré',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.message,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'L\'application va se fermer dans $countdown secondes...',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contactez-nous pour renouveler :',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text('📞 +212 XXX XXX XXX'),
                        Text('📧 support@mukhliss.ma'),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    SystemNavigator.pop(); // Ferme l'application immédiatement
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Fermer maintenant'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Écran de chargement
    if (_isChecking) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Vérification de l\'abonnement...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Accès refusé
    if (_accessResult?.canAccess != true) {
      return _AccessDeniedScreen(
        result: _accessResult!,
        onRetry: _checkAccess,
      );
    }

    // Accès OK mais avertissement
    if (_accessResult!.shouldShowWarning) {
      return _WarningWrapper(
        result: _accessResult!,
        child: widget.child,
      );
    }

    // Accès OK
    return widget.child;
  }
}

/// Écran affiché quand l'accès est refusé
class _AccessDeniedScreen extends StatelessWidget {
  final AccessResult result;
  final VoidCallback onRetry;

  const _AccessDeniedScreen({
    required this.result,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône animée
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          result.blockIcon,
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Titre
                  Text(
                    result.blockTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Message
                  Text(
                    result.message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Date d'expiration si disponible
                  if (result.expiresOn != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Date d\'expiration',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(result.expiresOn!),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 48),
                  
                  // Informations de contact
                  _buildContactInfo(),
                  
                  const SizedBox(height: 24),
                  
                  // Bouton réessayer
                  if (result.status == 'error')
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.phone, color: Colors.blue, size: 32),
          const SizedBox(height: 12),
          const Text(
            'Contactez-nous pour renouveler',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '📞 +212 XXX XXX XXX',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '📧 support@mukhliss.ma',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Wrapper qui affiche un avertissement si l'abonnement expire bientôt
class _WarningWrapper extends StatelessWidget {
  final AccessResult result;
  final Widget child;

  const _WarningWrapper({
    required this.result,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.orange,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Abonnement expire dans ${result.daysRemaining} jour${result.daysRemaining! > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showRenewalDialog(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Renouveler'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showRenewalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renouveler l\'abonnement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Votre abonnement expire le ${_formatDate(result.expiresOn!)}.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Contactez votre fournisseur pour renouveler :',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('📞 +212 XXX XXX XXX'),
            const Text('📧 support@mukhliss.ma'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
