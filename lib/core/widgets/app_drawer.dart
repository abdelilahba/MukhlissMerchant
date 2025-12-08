import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mukhlissmagasin/features/auth/presentation/cubit/auth_state.dart';
import 'package:mukhlissmagasin/features/auth/presentation/screens/login_screen.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/caissier_home_screen.dart';
import 'package:mukhlissmagasin/features/offers/presentation/screens/offers_screen.dart';
import 'package:mukhlissmagasin/features/parametres/presentation/screens/parametre_screen.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/screens/rewards_screen.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);    
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.65,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header compact
            _buildModernHeader(context, l10n),
            
            // Menu items - SANS ListView, directement dans Column
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Section Navigation
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          child: Text(
                            l10n.navigation,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        _buildCompactListTile(
                          icon: Icons.local_offer_rounded,
                          title: l10n.offre,
                          color: Colors.orange,
                          onTap: () => _navigateTo(context, const OffersScreen()),
                        ),
                        _buildCompactListTile(
                          icon: Icons.card_giftcard_rounded,
                          title: l10n.recompences,
                          color: Colors.purple,
                          onTap: () => _navigateTo(context, RewardsScreen()),
                        ),
                        _buildCompactListTile(
                          icon: Icons.point_of_sale_rounded,
                          title: l10n.caissier,
                          color: Colors.green,
                          onTap: () => _navigateTo(context, CaissierHomeScreen()),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Section Paramètres
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          child: Text(
                            l10n.setting,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        _buildCompactListTile(
                          icon: Icons.settings_rounded,
                          title: l10n.setting,
                          color: Colors.blue,
                          onTap: () => _navigateTo(context, ParametreScreen()),
                        ),
                      ],
                    ),
                    
                    // Section Déconnexion en bas
                    _buildLogoutSection(context, l10n),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 140, // Réduit pour plus d'espace au contenu
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.shade800,
            Colors.deepPurple.shade600,
            Colors.purple.shade500,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo compact
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              
              // Textes
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.menuprincipale,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mukhliss Magasin',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactListTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        minVerticalPadding: 0,
        visualDensity: VisualDensity.compact, // Réduit l'espacement
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.grey.shade400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 60),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.red.shade200,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            minVerticalPadding: 0,
            visualDensity: VisualDensity.compact,
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
            title: Text(
              l10n.deconnexion,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.red,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(l10n.confirmation),
            ],
          ),
          content: Text(
            l10n.etevoussur,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.annuler,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthCubit>().logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.deconnexion,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }
}

