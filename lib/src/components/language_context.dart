import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'ro';

  String get currentLanguage => _currentLanguage;

  Future<void> toggleLanguage() async {
    _currentLanguage = _currentLanguage == 'ro' ? 'en' : 'ro';
    await _saveLanguage(_currentLanguage);
    notifyListeners();
  }

  Future<void> _saveLanguage(String selectedLanguage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appLanguage', selectedLanguage);
  }

  Future<void> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString('appLanguage') ?? 'ro';
      debugPrint("Language loaded: $_currentLanguage");
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading language: $e");
    }
  }

  String getText(String key) {
    final Map<String, Map<String, String>> translations = {
      'appointments': {
        'ro': 'Programări',
        'en': 'Appointments',
      },
      'name': {
        'ro': 'Nume',
        'en': 'Name',
      },
      'phone': {
        'ro': 'Telefon',
        'en': 'Phone',
      },
    };

    // Check if the key exists and the current language is valid
    return translations[key]?.containsKey(currentLanguage) == true
        ? translations[key]![currentLanguage]!
        : translations[key]?['en'] ?? ''; // Return default to 'en' if key or language is missing
  }
}
