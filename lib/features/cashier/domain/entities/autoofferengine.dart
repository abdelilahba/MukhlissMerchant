import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';

class AutoOfferEngine {
  /// Renvoie le [pointsGagnes, soldeRestant]
  static (int points, double remaining) applyOffers({
    required double soldeInitial,
    required List<Offer> offers,
  }) {
    // 1.  Trie décroissant par montant
    final sorted = [...offers]..sort((a, b) => b.minAmount.compareTo(a.minAmount));

    var reste = soldeInitial;
    var points = 0;

    for (final offer in sorted) {
      // 2.  Tant qu'on peut payer l'offre, on l'applique
      while (reste >= offer.minAmount) {
        reste -= offer.minAmount;
        points += offer.pointsGiven;
      }
    }
    return (points, reste);
  }
}
