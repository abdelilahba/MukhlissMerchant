/// Widget principal de l'application Mukhliss Merchant.
///
/// Configure le MaterialApp avec:
/// - Thème
/// - Localisation (FR, AR, EN)
/// - Routes
/// - Protection par abonnement
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports
import 'package:mukhlissmagasin/core/config/app_config.dart';
import 'package:mukhlissmagasin/core/guards/subscription_guard.dart';
import 'package:mukhlissmagasin/core/services/magasin_service.dart';

// Feature imports - Screens
import 'package:mukhlissmagasin/features/auth/presentation/screens/login_screen.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/screens/caissier_home_screen.dart';
import 'package:mukhlissmagasin/features/offers/presentation/screens/offers_screen.dart';
import 'package:mukhlissmagasin/features/profile/presentation/screens/profile_screen.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/screens/rewards_screen.dart';

// Feature imports - Cubits
import 'package:mukhlissmagasin/features/language/presentation/cubit/language_cubit.dart';

// Localization
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

/// Widget racine de l'application.
///
/// Gère:
/// - Configuration MaterialApp
/// - Thème et apparence
/// - Localisation multi-langue
/// - Routes et navigation
/// - Protection par abonnement
class MukhlissApp extends StatelessWidget {
  /// Crée une instance de [MukhlissApp].
  const MukhlissApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp(
          // ═══════════════════════════════════════════════════
          // APP INFO
          // ═══════════════════════════════════════════════════
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,

          // ═══════════════════════════════════════════════════
          // THEME
          // ═══════════════════════════════════════════════════
          theme: _buildTheme(),

          // ═══════════════════════════════════════════════════
          // LOCALIZATION
          // ═══════════════════════════════════════════════════
          supportedLocales: _supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: locale,

          // ═══════════════════════════════════════════════════
          // HOME (avec protection abonnement)
          // ═══════════════════════════════════════════════════
          home: const _AppHome(),

          // ═══════════════════════════════════════════════════
          // ROUTES
          // ═══════════════════════════════════════════════════
          routes: _routes,
        );
      },
    );
  }

  /// Construit le thème de l'application.
  ThemeData _buildTheme() {
    return ThemeData(
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppColors.primaryValue),
      ),
      useMaterial3: true,

      // Personnalisations additionnelles
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.defaultRadius),
          ),
        ),
      ),
    );
  }

  /// Liste des locales supportées.
  static const List<Locale> _supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
  ];

  /// Map des routes de l'application.
  static Map<String, WidgetBuilder> get _routes => {
        AppStrings.routeOffers: (context) => const OffersScreen(),
        AppStrings.routeRewards: (context) => const RewardsScreen(),
        AppStrings.routeCaissiers: (context) => const CaissierHomeScreen(),
        AppStrings.routeProfile: (context) => ProfileScreen(),
        AppStrings.routeLogin: (context) => LoginScreen(),
      };
}

/// Widget Home avec logique de chargement et protection.
///
/// Gère:
/// - Chargement du magasin ID
/// - Redirection vers login si non connecté
/// - Protection par SubscriptionGuard
class _AppHome extends StatelessWidget {
  const _AppHome();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: MagasinService.getCurrentMagasinId(),
      builder: (context, snapshot) {
        // ═══════════════════════════════════════════════════
        // LOADING STATE
        // ═══════════════════════════════════════════════════
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        // ═══════════════════════════════════════════════════
        // ERROR / NO MAGASIN → LOGIN
        // ═══════════════════════════════════════════════════
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return LoginScreen();
        }

        // ═══════════════════════════════════════════════════
        // SUCCESS → PROTECTED HOME
        // ═══════════════════════════════════════════════════
        return SubscriptionGuardModern(
          magasinId: snapshot.data!,
          child: const CaissierHomeScreen(),
        );
      },
    );
  }
}

/// Écran de chargement pendant l'initialisation.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou icône app
            const Icon(
              Icons.storefront,
              size: 64,
              color: Color(AppColors.primaryValue),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
