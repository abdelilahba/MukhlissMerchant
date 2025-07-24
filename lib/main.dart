import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/core/di/injection_container.dart';
import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mukhlissmagasin/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:mukhlissmagasin/features/auth/presentation/screens/login_screen.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart' show CaissierCubit;
import 'package:mukhlissmagasin/features/cashier/presentation/screens/caissier_home_screen.dart';
import 'package:mukhlissmagasin/features/language/domain/usecases/changeluanguage.dart';
import 'package:mukhlissmagasin/features/language/presentation/cubit/language_cubit.dart';
import 'package:mukhlissmagasin/features/offers/domain/usecases/edit_offer_usecase.dart';
import 'package:mukhlissmagasin/features/offers/presentation/cubit/offer_cubit.dart';
import 'package:mukhlissmagasin/features/offers/presentation/screens/offers_screen.dart';
import 'package:mukhlissmagasin/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:mukhlissmagasin/features/profile/data/repositories/user_repository_impl.dart';
import 'package:mukhlissmagasin/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:mukhlissmagasin/features/profile/presentation/screens/profile_screen.dart';

import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_cubit.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/screens/rewards_screen.dart';
import 'package:mukhlissmagasin/l10n/app_localizations.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(
                signUpUseCase: getIt(),
                loginUseCase: getIt(),
                repository: getIt(),
              )..checkAuthStatus(),
        ),
        BlocProvider(
          create: (context) => OfferCubit(
                addOfferUseCase: getIt(),
                getOffersUseCase: getIt(),
                deleteOfferUseCase: getIt(),
                updateOfferUseCase: getIt(),
              ),
        ),
      BlocProvider(
    create: (context) => LanguageCubit(
    getLocale: getIt<GetLocale>(),  // Notez le camelCase et le type explicite
    saveLocale: getIt<SaveLocale>(),
      ),
      ),
        BlocProvider(
          create: (context) => RewardCubit(
                getShopRewardsUseCase: getIt(),
                addRewardUseCase: getIt(),
                updateRewardUseCase: getIt(),
                deleteRewardUseCase: getIt(),
              ),
        ),
          BlocProvider(
          create: (context) => CaissierCubit(
            ajouterSolde: getIt(),
            chargerRecompensesClient: getIt(),
            reclamerRecompense: getIt(),
          ),
        ),
     BlocProvider(
  create: (context) => ProfileCubit(
    getIt(),  // First parameter: UpdateUserUsecase
    getIt(),     // Second parameter: GetUserUsecase
  ),
)  ,
 //
      ],
      child: const MyApp(),
    ),
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
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
            Locale('ar'),
          ],
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: locale, // Utilisez la locale du cubit
          home: const AuthWrapper(),
          routes: {
            '/offers': (context) => const OffersScreen(),
            '/rewards': (context) => const RewardsScreen(),
            '/caissiers': (context) => CaissierHomeScreen(),
            '/profile':(context)=> ProfileScreen(),
            '/login' :(context)=>LoginScreen(),
          },
        );
      },
    );
  }
}
