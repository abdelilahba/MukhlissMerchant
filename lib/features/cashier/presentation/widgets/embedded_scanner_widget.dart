/// Widget de scanner embarqué pour l'écran caissier.
///
/// Encapsule la logique de scan QR en mode balance ou récompenses.
library;

import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/core/services/app_logger.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/scan_client_screen.dart';

/// Callback appelé après un scan réussi.
typedef OnScanSuccessCallback = void Function(Map<String, dynamic> data);

/// Widget de scanner embarqué.
///
/// Affiche un scanner QR code adapté au mode (balance ou rewards).
class EmbeddedScannerWidget extends StatelessWidget {
  /// Mode de scan actuel.
  final ScanMode scanMode;

  /// Montant pour le mode balance.
  final double? montant;

  /// Callback de succès pour le mode balance.
  final OnScanSuccessCallback? onBalanceSuccess;

  /// Callback de succès pour le mode rewards.
  final OnScanSuccessCallback? onRewardsSuccess;

  const EmbeddedScannerWidget({
    super.key,
    required this.scanMode,
    this.montant,
    this.onBalanceSuccess,
    this.onRewardsSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: _buildScanner(),
    );
  }

  Widget _buildScanner() {
    if (scanMode == ScanMode.balance) {
      return ScanClientScreen.balance(
        montant ?? 0.0,
        onScanSuccess: (data) {
          AppLogger.info('🎉 Scan balance réussi: $data', tag: 'Scanner');
          onBalanceSuccess?.call(data);
        },
      );
    } else {
      return ScanClientScreen.rewards(
        onScanSuccess: (data) {
          AppLogger.info('🎉 Scan récompense réussi: $data', tag: 'Scanner');
          onRewardsSuccess?.call(data);
        },
      );
    }
  }
}

/// Widget pour la section scanner complète avec toggle.
class ScannerSection extends StatelessWidget {
  /// Affiche le logo au lieu du scanner si true.
  final bool showManualInput;

  /// Mode de scan actuel.
  final ScanMode scanMode;

  /// Montant pour le mode balance.
  final double montant;

  /// Callback de succès pour le scan balance.
  final OnScanSuccessCallback? onBalanceSuccess;

  /// Callback de succès pour le scan rewards.
  final OnScanSuccessCallback? onRewardsSuccess;

  /// Widget à afficher en mode manuel (logo).
  final Widget logoWidget;

  const ScannerSection({
    super.key,
    required this.showManualInput,
    required this.scanMode,
    required this.montant,
    required this.logoWidget,
    this.onBalanceSuccess,
    this.onRewardsSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: showManualInput
          ? logoWidget
          : EmbeddedScannerWidget(
              scanMode: scanMode,
              montant: montant,
              onBalanceSuccess: onBalanceSuccess,
              onRewardsSuccess: onRewardsSuccess,
            ),
    );
  }
}
