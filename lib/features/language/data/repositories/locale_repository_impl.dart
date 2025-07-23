


import 'package:mukhlissmagasin/features/language/data/datasources/locale_datasource.dart';
import 'package:mukhlissmagasin/features/language/domain/entities/locale_entity.dart';
import 'package:mukhlissmagasin/features/language/domain/repositories/local_repository.dart';

class LocaleRepositoryImpl implements LocaleRepository {
  final LocaleDatasource datasource;

  LocaleRepositoryImpl(this.datasource);

  @override
  Future<LocaleEntity> getSavedLocale() async {
    final code = await datasource.getSavedLanguageCode();
    return LocaleEntity(code ?? 'fr'); // Default to French
  }

  @override
  Future<void> saveLocale(LocaleEntity locale) {
    return datasource.saveLanguageCode(locale.languageCode);
  }
}