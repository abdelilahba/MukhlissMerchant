import 'package:mukhlissmagasin/features/language/data/datasources/locale_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SharedPrefsLocaleDatasource implements LocaleDatasource {
  @override
  Future<String?> getSavedLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_language');
  }

  @override
  Future<void> saveLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
  }
}