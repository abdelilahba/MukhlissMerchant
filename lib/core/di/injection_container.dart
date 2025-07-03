// injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:mukhlissmagasin/core/services/supabase_service.dart';
import 'package:mukhlissmagasin/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mukhlissmagasin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mukhlissmagasin/features/auth/domain/repositories/auth_repository.dart';
import 'package:mukhlissmagasin/features/auth/domain/usecases/login_usecase.dart';
import 'package:mukhlissmagasin/features/auth/domain/usecases/signup_usecase.dart';
import 'package:mukhlissmagasin/features/cashier/data/datasources/caissier_remote_data_source.dart';
import 'package:mukhlissmagasin/features/cashier/data/repositories/caissier_repository_impl.dart';
import 'package:mukhlissmagasin/features/cashier/domain/repositories/caissier_repository.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/ajouter_solde.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/charger_recompenses_usecase.dart';
import 'package:mukhlissmagasin/features/cashier/domain/usecases/reclamer_recompense_usecase.dart';
import 'package:mukhlissmagasin/features/cashier/presentation/cubit/caissier_cubit.dart';
import 'package:mukhlissmagasin/features/offers/data/datasources/offer_remote_data_source.dart';
import 'package:mukhlissmagasin/features/offers/data/repositories/offer_repository_impl.dart';
import 'package:mukhlissmagasin/features/offers/domain/repositories/offer_repository.dart';
import 'package:mukhlissmagasin/features/offers/domain/usecases/add_offer_usecase.dart';
import 'package:mukhlissmagasin/features/offers/domain/usecases/delete_offer_usecase.dart';
import 'package:mukhlissmagasin/features/offers/domain/usecases/edit_offer_usecase.dart';
import 'package:mukhlissmagasin/features/offers/domain/usecases/get_offers_usecase.dart';
import 'package:mukhlissmagasin/features/rewards/data/datasources/reward_remote_data_source.dart';
import 'package:mukhlissmagasin/features/rewards/data/repositories/reward_repository_impl.dart';
import 'package:mukhlissmagasin/features/rewards/domain/repositories/reward_repository.dart';
import 'package:mukhlissmagasin/features/rewards/domain/usecases/add_shop_reward_usecase.dart';
import 'package:mukhlissmagasin/features/rewards/domain/usecases/delete_shop_reward_usecase.dart';
import 'package:mukhlissmagasin/features/rewards/domain/usecases/get_shop_rewards_usecase.dart';
import 'package:mukhlissmagasin/features/rewards/domain/usecases/update_shop_reward_usecase.dart';
import 'package:mukhlissmagasin/features/rewards/presentation/cubit/reward_cubit.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Initialize Supabase
  await SupabaseService.initialize();

  // Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt()),
  );
  
  getIt.registerLazySingleton(() => SignUpUseCase(getIt()));
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));

  // Offers
  getIt.registerLazySingleton<OfferRemoteDataSource>(
    () => OfferRemoteDataSource(),
  );
  
  getIt.registerLazySingleton<OfferRepository>(
    () => OfferRepositoryImpl(
      remoteDataSource: getIt(),
      authRepository: getIt(),
    ),
  );
  
  getIt.registerLazySingleton(() => AddOfferUseCase(
    repository: getIt(),
    authRepository: getIt(),
  ));

    getIt.registerLazySingleton(() => UpdateOfferUseCase(
    repository: getIt(),
    authRepository: getIt(),
  ));
   getIt.registerLazySingleton(() => DeleteOfferUseCase(
    repository: getIt(),
    authRepository: getIt(),
  )); 
  getIt.registerLazySingleton(() => GetOffersUseCase(repository: getIt()));

  // Rewards
  getIt.registerLazySingleton<RewardRemoteDataSource>(
    () => RewardRemoteDataSource(), // Assurez-vous d'avoir implémenté cette classe
  );
  
  getIt.registerLazySingleton<RewardRepository>(
    () => RewardRepositoryImpl(
      remoteDataSource: getIt(),
      authRepository: getIt(), // Si nécessaire
    ),
  );

  getIt.registerLazySingleton(() => GetShopRewardsUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => AddRewardUseCase(
    repository: getIt(),
    authRepository: getIt(),
  ));
  getIt.registerLazySingleton(() => UpdateShopRewardUsecase(
    repository: getIt(),
    authRepository: getIt(),
  ));

   getIt.registerLazySingleton(() => DeleteRewardUseCase(
    repository: getIt(),
    authRepository: getIt(),
  ));



  getIt.registerFactory(() => RewardCubit(
    getShopRewardsUseCase: getIt(),
    addRewardUseCase: getIt(),
    updateRewardUseCase: getIt(),
    deleteRewardUseCase: getIt(),
  ));
getIt.registerLazySingleton<CaissierRemoteDataSource>(
  () => CaissierRemoteDataSource(),
);

// Caissier Repository
getIt.registerLazySingleton<CaissierRepository>(
  () => CaissierRepositoryImpl(
    remoteDataSource: getIt(),
    authRepository: getIt(),
  ),
);

// Caissier Use Cases
getIt.registerLazySingleton(() => AjouterSoldeUseCase(repository: getIt()));
getIt.registerLazySingleton(() => ChargerRecompensesClientUseCase(repository: getIt() ));
getIt.registerLazySingleton(() => ReclamerRecompenseUseCase(repository: getIt()));

// Caissier Cubit
getIt.registerFactory(() => CaissierCubit(
  ajouterSolde: getIt(),
  chargerRecompensesClient: getIt(),
  reclamerRecompense: getIt(),
));
  
}