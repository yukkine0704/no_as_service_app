import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/localization/localization_service.dart';

/// Provider for managing app locale/language
/// 
/// Handles language switching and persists user preference
class LocaleProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  final LocalizationService _localizationService = LocalizationService();
  
  /// Current language code ('en' or 'es')
  String get languageCode => _localizationService.languageCode;
  
  /// Initialize the provider
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    
    if (savedLanguage != null) {
      _localizationService.setLanguage(savedLanguage);
      notifyListeners();
    }
  }
  
  /// Set the language
  Future<void> setLanguage(String languageCode) async {
    if (languageCode != _localizationService.languageCode) {
      _localizationService.setLanguage(languageCode);
      
      // Persist preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      notifyListeners();
    }
  }
  
  /// Toggle between English and Spanish
  Future<void> toggleLanguage() async {
    final newLanguage = _localizationService.isSpanish ? 'en' : 'es';
    await setLanguage(newLanguage);
  }
  
  /// Set language to English
  Future<void> setEnglish() async {
    await setLanguage('en');
  }
  
  /// Set language to Spanish
  Future<void> setSpanish() async {
    await setLanguage('es');
  }
  
  /// Check if current language is Spanish
  bool get isSpanish => _localizationService.isSpanish;
  
  /// Check if current language is English
  bool get isEnglish => _localizationService.isEnglish;
}
