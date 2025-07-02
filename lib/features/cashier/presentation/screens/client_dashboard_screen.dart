import 'package:flutter/material.dart';

import 'package:mukhlissmagasin/features/cashier/presentation/screens/recompenses_disponibles_screen.dart';

class ClientOffersRewardsScreen extends StatefulWidget {
  final String clientId;
  final String magasinId;
  final Map<String, dynamic> clientData;

  const ClientOffersRewardsScreen({
    super.key,
    required this.clientId,
    required this.magasinId,
    required this.clientData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ClientOffersRewardsScreenState createState() => _ClientOffersRewardsScreenState();
}

class _ClientOffersRewardsScreenState extends State<ClientOffersRewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.clientData['nom'] ?? 'Client'} - Offres & Récompenses'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.local_offer)),
            Tab(icon: Icon(Icons.card_giftcard)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet Offres
          // ClientOffersScreen(
          //   clientId: widget.clientId,
          //   magasinId: widget.magasinId,
          //   clientData: widget.clientData,
          // ),
          
          // Onglet Récompenses
          // ClientRewardsScreen(
          //   clientId: widget.clientId,
          //   magasinId: widget.magasinId,
          //   clientName: widget.clientData['nom'] ?? 'Client',
          // ),
        ],
      ),
    );
  }
}