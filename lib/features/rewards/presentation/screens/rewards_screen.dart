import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/core/widgets/app_drawer.dart';
import 'package:mukhlissmagasin/core/widgets/reward_card.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_cubit.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_state.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/managers/reward_manager.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';


class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
 String _searchQuery = '';
   bool _isGridView = true;
   String _selectedFilter = 'all'; 
   // all, active, expired
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    final manager = RewardManager(context.read<RewardCubit>());
    manager.loadRewards();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AppDrawer(),
       floatingActionButton: FloatingActionButton(
      onPressed: () => manager.navigateToAddReward(context),
      backgroundColor: Colors.blue.shade600,
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    ),
      body: Row(
        children: [
          // Sidebar pour tablette
          _buildSidebar(context, manager),
          // Contenu principal
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, manager),
                const SizedBox(height: 20),
                Expanded(child: _buildBody(context, manager)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, RewardManager manager) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec gradient
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade600,
                  Colors.purple.shade500,
                  Colors.pink.shade400,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.recompences,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.trouvermeilleur,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //option d afichage
                  Text(
                   l10n.optionaffichage ,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 10,),
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
                  SizedBox(height:16 ,),
                  // Filtres
                
                  const SizedBox(height: 16),
                           BlocBuilder<RewardCubit, RewardState>(
                    builder: (context, state) {
                      if (state is RewardsLoaded) {
                        return _buildStats(context, state.rewards);
                      }
                      return const SizedBox();
                    },
                  ),
                   const SizedBox(height: 32),
                    Text(
                  l10n.navigation  ,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                     const SizedBox(height: 10),
                 _buildMenuItem(
                    icon: Icons.dashboard_outlined,
                    title: l10n.tableaubord ,
                    onTap: () {
                      // Navigation vers le dashboard
                    },
                  ),
                  _buildFilterChip(l10n.tous, 'all'),
                  const SizedBox(height: 8),
                  _buildFilterChip(l10n.activee, 'active'),
                
                  const SizedBox(height: 32),
                  
                  // Actions rapides
                  
                  Text(
                  l10n.actionrapide  ,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                   Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => manager.navigateToAddReward(context),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.creerecompence),
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
                    onPressed: () =>manager.loadRewards(),
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


  Widget _buildFilterChip(String title, String value) {
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.blue.shade600 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, List<dynamic> rewards) {
    final L10n=AppLocalizations.of(context);
    final activereward=rewards.where((reward)=>reward.isActive).length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
               L10n.statistique ,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow(L10n.totalrecompence, '${rewards.length}'),
          const SizedBox(height: 8),
          _buildStatRow(L10n.activee, '${activereward}'), // À ajuster selon votre logique
          
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

 

Widget _buildTopBar(BuildContext context, RewardManager manager) {
  final l10n = AppLocalizations.of(context);
  
  return Container(
    height: 120,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // Bouton du menu
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        const SizedBox(width: 12),
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[400]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 10,),
        // Titre "Récompenses"
        Text(
        l10n.gestionrecompences ,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 16),
        
        // Barre de recherche
        Expanded(
  child: Align(
    alignment: Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 300), // Largeur réduite à 80
      child: Container(
        height: 36, // Hauteur légèrement réduite
        decoration: BoxDecoration(
          color:  Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: l10n.recherchereward,
            hintStyle: TextStyle(fontSize: 15), // Texte plus petit
            prefixIcon: Icon(Icons.search, 
                           color: Colors.grey.shade500,
                           size: 18), // Icône plus petite
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, // Padding horizontal réduit
              vertical: 12,   // Padding vertical réduit
            ),
            isDense: true, // Réduit l'espace interne
          ),
          style: TextStyle(fontSize: 12), // Texte de saisie plus petit
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
    ),
  ),
),
      ],
    ),
  );
}


  Widget _buildBody(BuildContext context, RewardManager manager) {
    return BlocBuilder<RewardCubit, RewardState>(
      builder: (context, state) {
        if (state is RewardLoading) {
          return _buildLoadingState(context);
        }

        if (state is RewardError) {
          return _buildErrorState(state.message);
        }

        if (state is RewardsLoaded) {
          if (state.rewards.isEmpty) {
            return _buildEmptyState(context, manager);
          }
          return CustomScrollView(  // Add this
          slivers: [
            _isGridView 
              ? _buildRewardsGrid(state, manager, context)
              : _buildRewardsList(state, context, manager),
          ],
        );
         
        }

        return const SizedBox();
        
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final L10n=AppLocalizations.of(context);
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                   L10n.chargementdesrecompences ,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final L10n=AppLocalizations.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFDC2626),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
             Text(
             L10n.oups ,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, RewardManager manager) {
    final l10n = AppLocalizations.of(context);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(40),
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
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
                    Icons.card_giftcard_rounded,
                    size: 64,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                 Text(
                 l10n.aucunerecompence ,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                 l10n.commencezparcreerecompence ,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => manager.navigateToAddReward(context),
                  icon: const Icon(Icons.add_rounded, size: 24),
                  label:  Text(
                  l10n.creerecompence  ,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _buildRewardsGrid(RewardsLoaded state, RewardManager manager, BuildContext context) {
  AppLocalizations.of(context);
  
  List<dynamic> filteredRewards = state.rewards.where((reward) {
    // Filtre par statut (nouveau)
    bool statusMatch = true;
    if (_selectedFilter == 'active') {
      statusMatch = reward.isActive == true;
    } else if (_selectedFilter == 'inactive') {
      statusMatch = reward.isActive == false;
    }
    // Si _selectedFilter == 'all', on affiche tout (statusMatch reste true)
    
    // Filtre par recherche (existant)
    bool searchMatch = true;
    if (_searchQuery.isNotEmpty) {
      final nameMatch = reward.name.toLowerCase().contains(_searchQuery.toLowerCase());
      bool pointsMatch = false;
      final points = int.tryParse(_searchQuery);
      if (points != null) {
        pointsMatch = reward.requiredPoints == points;
      }
      searchMatch = nameMatch || pointsMatch;
    }
    
    return statusMatch && searchMatch;
  }).toList();

  // Si aucune récompense ne correspond aux filtres
  if (filteredRewards.isEmpty) {
    return SliverFillRemaining(
      child: _buildNoResultsState(context, manager),
    );
  }

  return SliverPadding(
    padding: const EdgeInsets.all(16),
    sliver: SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1400 ? 3 : 
                       MediaQuery.of(context).size.width > 900 ? 2 : 1,
        childAspectRatio: MediaQuery.of(context).size.width > 900 ? 3.5 : 3.0,
        crossAxisSpacing: 20,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final reward = filteredRewards[index];
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: 30,
                          maxHeight: 60,
                        ),
                        child: RewardCard(
                          reward: reward,
                          onTap: () => manager.showRewardDetail(reward),
                          onDelete: () => _showDeleteDialog(context, manager, reward.id),
                          onEdit: () => manager.navigateToEditReward(context, reward),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        childCount: filteredRewards.length,
      ),
    ),
  );
}

Widget _buildNoResultsState(BuildContext context, RewardManager manager) {
  AppLocalizations.of(context);
  
  return Center(
    child: Container(
      margin: const EdgeInsets.all(40),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade100,
                  Colors.red.shade100,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 50,
              color: Colors.orange.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Aucun résultat trouvé",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedFilter == 'active' 
              ? "Aucune récompense active ne correspond à votre recherche"
              : _selectedFilter == 'inactive'
                ? "Aucune récompense inactive ne correspond à votre recherche"
                : "Aucune récompense ne correspond à votre recherche",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedFilter = 'all';
                  });
                },
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text("Effacer filtres"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => manager.navigateToAddReward(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text("Créer récompense"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
 Widget _buildRewardsList(RewardsLoaded state, BuildContext context, RewardManager manager) {
  List<dynamic> filteredRewards = state.rewards.where((reward) {
    // Filtre par statut (nouveau)
    bool statusMatch = true;
    if (_selectedFilter == 'active') {
      statusMatch = reward.isActive == true;
    } else if (_selectedFilter == 'inactive') {
      statusMatch = reward.isActive == false;
    }
    
    // Filtre par recherche (existant)
    bool searchMatch = true;
    if (_searchQuery.isNotEmpty) {
      final nameMatch = reward.name.toLowerCase().contains(_searchQuery.toLowerCase());
      bool pointsMatch = false;
      final points = int.tryParse(_searchQuery);
      if (points != null) {
        pointsMatch = reward.requiredPoints == points;
      }
      searchMatch = nameMatch || pointsMatch;
    }
    
    return statusMatch && searchMatch;
  }).toList();

  // Si aucune récompense ne correspond aux filtres
  if (filteredRewards.isEmpty) {
    return SliverFillRemaining(
      child: _buildNoResultsState(context, manager),
    );
  }

  return SliverPadding(
    padding: const EdgeInsets.all(16),
    sliver: SliverList(
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
                            child: RewardCard(
                              reward: filteredRewards[index],
                              onTap: () => manager.showRewardDetail(filteredRewards[index]),
                              onDelete: () => _showDeleteDialog(context, manager, filteredRewards[index].id),
                              onEdit: () => manager.navigateToEditReward(context, filteredRewards[index]),
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
        childCount: filteredRewards.length,
      ),
    ),
  );
}
  void _showDeleteDialog(BuildContext context, RewardManager manager, String id) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.supprimerrecompence,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.etesvoussurdesupprimerrecompense,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        l10n.annuler,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        manager.deleteReward(id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.supprimer,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}