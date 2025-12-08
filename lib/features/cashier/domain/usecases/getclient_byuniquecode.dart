/// Use case pour récupérer un client par son code unique.
///
/// Permet de rechercher un client via son code de fidélité
/// (généralement scanné via QR code ou saisi manuellement).
///
/// ### Exemple d'utilisation:
/// ```dart
/// final client = await getClientByUniqueCode.execute(
///   uniqueCode: 12345678,
/// );
/// print('Client trouvé: ${client.nom}');
/// ```
///
/// ### Business Rules:
/// - Code unique: 8 chiffres
/// - Un seul client par code
/// - Code généré automatiquement à l'inscription
///
/// ### Errors:
/// Peut lever une exception si:
/// - Code invalide
/// - Client non trouvé
/// - Problème réseau
library;

import 'package:mukhlissmagasin/features/cashier/domain/entities/Client_entity.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';

/// Use case pour récupérer un client par code unique.
///
/// Le code unique est un identifiant court (8 chiffres)
/// facile à scanner ou saisir manuellement.
class GetClientByUniqueCodeUseCase {
  /// Repository pour accès aux données
  final CaissierRepository repository;

  /// Crée une instance de [GetClientByUniqueCodeUseCase].
  GetClientByUniqueCodeUseCase({required this.repository});

  /// Exécute la recherche du client.
  ///
  /// [uniqueCode] - Code unique du client (8 chiffres)
  ///
  /// Returns: [Client] correspondant au code
  ///
  /// Throws: Exception si client non trouvé
  Future<Client> execute({
    required int uniqueCode,
  }) {
    // Validation du code
    if (uniqueCode <= 0) {
      throw ArgumentError('Le code unique doit être positif');
    }

    return repository.getClientByCodeUnique(uniqueCode: uniqueCode);
  }
}

/// Alias pour compatibilité avec l'ancien nom
@Deprecated('Utilisez GetClientByUniqueCodeUseCase à la place')
typedef GetclientByuniquecode = GetClientByUniqueCodeUseCase;
