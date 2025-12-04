import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:mukhlissmagasin/core/di/injection_container.dart';
import 'package:mukhlissmagasin/features/auth/presentation/cubit/auth_cubit.dart';

import 'package:mukhlissmagasin/features/auth/presentation/screens/login_screen.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart'
    show CaissierCubit;
import 'package:mukhlissmagasin/features/cashier/presentation/screens/caissier_home_screen.dart';
import 'package:mukhlissmagasin/features/language/domain/usecases/changeluanguage.dart';
import 'package:mukhlissmagasin/features/language/presentation/cubit/language_cubit.dart';
import 'package:mukhlissmagasin/features/offers/presentation/cubit/offer_cubit.dart';
import 'package:mukhlissmagasin/features/offers/presentation/screens/offers_screen.dart';

import 'package:mukhlissmagasin/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:mukhlissmagasin/features/profile/presentation/screens/profile_screen.dart';

import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_cubit.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/screens/rewards_screen.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';

// ✅ Imports pour le système d'abonnement
import 'package:mukhlissmagasin/core/guards/subscription_guard.dart';
import 'package:mukhlissmagasin/core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialiser Sentry pour monitoring
  await SentryFlutter.init(
    (options) {
      // ✅ DSN Sentry (même que Laravel - tout au même endroit!)
      options.dsn =
          'https://c2330142af6d1c0fcf8f2206cc345eb8@o4510465596325888.ingest.de.sentry.io/4510465604976720';

      // Capture 100% des transactions (bon pour commencer)
      options.tracesSampleRate = 1.0;

      // Environnement
      options.environment = 'production';

      // Activer breadcrumbs (contexte avant erreur)
      options.enableAutoPerformanceTracing = true;

      // Debug mode (désactiver en production)
      options.debug = true;

      // Nom de l'app
      options.release = 'mukhliss-merchant@1.0.0';
    },
    appRunner: () async {
      // Initialize dependencies
      await initDependencies();

      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider(
              create:
                  (context) => AuthCubit(
                    signUpUseCase: getIt(),
                    loginUseCase: getIt(),
                    repository: getIt(),
                  )..checkAuthStatus(),
            ),
            BlocProvider(
              create:
                  (context) => OfferCubit(
                    addOfferUseCase: getIt(),
                    getOffersUseCase: getIt(),
                    deleteOfferUseCase: getIt(),
                    updateOfferUseCase: getIt(),
                    getactivateofferUseCase: getIt(),
                  ),
            ),
            BlocProvider(
              create:
                  (context) => LanguageCubit(
                    getLocale: getIt<GetLocale>(),
                    saveLocale: getIt<SaveLocale>(),
                  ),
            ),
            BlocProvider(
              create:
                  (context) => RewardCubit(
                    getShopRewardsUseCase: getIt(),
                    addRewardUseCase: getIt(),
                    updateRewardUseCase: getIt(),
                    deleteRewardUseCase: getIt(),
                  ),
            ),
            BlocProvider(
              create:
                  (context) => CaissierCubit(
                    ajouterSolde: getIt(),
                    chargerRecompensesClient: getIt(),
                    reclamerRecompense: getIt(),
                    getCurrentMagazin: getIt(),
                    ajouterSoldeClientcode: getIt(),
                    getclientByuniquecode: getIt(),
                  ),
            ),
            BlocProvider(
              create:
                  (context) => ProfileCubit(
                    getIt(), // First parameter: UpdateUserUsecase
                    getIt(), // Second parameter: GetUserUsecase
                  ),
            ),
          ],
          child: const MyApp(),
        ),
      );
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp(
          title: 'Loyalty App',
          theme: ThemeData(
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: locale, // Utilisez la locale du cubit
          // ✅ Home protégé par SubscriptionGuard
          home: FutureBuilder<String?>(
            future: _getMagasinId(),
            builder: (context, snapshot) {
              // Chargement
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Erreur ou pas de magasin → Rediriger vers Login
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data == null) {
                // Retourner écran de login au lieu d'erreur
                return LoginScreen();
              }

              // ✅ Wrapper avec SubscriptionGuard
              return SubscriptionGuard(
                magasinId: snapshot.data!,
                child: const CaissierHomeScreen(),
              );
            },
          ),

          routes: {
            '/offers': (context) => const OffersScreen(),
            '/rewards': (context) => const RewardsScreen(),
            '/caissiers': (context) => const CaissierHomeScreen(),
            '/profile': (context) => ProfileScreen(),
            '/login': (context) => LoginScreen(),
          },
        );
      },
    );
  }

  /// Récupère l'ID du magasin de l'utilisateur connecté
  Future<String?> _getMagasinId() async {
    try {
      final user = SupabaseService.client.auth.currentUser;

      if (user == null) {
        print('❌ Aucun utilisateur connecté');
        return null;
      }

      // Récupérer le magasin associé à cet utilisateur
      // Adaptez cette requête selon votre structure de données
      final response =
          await SupabaseService.client
              .from('magasins')
              .select('id')
              .eq('id', user.id)
              .maybeSingle();

      if (response == null) {
        print('❌ Aucun magasin trouvé pour l\'utilisateur ${user.email}');
        return null;
      }

      final magasinId = response['id'] as String;
      print('✅ Magasin ID récupéré: $magasinId');
      return magasinId;
    } catch (e) {
      print('❌ Erreur récupération magasin: $e');
      return null;
    }
  }
}
