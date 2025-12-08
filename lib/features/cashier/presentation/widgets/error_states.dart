/// Widget d'état d'erreur de connexion.
///
/// Affiche un message d'erreur avec options de récupération
/// lorsque la connexion réseau échoue.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

/// Widget affichant l'état d'erreur de connexion.
///
/// Affiche:
/// - Icône d'erreur
/// - Message explicatif
/// - Bouton de réessai
///
/// ### Exemple:
/// ```dart
/// if (state is CaissierError) {
///   return ConnectionErrorState(
///     onRetry: () => cubit.getCurrentMagasin(),
///   );
/// }
/// ```
class ConnectionErrorState extends StatelessWidget {
  /// Callback appelé lors du clic sur "Réessayer"
  final VoidCallback? onRetry;

  /// Message d'erreur personnalisé (optionnel)
  final String? errorMessage;

  /// Afficher le bouton de paramètres
  final bool showSettingsButton;

  /// Crée un widget d'erreur de connexion.
  const ConnectionErrorState({
    super.key,
    this.onRetry,
    this.errorMessage,
    this.showSettingsButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône d'erreur de connexion
            _buildErrorIcon(),
            const SizedBox(height: 24),

            // Titre
            Text(
              l10n.problemconnexion,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              errorMessage ?? l10n.problemeconnexiondetails,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Boutons d'action
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// Construit l'icône d'erreur.
  Widget _buildErrorIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFECACA),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.wifi_off_rounded,
        size: 40,
        color: Color(0xFFDC2626),
      ),
    );
  }

  /// Construit les boutons d'action.
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bouton Réessayer
        ElevatedButton(
          onPressed: onRetry ??
              () {
                context.read<CaissierCubit>().getCurrentMagasin();
              },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh_rounded, size: 18),
              SizedBox(width: 8),
              Text('Réessayer'),
            ],
          ),
        ),

        // Bouton Paramètres (optionnel)
        if (showSettingsButton) ...[
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {
              // Ouvrir les paramètres
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings_outlined, size: 18),
                SizedBox(width: 8),
                Text('Paramètres'),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget d'erreur générique.
///
/// Pour les erreurs autres que la connexion.
class GenericErrorState extends StatelessWidget {
  /// Message d'erreur
  final String message;

  /// Callback de réessai
  final VoidCallback? onRetry;

  /// Icône personnalisée
  final IconData icon;

  /// Crée un widget d'erreur générique.
  const GenericErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),

            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
              textAlign: TextAlign.center,
            ),

            // Bouton réessayer
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget d'état d'erreur d'authentification.
class AuthenticationErrorState extends StatelessWidget {
  /// Callback pour rediriger vers login
  final VoidCallback? onLoginPressed;

  /// Crée un widget d'erreur d'authentification.
  const AuthenticationErrorState({
    super.key,
    this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_off_outlined,
                size: 40,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 24),

            // Titre
            const Text(
              'Session expirée',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            const Text(
              'Veuillez vous reconnecter',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Bouton connexion
            ElevatedButton.icon(
              onPressed: onLoginPressed ??
                  () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
              icon: const Icon(Icons.login),
              label: const Text('Connexion'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
