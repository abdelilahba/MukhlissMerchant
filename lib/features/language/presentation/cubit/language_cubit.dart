import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mukhlissmagasin/features/language/domain/entities/locale_entity.dart';
import 'package:mukhlissmagasin/features/language/domain/usecases/changeluanguage.dart';

class LanguageCubit extends Cubit<Locale> {
  final GetLocale getLocale;
  final SaveLocale saveLocale;

  LanguageCubit({
    required this.getLocale,
    required this.saveLocale,
  }) : super(const Locale('fr')) {
    loadSavedLocale();
  }

  Future<void> loadSavedLocale() async {
    final localeEntity = await getLocale();
    emit(localeEntity.toLocale());
  }

  Future<void> changeLanguage(Locale newLocale) async {
    await saveLocale(LocaleEntity(newLocale.languageCode));
    emit(newLocale);
  }
}