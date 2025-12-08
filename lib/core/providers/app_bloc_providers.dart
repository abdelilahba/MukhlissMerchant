/// Configuration centralisée des BlocProviders.
///
/// Sépare la configuration des Cubits du fichier main.dart
/// pour une meilleure organisation et maintenabilité.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Imports Cubits
import 'package:mukhlissmagasin/core/di/injection_container.dart';
import 'package:mukhlissmagasin/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart';
import 'package:mukhlissmagasin/features/language/domain/usecases/changeluanguage.dart';
import 'package:mukhlissmagasin/features/language/presentation/cubit/language_cubit.dart';
import 'package:mukhlissmagasin/features/offers/presentation/cubit/offer_cubit.dart';
import 'package:mukhlissmagasin/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_cubit.dart';

/// Fournit tous les BlocProviders de l'application.
///
/// Centralise la création et configuration des Cubits
/// pour faciliter la maintenance.
///
/// ### Exemple d'utilisation:
/// ```dart
/// runApp(
///   AppBlocProviders.wrap(
///     child: MyApp(),
///   ),
/// );
/// ```
class AppBlocProviders {
  // Private constructor - classe utilitaire
  AppBlocProviders._();

  /// Wrape un widget avec tous les BlocProviders nécessaires.
  ///
  /// [child] - Widget enfant à wrapper (généralement MyApp)
  ///
  /// Returns: MultiBlocProvider contenant tous les Cubits
  static Widget wrap({required Widget child}) {
    return MultiBlocProvider(
      providers: _providers,
      child: child,
    );
  }

  /// Liste de tous les BlocProviders de l'application.
  static List<BlocProvider> get _providers => [
        // ═══════════════════════════════════════════════════════════
        // AUTH CUBIT
        // Gestion authentification utilisateur
        // ═══════════════════════════════════════════════════════════
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            signUpUseCase: getIt(),
            loginUseCase: getIt(),
            repository: getIt(),
          )..checkAuthStatus(),
        ),

        // ═══════════════════════════════════════════════════════════
        // OFFER CUBIT
        // Gestion des offres promotionnelles
        // ═══════════════════════════════════════════════════════════
        BlocProvider<OfferCubit>(
          create: (context) => OfferCubit(
            addOfferUseCase: getIt(),
            getOffersUseCase: getIt(),
            deleteOfferUseCase: getIt(),
            updateOfferUseCase: getIt(),
            getactivateofferUseCase: getIt(),
          ),
        ),

        // ═══════════════════════════════════════════════════════════
        // LANGUAGE CUBIT
        // Gestion de la localisation (FR, AR, EN)
        // ═══════════════════════════════════════════════════════════
        BlocProvider<LanguageCubit>(
          create: (context) => LanguageCubit(
            getLocale: getIt<GetLocale>(),
            saveLocale: getIt<SaveLocale>(),
          ),
        ),

        // ═══════════════════════════════════════════════════════════
        // REWARD CUBIT
        // Gestion des récompenses du programme de fidélité
        // ═══════════════════════════════════════════════════════════
        BlocProvider<RewardCubit>(
          create: (context) => RewardCubit(
            getShopRewardsUseCase: getIt(),
            addRewardUseCase: getIt(),
            updateRewardUseCase: getIt(),
            deleteRewardUseCase: getIt(),
          ),
        ),

        // ═══════════════════════════════════════════════════════════
        // CAISSIER CUBIT
        // Gestion des opérations caissier (solde, récompenses)
        // ═══════════════════════════════════════════════════════════
        BlocProvider<CaissierCubit>(
          create: (context) => CaissierCubit(
            ajouterSolde: getIt(),
            chargerRecompensesClient: getIt(),
            reclamerRecompense: getIt(),
            getCurrentMagazin: getIt(),
            ajouterSoldeClientcode: getIt(),
            getclientByuniquecode: getIt(),
          ),
        ),

        // ═══════════════════════════════════════════════════════════
        // PROFILE CUBIT
        // Gestion du profil utilisateur/magasin
        // ═══════════════════════════════════════════════════════════
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            getIt(), // UpdateUserUsecase
            getIt(), // GetUserUsecase
          ),
        ),
      ];
}
