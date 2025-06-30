import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/core/di/injection_container.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_state.dart';

class ClientOffersScreen extends StatefulWidget {
  final String clientId;
  final String magasinId;
  final Map<String, dynamic> clientData;

  const ClientOffersScreen({
    super.key,
    required this.clientId,
    required this.magasinId,
    required this.clientData,
  });

  @override
  State<ClientOffersScreen> createState() => _ClientOffersScreenState();
}

class _ClientOffersScreenState extends State<ClientOffersScreen> {
  late final CaissierCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<CaissierCubit>();
    _loadOffers();
  }

  void _loadOffers() {
    _cubit.loadClientOffers(
      clientId: widget.clientId,
      magasinId: widget.magasinId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: BlocConsumer<CaissierCubit, CaissierState>(
          listener: _handleStateChanges,
          builder: (context, state) => _buildBody(state),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Offres Client'),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadOffers,
          tooltip: 'Actualiser',
        ),
      ],
    );
  }

  Widget _buildBody(CaissierState state) {
    switch (state) {
      case CaissierLoading():
        return _buildLoadingState();
      case OffresChargees():
        return _buildOffersLoaded(state);
      case CaissierError():
        return _buildErrorState(state.message);
      default:
        return _buildInitialState();
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Chargement des offres...',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersLoaded(OffresChargees state) {
    final availableOffers = state.offers.where((offer) {
      // Filter only offers that can be exchanged (client has enough balance)
      return state.clientSolde >= offer.minAmount;
    }).toList();

    return Column(
      children: [
        _buildClientInfo(state.clientSolde),
        Expanded(
          child: availableOffers.isEmpty
              ? _buildNoOffersAvailable(state.clientSolde)
              : _buildOffersList(availableOffers, state.clientSolde),
        ),
      ],
    );
  }

  Widget _buildClientInfo(double clientSolde) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet,
            size: 32,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          const Text(
            'Solde Client',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${clientSolde.toStringAsFixed(2)} DH',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoOffersAvailable(double clientSolde) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune offre disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            clientSolde > 0
                ? 'Le solde du client est insuffisant pour les offres disponibles'
                : 'Le client n\'a pas de solde disponible',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOffersList(List<dynamic> offers, double clientSolde) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        return _buildOfferCard(offer, clientSolde);
      },
    );
  }

  Widget _buildOfferCard(dynamic offer, double clientSolde) {
    final montantSolde = offer.minAmount; // Changed from offer.minAmount ?? 0.0
    final points = offer.pointsGiven; // Changed from offer.pointsGiven ?? 0
    final titre = 'Offre #${offer.id}'; // Since titre doesn't exist, use offer ID
    final description = 'Montant minimum: ${montantSolde.toStringAsFixed(2)} DH - Points gagnés: $points'; // Create description from available data
    final canExchange = clientSolde >= montantSolde;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: canExchange ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_offer,
                    color: canExchange ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            'Coût: ${montantSolde.toStringAsFixed(2)} DH',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.stars, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            'Points: $points',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: canExchange ? () => _exchangeOffer(offer, montantSolde, points) : null,
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: const Text('Échanger'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canExchange ? Colors.green : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadOffers,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Text(
        'Initialisation...',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  void _exchangeOffer(dynamic offer, double montantSolde, int points) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer l\'échange'),
        content: Text(
          'Voulez-vous échanger ${montantSolde.toStringAsFixed(2)} DH de solde contre $points points pour l\'offre "Offre #${offer.id}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performExchange(offer, montantSolde, points);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _performExchange(dynamic offer, double montantSolde, int points) {
    _cubit.exchangeOffer(
      clientId: widget.clientId,
      magasinId: widget.magasinId,
      offreId: offer.id.toString(),
      montantSolde: montantSolde,
      points: points,
    );
  }

  void _handleStateChanges(BuildContext context, CaissierState state) {
    switch (state) {
      case OffreEchangee():
        _showSnackBar(
          message: state.message,
          backgroundColor: Colors.green,
        );
        // Reload offers to update the list
        _loadOffers();
        break;
      case CaissierError():
        _showSnackBar(
          message: 'Erreur: ${state.message}',
          backgroundColor: Colors.red,
        );
        break;
      default:
        break;
    }
  }

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}