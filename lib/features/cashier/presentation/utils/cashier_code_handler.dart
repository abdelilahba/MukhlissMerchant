/// Gestionnaire d'événements du scanner pour CaissierHomeScreen.
///
/// Cette classe centralise la logique de traitement des scans
/// et des saisies manuelles de codes client.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/core/di/injection_container.dart';
import 'package:mukhlissmagasin/core/services/app_logger.dart';
import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/scan_client_screen.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

/// Résultat d'un traitement de code.
class CodeProcessResult {
  final bool success;
  final String? errorMessage;
  final String? clientId;
  final String? magasinId;
  final int? pointsAdded;
  final int? totalPoints;

  const CodeProcessResult._({
    required this.success,
    this.errorMessage,
    this.clientId,
    this.magasinId,
    this.pointsAdded,
    this.totalPoints,
  });

  factory CodeProcessResult.success({
    required String clientId,
    required String magasinId,
    int? pointsAdded,
    int? totalPoints,
  }) {
    return CodeProcessResult._(
      success: true,
      clientId: clientId,
      magasinId: magasinId,
      pointsAdded: pointsAdded,
      totalPoints: totalPoints,
    );
  }

  factory CodeProcessResult.error(String message) {
    return CodeProcessResult._(success: false, errorMessage: message);
  }
}

/// Gestionnaire centralisé pour le traitement des codes client.
class CashierCodeHandler {
  final BuildContext context;

  CashierCodeHandler(this.context);

  /// Valide le code fourni.
  ///
  /// Retourne le code parsé ou null si invalide.
  int? validateCode(String code) {
    if (code.isEmpty) return null;
    return int.tryParse(code);
  }

  /// Traite un code en mode ajout de solde.
  ///
  /// [code] Le code unique du client (numérique).
  /// [montant] Le montant à ajouter.
  Future<CodeProcessResult> processBalanceCode({
    required String code,
    required double montant,
  }) async {
    final l10n = AppLocalizations.of(context);

    // Validation du code
    final uniqueCode = validateCode(code);
    if (uniqueCode == null) {
      return CodeProcessResult.error(
        code.isEmpty
            ? 'Veuillez saisir un code'
            : 'Code invalide. Veuillez saisir un code numérique.',
      );
    }

    // Validation du montant
    if (montant <= 0) {
      return CodeProcessResult.error(l10n.veuillez);
    }

    // Récupérer l'utilisateur courant
    final currentUser = getIt<AuthRepository>().getCurrentUser();
    if (currentUser == null) {
      return CodeProcessResult.error('Aucun magasin connecté');
    }

    try {
      // Récupérer le client
      final client = await context
          .read<CaissierCubit>()
          .getClientByUniqueCode(uniqueCode);

      // Points AVANT l'ajout
      final pointsAvant = await getIt<CaissierRepository>().getClientPoints(
        clientId: client.id,
        magasinId: currentUser.id,
      );

      // Ajouter le solde
      await context.read<CaissierCubit>().ajouterSoldeViaCodeUnique(
            uniqueCode: uniqueCode,
            magasinId: currentUser.id,
            montant: montant,
          );

      // Points APRÈS l'ajout
      final totalPoints = await getIt<CaissierRepository>().getClientPoints(
        clientId: client.id,
        magasinId: currentUser.id,
      );

      final pointsAdded = totalPoints - pointsAvant;

      AppLogger.info(
        '✅ Solde ajouté: $montant DH, +$pointsAdded points',
        tag: 'CashierCodeHandler',
      );

      return CodeProcessResult.success(
        clientId: client.id,
        magasinId: currentUser.id,
        pointsAdded: pointsAdded,
        totalPoints: totalPoints,
      );
    } catch (e) {
      AppLogger.error('Erreur processBalanceCode: $e', tag: 'CashierCodeHandler');
      return CodeProcessResult.error('Erreur: $e');
    }
  }

  /// Traite un code en mode récompenses.
  ///
  /// [code] Le code unique du client (numérique).
  Future<CodeProcessResult> processRewardsCode({required String code}) async {
    // Validation du code
    final uniqueCode = validateCode(code);
    if (uniqueCode == null) {
      return CodeProcessResult.error(
        code.isEmpty
            ? 'Veuillez saisir un code'
            : 'Code invalide. Veuillez saisir un code numérique.',
      );
    }

    final currentUser = getIt<AuthRepository>().getCurrentUser();
    if (currentUser == null) {
      return CodeProcessResult.error('Aucun magasin connecté');
    }

    try {
      final client = await context
          .read<CaissierCubit>()
          .getClientByUniqueCode(uniqueCode);

      final points = await getIt<CaissierRepository>().getClientPoints(
        clientId: client.id,
        magasinId: currentUser.id,
      );

      AppLogger.info(
        '✅ Client trouvé: ${client.id}, $points points',
        tag: 'CashierCodeHandler',
      );

      return CodeProcessResult.success(
        clientId: client.id,
        magasinId: currentUser.id,
        totalPoints: points,
      );
    } catch (e) {
      AppLogger.error('Erreur processRewardsCode: $e', tag: 'CashierCodeHandler');
      return CodeProcessResult.error('Erreur: $e');
    }
  }

  /// Traite un code selon le mode donné.
  Future<CodeProcessResult> processCode({
    required String code,
    required ScanMode mode,
    double? montant,
  }) async {
    if (mode == ScanMode.balance) {
      return processBalanceCode(
        code: code,
        montant: montant ?? 0,
      );
    } else {
      return processRewardsCode(code: code);
    }
  }
}
