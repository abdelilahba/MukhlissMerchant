import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/core/widgets/app_drawer.dart';
import 'package:mukhlissmagasin/core/widgets/offer_card.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';
import 'package:mukhlissmagasin/features/offers/presentation/cubit/offer_cubit.dart';
import 'package:mukhlissmagasin/features/offers/presentation/managers/offer_manager.dart';
import 'package:mukhlissmagasin/l10n/l10n.dart';

import '../../../../l10n/app_localizations.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> 
    with SingleTickerProviderStateMixin {
      final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isGridView = true;
  String _searchQuery = '';
  // Largeur de la sidebar
  static const double sidebarWidth = 280.0;
  
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _minPointsController = TextEditingController();
  final TextEditingController _maxPointsController = TextEditingController();
  
  // Variables pour stocker les valeurs de recherche
  double? _minPriceFilter;
  double? _maxPriceFilter;
  int? _minPointsFilter;
  int? _maxPointsFilter;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  final manager = OfferManager(context.read<OfferCubit>());
  manager.loadOffers();
  

  return Scaffold(
    key: _scaffoldKey,
    backgroundColor: const Color(0xFFF5F7FA),
    drawer:  AppDrawer(),
    body: Row(
      children: [
        // Sidebar for large screens
       
          SizedBox(
            width: sidebarWidth,
            child: _buildSidebar(context, manager),
          ),
        // Main content area
        Expanded(
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, manager),
              _buildBody(context, manager),
            ],
          ),
        ),
      ],
    ),
    floatingActionButton: _buildFloatingActionButton(context, manager),
  );
}

  Widget _buildSidebar(BuildContext context, OfferManager manager) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header du sidebar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade600,
                  Colors.purple.shade500,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.local_offer_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.offrespeciale,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.decouvrezmeilleures,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu scrollable de la sidebar
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Options de vue
                  Text(
                   l10n.optionaffichage ,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Toggle Grid/List view
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isGridView = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isGridView ? Colors.blue.shade600 : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.grid_view_rounded,
                                    color: _isGridView ? Colors.white : Colors.grey.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                  l10n.grille  ,
                                    style: TextStyle(
                                      color: _isGridView ? Colors.white : Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isGridView = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isGridView ? Colors.blue.shade600 : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.view_list_rounded,
                                    color: !_isGridView ? Colors.white : Colors.grey.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.liste,
                                    style: TextStyle(
                                      color: !_isGridView ? Colors.white : Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Statistiques rapides
                  BlocBuilder<OfferCubit, OfferState>(
                    builder: (context, state) {
                      if (state is OffersLoaded) {
                        return _buildQuickStats(context, state.offers);
                      }
                      return const SizedBox();
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Menu de navigation supplémentaire (optionnel)
                  Text(
                    l10n.navigation,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildMenuItem(
                    icon: Icons.dashboard_outlined,
                    title: l10n.tableaubord ,
                    onTap: () {
                      // Navigation vers le dashboard
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.local_offer_outlined,
                    title:l10n.tousoffres ,
                    onTap: () {
                      // Déjà sur cette page
                    },
                    isActive: true,
                  ),
                ],
              ),
            ),
          ),
          
          // Actions rapides en bas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => manager.navigateToAddOffer(context),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.creeoffre),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => manager.loadOffers(),
                    icon: const Icon(Icons.refresh_rounded),
                    label:  Text(l10n.actualiiser),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue.shade50 : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive ? Border.all(color: Colors.blue.shade200) : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? Colors.blue.shade600 : Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive ? Colors.blue.shade700 : Colors.grey.shade700,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, List<Offer> offers) {
    final L10n=AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
           L10n.statistique ,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
               L10n.totaloffre ,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
              Text(
                '${offers.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
               L10n.activee ,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
              
            ],
          ),
        ],
      ),
    );
  }

 SliverAppBar _buildSliverAppBar(BuildContext context, OfferManager manager) {
  final l10n = AppLocalizations.of(context)!;
  
  return SliverAppBar(
    expandedHeight: 120,
    floating: false,
    pinned: true,
    elevation: 0,
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    // automaticallyImplyLeading: , // Menu seulement si pas de sidebar
    leading: IconButton(
      icon: const Icon(Icons.menu ,size: 28),
      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
    ),
    title: Row(
      children: [
      Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[400]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_offer_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 10,),
        Text(
      l10n.gestionoffre  ,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const Spacer(),
        if (MediaQuery.of(context).size.width > 800) ...[
          // Barre de recherche
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
           child: TextField(
  decoration: InputDecoration(
    hintText: l10n.rechercheoffre,
    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  ),
  keyboardType: TextInputType.number,
  onChanged: (value) {
    setState(() {
      _searchQuery = value;
      // Essayez de parser la valeur en double (pour le prix) ou int (pour les points)
      _minPriceFilter = double.tryParse(value);
      _minPointsFilter = int.tryParse(value);
    });
  },
),

           
          ),
        ],
      ],
    ),
  );
}

  Widget _buildBody(BuildContext context, OfferManager manager) {
    return BlocBuilder<OfferCubit, OfferState>(
      builder: (context, state) {
        return SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: _buildContent(context, state, manager),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, OfferState state, OfferManager manager) {
  final l10n = AppLocalizations.of(context)!;
  if (state is OffersLoaded) {
    List<Offer> filteredOffers = state.offers.where((offer) {
      // Filtre par recherche texte (prix ou points)
      if (_searchQuery.isNotEmpty) {
        final priceStr = offer.minAmount.toString(); // Enlever toStringAsFixed(2)
        final priceStrFormatted = offer.minAmount.toStringAsFixed(2);
        final pointsStr = offer.pointsGiven.toString();
        
         final matchesPrice = priceStr.contains(_searchQuery) || 
                            priceStrFormatted.contains(_searchQuery) ||
                            offer.minAmount.toString().replaceAll('.0', '').contains(_searchQuery);
        final matchesPoints = pointsStr.contains(_searchQuery);
        
        if (!matchesPrice && !matchesPoints) {
          return false;
        }
      }
      
      // Filtre par prix
      if (_minPriceFilter != null && offer.minAmount < _minPriceFilter!) return false;
      if (_maxPriceFilter != null && offer.minAmount > _maxPriceFilter!) return false;
      
      // Filtre par points
      if (_minPointsFilter != null && offer.pointsGiven < _minPointsFilter!) return false;
      if (_maxPointsFilter != null && offer.pointsGiven > _maxPointsFilter!) return false;
      
      return true;
    }).toList();

    if (filteredOffers.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(context, manager),
      );
    }
    
    return _isGridView 
        ? _buildOffersGrid(context, filteredOffers, manager)
        : _buildOffersList(context, filteredOffers, manager);
  }
  
  return SliverFillRemaining(
    child: FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.chargementoffres,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildOffersGrid(BuildContext context, List<Offer> offers, OfferManager manager) {
  // Calcul adaptatif du nombre de colonnes
  final screenWidth = MediaQuery.of(context).size.width - sidebarWidth - 48;
  final crossAxisCount = (screenWidth / 280).floor().clamp(1, 4); // Augmenter la largeur de base à 280
  
  return SliverGrid(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      childAspectRatio: 2.5, // Augmenter ce ratio pour des cartes plus larges (ancienne valeur: 0.75)
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
    ),
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      margin: const EdgeInsets.all(4), // Ajouter une marge
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: OfferCard(
                          offer: offers[index],
                          onEdit: () => _handleEdit(context, offers[index], manager),
                          onDelete: () => _handleDelete(context, offers[index].id, manager),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      childCount: offers.length,
    ),
  );
}

  Widget _buildOffersList(BuildContext context, List<Offer> offers, OfferManager manager) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 50)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 120,
                            child: OfferCard(
                              offer: offers[index],
                              onEdit: () => _handleEdit(context, offers[index], manager),
                              onDelete: () => _handleDelete(context, offers[index].id, manager),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        childCount: offers.length,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, OfferManager manager) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade100,
                  Colors.purple.shade100,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_offer_outlined,
              size: 80,
              color: Colors.blue.shade400,
            ),
          ),
          const SizedBox(height: 32),
          
          Text(
            l10n.aucunoffre,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              l10n.commencezparcree,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 48),
          
          ElevatedButton.icon(
            onPressed: () => manager.navigateToAddOffer(context),
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            label: Text(
              l10n.creeoffre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Colors.blue.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, OfferManager manager) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade600,
            Colors.purple.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade300,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => manager.navigateToAddOffer(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, String id, OfferManager manager) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _showModernDeleteDialog(context);
    if (confirmed) {
      try {
        print('Suppression de l\'offre avec ID: $id');
        await manager.deleteOffer(id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(l10n.offresupprimersucces),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erreur: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<bool> _showModernDeleteDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete_outline, color: Colors.red.shade600),
            ),
            const SizedBox(width: 12),
            Text(l10n.supprimeroffre),
          ],
        ),
        content: Text(l10n.etesvoussur),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.annuler,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.supprimer,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _handleEdit(BuildContext context, Offer offer, OfferManager manager) {
    manager.initializeControllersForEdit(offer);
    manager.navigateToEditOffer(context, offer);
  }
}