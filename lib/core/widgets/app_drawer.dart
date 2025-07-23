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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
           DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Text(
             l10n.menuprincipale,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title:  Text(l10n.acceuil),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OffersScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_offer),
            title:  Text(l10n.offre),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OffersScreen()),
              );
            },
          ),
           ListTile(
            leading: const Icon(Icons.card_giftcard),
            title:  Text(l10n.recompences),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => RewardsScreen(),
                ),
              );
            },
          ),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title:  Text(l10n.caissier),
            onTap: () {
               Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CaissierHomeScreen(),
                ),
              );
            },
          ),
          //parametre
                 ListTile(
            leading: const Icon(Icons.settings),
            title:  Text(l10n.setting),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ParametreScreen(),
                ),
              );
            },
          ),
          // Ajout du bouton de déconnexion
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) =>  LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title:  Text(l10n.deconnexion, style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthCubit>().logout();
              },
            ),
          ),
        ],
      ),
    );
  }
}