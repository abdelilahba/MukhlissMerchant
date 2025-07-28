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
    final l10n = AppLocalizations.of(context)!;
  
    
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
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
            // Header moderne avec gradient
            _buildModernHeader(context, l10n),
            
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildMenuSection(
                    title: l10n.navigation,
                    items: [
                      _MenuItemData(
                        icon: Icons.local_offer_rounded,
                        title: l10n.offre,
                        color: Colors.orange,
                        onTap: () => _navigateTo(context, const OffersScreen()),
                      ),
                      _MenuItemData(
                        icon: Icons.card_giftcard_rounded,
                        title: l10n.recompences,
                        color: Colors.purple,
                        onTap: () => _navigateTo(context, RewardsScreen()),
                      ),
                      _MenuItemData(
                        icon: Icons.point_of_sale_rounded,
                        title: l10n.caissier,
                        color: Colors.green,
                        onTap: () => _navigateTo(context, CaissierHomeScreen()),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildMenuSection(
                    title:l10n.setting ,
                    items: [
                      _MenuItemData(
                        icon: Icons.settings_rounded,
                        title: l10n.setting,
                        color: Colors.blue,
                        onTap: () => _navigateTo(context, ParametreScreen()),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
            
            // Bouton de déconnexion en bas
            _buildLogoutSection(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple,
            Colors.deepPurple.shade700,
            Colors.purple.shade600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo ou icône de l'app
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.store_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              
              // Titre
              Flexible(
                child: Text(
                  l10n.menuprincipale,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Sous-titre
              Text(
                'Mukhliss Magasin',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItemData> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items.map((item) => _buildModernListTile(item)),
      ],
    );
  }

  Widget _buildModernListTile(_MenuItemData item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            item.icon,
            color: item.color,
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey.shade400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: item.onTap,
        hoverColor: item.color.withOpacity(0.05),
        focusColor: item.color.withOpacity(0.1),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.shade200,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            title: Text(
              l10n.deconnexion,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.red,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(l10n.confirmation),
            ],
          ),
          content: Text(
          l10n.etevoussur ,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
               l10n.annuler ,
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
                '/login', // Route de votre page de login
                (Route<dynamic> route) => false, // Supprime toutes les routes
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

class _MenuItemData {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}
