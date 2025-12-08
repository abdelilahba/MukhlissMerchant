import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/core/di/injection_container.dart';
import 'package:mukhlissmagasin/core/utils/app_logger.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/widgets/rewards_celebration_sheet.dart';

/// Classe utilitaire pour afficher les dialogues du module caissier.
class CaissierDialogs {
  /// Affiche le dialogue de célébration avec les récompenses disponibles.
  ///
  /// Retourne les données de sélection si l'utilisateur choisit d'échanger.
  static Future<Map<String, dynamic>?> showRewardsCelebration(
    BuildContext context, {
    required String clientId,
    required String magasinId,
    required int pointsAdded,
    required int totalPoints,
  }) async {
    try {
      // Récupérer les récompenses disponibles
      final availableRewards =
          await getIt<CaissierRepository>().getAvailableRewards(
        clientId: clientId,
        magasinId: magasinId,
      );

      if (!context.mounted) return null;

      Map<String, dynamic>? result;

      // Afficher le dialogue centré
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 60,
            vertical: 24,
          ),
          child: RewardsCelebrationSheet(
            pointsAdded: pointsAdded,
            totalPoints: totalPoints,
            availableRewards: availableRewards,
            onExchangeRewards: () {
              result = {
                'action': 'exchange',
                'clientId': clientId,
                'magasinId': magasinId,
                'totalPoints': totalPoints,
              };
              Navigator.of(dialogContext).pop();
            },
            onSaveLater: () {
              result = {'action': 'save'};
              Navigator.of(dialogContext).pop();
            },
          ),
        ),
      );

      return result;
    } catch (e) {
      AppLogger.error(
        'Erreur lors de la récupération des récompenses: $e',
        tag: 'Rewards',
        error: e,
      );

      // En cas d'erreur, afficher quand même le bottom sheet sans récompenses
      if (!context.mounted) return null;

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => RewardsCelebrationSheet(
          pointsAdded: pointsAdded,
          totalPoints: totalPoints,
          availableRewards: [],
        ),
      );

      return null;
    }
  }

  /// Affiche un dialogue de confirmation.
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    Color confirmColor = Colors.blue,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child:
                Text(confirmText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
