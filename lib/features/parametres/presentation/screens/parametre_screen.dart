import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/features/language/presentation/cubit/language_cubit.dart';
import 'package:mukhlissmagasin/features/language/presentation/screens/language_selector.dart';
import 'package:mukhlissmagasin/features/offers/presentation/screens/offers_screen.dart';
import 'package:mukhlissmagasin/features/profile/presentation/screens/profile_screen.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';


class ParametreScreen extends StatefulWidget {
  
  const ParametreScreen({super.key});

  @override
 State<ParametreScreen> createState() => _ParametreScreenState();
}

class _ParametreScreenState extends State<ParametreScreen> {
  
   @override
  void initState() {
    super.initState();
    // Initialize with the current locale
   
  }
  

  @override
  Widget build(BuildContext context) {
     final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
       l10n.setting,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
          onPressed: () {
      // Navigation vers OffersScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OffersScreen()),
      );
    },
        ),
       
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec avatar et nom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // CircleAvatar(
                  //   radius: 40,
                  //   backgroundColor: Colors.blue[100],
                  //   child: Icon(
                  //     Icons.person,
                  //     size: 40,
                  //     color: Colors.blue[600],
                  //   ),
                  // ),
                  const SizedBox(height: 12),
                  Text(
                    "Mukhlis Magasin",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                  l10n.gerervospreference ,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section Général
            _buildSection(
              title:l10n.general ,
              children: [
               _buildSettingsTile(
                  icon: Icons.language,
                  title: l10n.langue,
                  subtitle: context.watch<LanguageCubit>().state.languageCode.toUpperCase(),
                  onTap: () => _showLanguageDialog(context),
                  color: Colors.blue,
                  ),
        
           
              ],
            ),

            const SizedBox(height: 24),

            // Section Compte
            _buildSection(
              title: l10n.compte,
              children: [
                _buildSettingsTile(
                  icon: Icons.person,
                  title:l10n.profil ,
                  subtitle:l10n.informationpers ,
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) =>  ProfileScreen()),
  );
},
                  color: Colors.green,
                ),
                _buildSettingsTile(
                  icon: Icons.security,
                  title:l10n.securite ,
                  subtitle:l10n.motpassesecurise ,
                  onTap: () {},
                  color: Colors.red,
                ),
                _buildSettingsTile(
                  icon: Icons.privacy_tip,
                  title:l10n.confidentialite ,
                  subtitle:l10n.paramconfidentialite ,
                  onTap: () {},
                  color: Colors.teal,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section Support
            _buildSection(
              title: "Support",
              children: [
                _buildSettingsTile(
                  icon: Icons.help,
                  title: "Aide",
                  subtitle: "FAQ et support",
                  onTap: () {},
                  color: Colors.indigo,
                ),
                _buildSettingsTile(
                  icon: Icons.info,
                  title: "À propos",
                  subtitle: "Version et informations",
                  onTap: () {},
                  color: Colors.grey,
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }


  


void _showLanguageDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => LanguageSelector(),
  );
}







}
