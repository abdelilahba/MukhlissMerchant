import 'package:flutter/material.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';
import 'package:mukhlissmagasin/features/offers/presentation/cubit/offer_cubit.dart';
import 'package:mukhlissmagasin/features/offers/presentation/screens/add_offer_screen.dart';

class OfferManager {
  final OfferCubit offerCubit;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController pointsController = TextEditingController();

  OfferManager(this.offerCubit);

  /// Charge toutes les offres
  Future<void> loadOffers() async {
    await offerCubit.loadOffers();
  }

  /// Crée une nouvelle offre
  Future<void> createOffer({
    required String amount,
    required String points,
  }) async {
    try {
      await offerCubit.addOffer(
        amount: double.parse(amount),
        points: int.parse(points),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Met à jour une offre existante
Future<void> updateOffer({
    required String id,
    required String amount,
    required String points,
  }) async {
    try {
      await offerCubit.updateOffer(
        id: id,
        amount: double.parse(amount),
        points: int.parse(points),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Supprime une offre
  Future<void> deleteOffer(String id) async {
    try {
      await offerCubit.deleteOffer(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Affiche une boîte de dialogue de confirmation
  Future<bool> showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cette offre ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Navigation vers l'écran d'ajout
  void navigateToAddOffer(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AddOfferScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  /// Navigation vers l'écran d'édition
 void navigateToEditOffer(BuildContext context, Offer offer) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AddOfferScreen(offer: offer),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }

  /// Initialise les contrôleurs avec les valeurs d'une offre existante
  void initializeControllersForEdit(Offer offer) {
    amountController.text = offer.minAmount.toString();
    pointsController.text = offer.pointsGiven.toString();
  }

  /// Nettoie les contrôleurs
  void clearControllers() {
    amountController.clear();
    pointsController.clear();
  }

  /// Libère les ressources
  void dispose() {
    amountController.dispose();
    pointsController.dispose();
  }
}