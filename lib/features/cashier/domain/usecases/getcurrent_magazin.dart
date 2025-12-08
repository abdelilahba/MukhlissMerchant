/// Use case pour récupérer le magasin de l'utilisateur connecté.
///
/// Récupère les informations du magasin associé
/// à l'utilisateur actuellement authentifié.
///
/// ### Exemple d'utilisation:
/// ```dart
/// final magasin = await getCurrentMagasin.execute();
/// print('Magasin: ${magasin.nomEnseigne}');
/// print('Logo: ${magasin.imageUrl}');
/// ```
///
/// ### Business Rules:
/// - Un utilisateur = un magasin
/// - Magasin créé lors de l'inscription
/// - Utilisé pour contextualiser les opérations
///
/// ### Errors:
/// Peut lever une exception si:
/// - Utilisateur non connecté
/// - Magasin non trouvé
/// - Problème réseau
library;

import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';
import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';

/// Use case pour récupérer le magasin courant.
///
/// Retourne le magasin associé à l'utilisateur connecté.
/// Utilisé pour afficher les informations du magasin
/// et contextualiser les transactions.
class GetCurrentMagasinUseCase {
  /// Repository pour accès aux données
  final CaissierRepository repository;

  /// Crée une instance de [GetCurrentMagasinUseCase].
  GetCurrentMagasinUseCase({required this.repository});

  /// Exécute la récupération du magasin.
  ///
  /// Returns: [MagasinModel] du magasin courant
  ///
  /// Throws: Exception si utilisateur non connecté ou magasin non trouvé
  Future<MagasinModel> execute() async {
    return await repository.currentMagazin();
  }
}

/// Alias pour compatibilité avec l'ancien nom
@Deprecated('Utilisez GetCurrentMagasinUseCase à la place')
typedef GetCurrentMagazin = GetCurrentMagasinUseCase;
