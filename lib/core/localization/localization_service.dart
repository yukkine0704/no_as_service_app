import 'package:flutter/material.dart';
import 'l10n/ui_translations.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  /// Current language code
  String _languageCode = 'es'; // Default to Spanish

  /// Get current language code
  String get languageCode => _languageCode;

  /// Check if current language is Spanish
  bool get isSpanish => _languageCode == 'es';

  /// Check if current language is English
  bool get isEnglish => _languageCode == 'en';

  /// Set the language
  void setLanguage(String languageCode) {
    if (languageCode == 'en' || languageCode == 'es') {
      _languageCode = languageCode;
    }
  }

  /// Translate a key to the current language
  String translate(String key) {
    return UiTranslations.get(key, _languageCode);
  }

  /// Get supported languages
  List<SupportedLanguage> get supportedLanguages => SupportedLanguage.values;
}

/// Extension to easily access translations from BuildContext
extension LocalizationExtension on BuildContext {
  /// Get the localization service
  LocalizationService get l10n => LocalizationService();

  /// Translate a key
  String tr(String key) => l10n.translate(key);
}
