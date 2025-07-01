import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/core/di/injection_container.dart';
import 'package:mukhlissmagasin/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mukhlissmagasin/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart' show CaissierCubit;
import 'package:mukhlissmagasin/features/cashier/presentation/screens/caissier_home_screen.dart';
import 'package:mukhlissmagasin/features/offers/presentation/cubit/offer_cubit.dart';
import 'package:mukhlissmagasin/features/offers/presentation/screens/offers_screen.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_cubit.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/screens/rewards_screen.dart';

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
            chargerOffresClient: getIt(),
            echangerOffre: getIt(),

            chargerRecompensesClient: getIt(),
            reclamerRecompense: getIt(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      title: 'Loyalty App',
      theme: ThemeData(
            fontFamily: 'Poppins', // Default font

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/offers': (context) => const OffersScreen(),
        '/rewards': (context) => const RewardsScreen(), // À adapter
        '/caissiers': (context) =>  CaissierHomeScreen(), // À adapter
      },
    );
  }
}