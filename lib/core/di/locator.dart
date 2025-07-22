import 'package:mukhlissmagasin/core/di/injection_container.dart';
import 'package:mukhlissmagasin/features/language/data/datasources/locale_datasource.dart';
import 'package:mukhlissmagasin/features/language/data/datasources/shared_prefs_datasource.dart';
import 'package:mukhlissmagasin/features/language/data/repositories/locale_repository_impl.dart';
import 'package:mukhlissmagasin/features/language/domain/repositories/local_repository.dart';
import 'package:mukhlissmagasin/features/language/domain/usecases/changeluanguage.dart';
import 'package:mukhlissmagasin/features/language/presentation/cubit/language_cubit.dart';



void setupLanguageDependencies() {
  // Datasource
  getIt.registerLazySingleton<LocaleDatasource>(
    () => SharedPrefsLocaleDatasource(),
  );

  // Repository
  getIt.registerLazySingleton<LocaleRepository>(
    () => LocaleRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetLocale(getIt()));
  getIt.registerLazySingleton(() => SaveLocale(getIt()));

  // Cubit
  getIt.registerFactory(
    () => LanguageCubit(
      getLocale: getIt(),  // Utilisez le même nom que dans le constructeur
      saveLocale: getIt(), // Utilisez le même nom que dans le constructeur
    ),
  );
}