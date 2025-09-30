import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/core/widgets/app_drawer.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_state.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/recompenses_disponibles_screen.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/scan_client_screen.dart';
import 'package:mukhlissmagasin/features/profile/domain/entities/magasin_entity.dart';

import 'package:mukhlissmagasin/l10n/app_localizations.dart';


class CaissierHomeScreen extends StatefulWidget {
  const CaissierHomeScreen({Key? key}) : super(key: key);

  @override
  State<CaissierHomeScreen> createState() => _CaissierHomeScreenState();
}


class _CaissierHomeScreenState extends State<CaissierHomeScreen>  {
  final _montantController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
   @override
  void initState() {
    super.initState();
    // Charge le magasin au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaissierCubit>().getCurrentMagasin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildModernAppBar(context, l10n),
      drawer: const AppDrawer(),
      body: isTablet ? _buildTabletLayout(context) : _buildMobileLayout(context),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
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
              Icons.point_of_sale_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.espacecaisier,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
             
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80,
      leading: Builder(
        builder: (context) => Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
       
           
           
          ),
          child: IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF475569),size: 28,),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      
    );
  }



 Widget _buildTabletLayout(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(32.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colonne gauche - Stats et info
        Expanded(
          flex: 2,
          child: Column(
            children: [
              // Logo - taille naturelle
              _buildWelcomeSection(context),
              const SizedBox(height: 24),
              // Section aide - prend TOUT l'espace restant
              Expanded(
                child: _buildHelpSection(context),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Colonne droite - Actions principales
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: _buildMainActionsGrid(context),
          ),
        ),
      ],
    ),
  );
}


Widget _buildMobileLayout(BuildContext context) {
  return SingleChildScrollView(  // Garde le défilement pour mobile
    padding: const EdgeInsets.all(20.0),
    child: Column(
      children: [
        _buildWelcomeSection(context),
        const SizedBox(height: 24),
        _buildMainActionsGrid(context),
        const SizedBox(height: 24),
        _buildHelpSection(context),
      ],
    ),
  );
}

Widget _buildWelcomeSection(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return BlocBuilder<CaissierCubit, CaissierState>(
    builder: (context, state) {
      MagasinModel? currentMagasin;
      bool isLoading = false;
      
      if (state is CurrentMagasinLoaded) {
        currentMagasin = state.magasin;
      } else if (state is CaissierLoading) {
        isLoading = true;
      }
      
      return Container(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important!
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: _buildModernLogoSection(currentMagasin, isLoading),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildModernLogoSection(MagasinModel? magasin, bool isLoading) {
  return Container(
    width: double.infinity,
    child: Column(
      mainAxisSize: MainAxisSize.min, // Important!
      children: [
        if (isLoading) 
          const CircularProgressIndicator()
        else if (magasin != null)
          _buildModernLogo(magasin)
        else
          const Icon(
            Icons.storefront_rounded,
            size: 100,
            color: Colors.grey,
          ),
      ],
    ),
  );
}

Widget _buildModernLogo(MagasinModel magasin) {
  final logoUrl = magasin.imageUrl;
  
  return LayoutBuilder(
    builder: (context, constraints) {
      // Calcule une hauteur adaptative basée sur l'espace disponible
      final maxHeight = constraints.maxHeight > 0 
          ? constraints.maxHeight.clamp(150.0, 250.0) 
          : 200.0;
      
      return Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100), // Rendre circulaire
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipOval( // Utiliser ClipOval au lieu de ClipRRect pour un cercle parfait
          child: Image.network(
            logoUrl,
            width: 200,
            height: maxHeight,
            fit: BoxFit.cover, // Conserver BoxFit.cover pour bien remplir le cercle
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[100],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
  Widget _buildMainActionsGrid(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.actionprincipale,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 24),
        _buildAddBalanceCard(context),
        const SizedBox(height: 24),
        _buildRewardsCard(context),
      ],
    );
  }

  Widget _buildAddBalanceCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF10B981), const Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_card_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.ajoutersolde,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.rechargezcompte,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _montantController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.montantajouter,
                      labelStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: '0.00',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(20),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFF10B981), const Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.monetization_on_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      suffixText: 'DH',
                      suffixStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_rounded, size: 20, color: Colors.blue[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.scanerajoutermontant,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleAddBalance(context),
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 28),
                label: Text(
                  l10n.scannercleint,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: const Color(0xFF10B981).withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.gererrecompence,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.aidezclientconsulterrecompence,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars_rounded, size: 24, color: Colors.purple[600]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.scannerrecompence,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _handleViewRewards(context),
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 28),
                label: Text(
                  l10n.scannerrecompenceqr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: const Color(0xFF8B5CF6).withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildHelpSection(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Container(
    height: double.infinity, // Prend toute la hauteur disponible
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey[100]!),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.help_outline_rounded, 
                  color: Colors.blue[600], 
                  size: 18
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.commentmarche,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHelpStep(
            number: '1',
            title: l10n.ajoutersolde,
            description: l10n.scanerajoutermontant,
          ),
          const SizedBox(height: 10),
          _buildHelpStep(
            number: '2',
            title: l10n.gererrecompence,
            description: l10n.scannerrecompence,
          ),
          const SizedBox(height: 10),
          _buildHelpStep(
            number: '3',
            title: l10n.validation,
            description: l10n.confiremeztransaction,
          ),
        ],
      ),
    ),
  );
}

 Widget _buildHelpStep({
  required String number,
  required String title,
  required String description,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[600]!, Colors.blue[500]!],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

  Future<void> _handleAddBalance(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final montantTxt = _montantController.text.replaceAll(',', '.');
    final montant = double.tryParse(montantTxt);

    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text(l10n.veuillez),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ScanClientScreen.balance(montant),
      ),
    );

    if (success == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text(l10n.soldede + '${montant.toStringAsFixed(2)}' + l10n.dhajoute),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      _montantController.clear();
    }
  }

  Future<void> _handleViewRewards(BuildContext context) async {
    final data = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const ScanClientScreen.rewards()),
    );

    if (data != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RewardSelectionScreen(
            clientId: data['clientId']!,
            magasinId: data['magasinId']!,
            clientPoints: int.parse(data['clientPoints']!),
          ),
        ),
      );
    }
  }
}