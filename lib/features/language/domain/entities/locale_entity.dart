import 'dart:ui';

class LocaleEntity {
  final String languageCode;
  
  const LocaleEntity(this.languageCode);

  Locale toLocale() => Locale(languageCode);
}