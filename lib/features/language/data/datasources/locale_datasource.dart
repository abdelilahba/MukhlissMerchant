


abstract class LocaleDatasource {
  Future<String?> getSavedLanguageCode();
  Future<void> saveLanguageCode(String languageCode);
}