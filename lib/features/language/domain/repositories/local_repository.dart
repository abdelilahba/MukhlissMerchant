



import 'package:mukhlissmagasin/features/language/domain/entities/locale_entity.dart';

abstract class LocaleRepository {

Future<void> saveLocale(LocaleEntity locale);

Future<LocaleEntity>getSavedLocale();

}