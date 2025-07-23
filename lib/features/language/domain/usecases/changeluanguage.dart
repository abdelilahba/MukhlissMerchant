import 'package:mukhlissmagasin/features/language/domain/entities/locale_entity.dart';
import 'package:mukhlissmagasin/features/language/domain/repositories/local_repository.dart';

class GetLocale {
  final LocaleRepository repository;

  GetLocale(this.repository);

  Future<LocaleEntity> call() => repository.getSavedLocale();
}

class SaveLocale {
  final LocaleRepository repository;

  SaveLocale(this.repository);

  Future<void> call(LocaleEntity locale) => repository.saveLocale(locale);
}