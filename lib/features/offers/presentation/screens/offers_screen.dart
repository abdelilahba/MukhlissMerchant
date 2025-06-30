import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/core/widgets/app_drawer.dart';
import 'package:mukhlissmagasin/core/widgets/offer_card.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';
import 'package:mukhlissmagasin/features/offers/presentation/cubit/offer_cubit.dart';
import 'package:mukhlissmagasin/features/offers/presentation/managers/offer_manager.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final manager = OfferManager(context.read<OfferCubit>());
    manager.loadOffers();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context, manager),
      drawer: const AppDrawer(),
      body: _buildBody(context, manager),
      floatingActionButton: _buildFloatingActionButton(context, manager),
    );
  }

  AppBar _buildAppBar(BuildContext context, OfferManager manager) {
    return AppBar(
      title: const Text('Offres spéciales', 
        style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          tooltip: 'Ajouter une offre',
          onPressed: () => manager.navigateToAddOffer(context),
        ),
      ],
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OfferManager manager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocBuilder<OfferCubit, OfferState>(
        builder: (context, state) {
          if (state is OffersLoaded) {
            return _buildContent(context, state.offers, manager);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Offer> offers, OfferManager manager) {
    if (offers.isEmpty) return _buildEmptyState();
    
    return RefreshIndicator(
      onRefresh: () => manager.loadOffers(),
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 16, bottom: 80),
        itemCount: offers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, index) => OfferCard(
          offer: offers[index],
          onEdit: () => _handleEdit(ctx, offers[index], manager),
          onDelete: () => _handleDelete(ctx, offers[index].id, manager),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Aucune offre disponible',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text('Appuyez sur + pour ajouter une offre',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context, OfferManager manager) {
    return FloatingActionButton(
      onPressed: () => manager.navigateToAddOffer(context),
      child: const Icon(Icons.add_rounded),
    );
  }

 Future<void> _handleDelete(BuildContext context, String id, OfferManager manager) async {
    final confirmed = await manager.showDeleteConfirmation(context);
    if (confirmed) {
      try {
        print('Suppression de l\'offre avec ID: $id');
        await manager.deleteOffer(id);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: $e')),
        );
      }
    }
  }

void _handleEdit(BuildContext context, Offer offer, OfferManager manager) {
  manager.initializeControllersForEdit(offer);
  manager.navigateToEditOffer(context, offer);
}
}