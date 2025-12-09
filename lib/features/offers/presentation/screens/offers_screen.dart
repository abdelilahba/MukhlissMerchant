import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/core/widgets/app_drawer.dart';
import 'package:mukhlissmagasin/core/widgets/offer_card.dart';
import 'package:mukhlissmagasin/features/offers/domain/entities/offer_entity.dart';
import 'package:mukhlissmagasin/features/offers/presentation/cubit/offer_cubit.dart';
import 'package:mukhlissmagasin/features/offers/presentation/managers/offer_manager.dart';
import 'package:mukhlissmagasin/features/offers/presentation/widgets/widgets.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

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
  String _selectedFilter = 'all';

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
      drawer: AppDrawer(),
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

  /// Construit la sidebar.
  ///
  /// Utilise le widget refactorisé [OffersSidebar].
  Widget _buildSidebar(BuildContext context, OfferManager manager) {
    return OffersSidebar(
      manager: manager,
      isGridView: _isGridView,
      selectedFilter: _selectedFilter,
      onViewChanged: (value) => setState(() => _isGridView = value),
      onFilterChanged: (value) => setState(() => _selectedFilter = value),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, OfferManager manager) {
    final l10n = AppLocalizations.of(context);

    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      // automaticallyImplyLeading: , // Menu seulement si pas de sidebar
      leading: IconButton(
        icon: const Icon(Icons.menu, size: 28),
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
          SizedBox(
            width: 10,
          ),
          Text(
            l10n.gestionoffre,
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

  Widget _buildContent(
      BuildContext context, OfferState state, OfferManager manager) {
    final l10n = AppLocalizations.of(context);
    if (state is OffersLoaded) {
      List<Offer> filteredOffers = state.offers.where((offer) {
        if (_selectedFilter == 'active' && !offer.isActive) {
          return false;
        }
        // Filtre par recherche texte (prix ou points)
        if (_searchQuery.isNotEmpty) {
          final priceStr =
              offer.minAmount.toString(); // Enlever toStringAsFixed(2)
          final priceStrFormatted = offer.minAmount.toStringAsFixed(2);
          final pointsStr = offer.pointsGiven.toString();

          final matchesPrice = priceStr.contains(_searchQuery) ||
              priceStrFormatted.contains(_searchQuery) ||
              offer.minAmount
                  .toString()
                  .replaceAll('.0', '')
                  .contains(_searchQuery);
          final matchesPoints = pointsStr.contains(_searchQuery);

          if (!matchesPrice && !matchesPoints) {
            return false;
          }
        }

        // Filtre par prix
        if (_minPriceFilter != null && offer.minAmount < _minPriceFilter!) {
          return false;
        }
        if (_maxPriceFilter != null && offer.minAmount > _maxPriceFilter!) {
          return false;
        }

        // Filtre par points
        if (_minPointsFilter != null && offer.pointsGiven < _minPointsFilter!) {
          return false;
        }
        if (_maxPointsFilter != null && offer.pointsGiven > _maxPointsFilter!) {
          return false;
        }

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
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
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

  Widget _buildOffersGrid(
      BuildContext context, List<Offer> offers, OfferManager manager) {
    // Calcul adaptatif du nombre de colonnes
    final screenWidth = MediaQuery.of(context).size.width - sidebarWidth - 48;
    final crossAxisCount = (screenWidth / 280)
        .floor()
        .clamp(1, 4); // Augmenter la largeur de base à 280

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio:
            2.5, // Augmenter ce ratio pour des cartes plus larges (ancienne valeur: 0.75)
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
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: OfferCard(
                            offer: offers[index],
                            onEdit: () =>
                                _handleEdit(context, offers[index], manager),
                            onDelete: () => _handleDelete(
                                context, offers[index].id, manager),
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

  Widget _buildOffersList(
      BuildContext context, List<Offer> offers, OfferManager manager) {
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
                              color: Colors.black.withValues(alpha: 0.08),
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
                              onEdit: () =>
                                  _handleEdit(context, offers[index], manager),
                              onDelete: () => _handleDelete(
                                  context, offers[index].id, manager),
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

  /// Construit l'état vide.
  ///
  /// Utilise le widget refactorisé [OffersEmptyState].
  Widget _buildEmptyState(BuildContext context, OfferManager manager) {
    return OffersEmptyState(manager: manager);
  }

  Widget _buildFloatingActionButton(
      BuildContext context, OfferManager manager) {
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

  Future<void> _handleDelete(
      BuildContext context, String id, OfferManager manager) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _showModernDeleteDialog(context);
    if (confirmed) {
      try {
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
    final l10n = AppLocalizations.of(context);
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
        ) ??
        false;
  }

  void _handleEdit(BuildContext context, Offer offer, OfferManager manager) {
    manager.initializeControllersForEdit(offer);
    manager.navigateToEditOffer(context, offer);
  }
}
