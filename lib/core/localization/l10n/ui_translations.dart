/// UI Translations for the app
/// 
/// Contains all user interface strings in both English and Spanish.
/// Use [AppLocalizations] extension on BuildContext for easy access.

/// Supported languages in the app
enum SupportedLanguage {
  english('en', 'English', '🇺🇸'),
  spanish('es', 'Español', '🇪🇸');

  final String code;
  final String name;
  final String flag;

  const SupportedLanguage(this.code, this.name, this.flag);
}

/// Map of all UI translations
class UiTranslations {
  static const Map<String, Map<String, String>> _translations = {
    // Home Screen
    'appTitle': {
      'en': 'NoWay',
      'es': 'NoWay',
    },
    'homeTab': {
      'en': 'Home',
      'es': 'Inicio',
    },
    'favoritesTab': {
      'en': 'Favorites',
      'es': 'Favoritos',
    },
    'settingsTab': {
      'en': 'Settings',
      'es': 'Ajustes',
    },
    'tooltipFavorites': {
      'en': 'Favorites',
      'es': 'Favoritos',
    },
    'tooltipNewPhrase': {
      'en': 'New phrase',
      'es': 'Nueva frase',
    },
    'addedToFavorites': {
      'en': 'Added to favorites: @phrase',
      'es': 'Añadido a favoritos: @phrase',
    },
    'noPhrasesAvailable': {
      'en': 'No phrases available',
      'es': 'No hay frases disponibles',
    },
    'tapButtonToLoad': {
      'en': 'Tap the button to load new phrases',
      'es': 'Toca el botón para cargar nuevas frases',
    },
    'loadPhrases': {
      'en': 'Load phrases',
      'es': 'Cargar frases',
    },
    'unknownError': {
      'en': 'Unknown error',
      'es': 'Error desconocido',
    },
    'noPrefix': {
      'en': 'NO',
      'es': 'NO',
    },

    // Favorites Screen
    'myFavorites': {
      'en': 'My Favorites',
      'es': 'Mis Favoritos',
    },
    'deleteAll': {
      'en': 'Delete all',
      'es': 'Eliminar todos',
    },
    'deleteFromFavorites': {
      'en': 'Delete from favorites',
      'es': 'Eliminar de favoritos',
    },
    'deleteConfirmation': {
      'en': 'Are you sure you want to delete',
      'es': '¿Estás seguro de que quieres eliminar',
    },
    'fromFavorites': {
      'en': 'from favorites?',
      'es': 'de favoritos?',
    },
    'cancel': {
      'en': 'Cancel',
      'es': 'Cancelar',
    },
    'delete': {
      'en': 'Delete',
      'es': 'Eliminar',
    },
    'deleteAllFavorites': {
      'en': 'Delete all favorites',
      'es': 'Eliminar todos los favoritos',
    },
    'deleteAllConfirmation': {
      'en': 'Are you sure you want to delete all favorites? This action cannot be undone.',
      'es': '¿Estás seguro de que quieres eliminar todos los favoritos? Esta acción no se puede deshacer.',
    },
    'deleteAllButton': {
      'en': 'Delete all',
      'es': 'Eliminar todo',
    },
    'deletedFromFavorites': {
      'en': 'Deleted from favorites',
      'es': 'Eliminado de favoritos',
    },
    'allFavoritesDeleted': {
      'en': 'All favorites deleted',
      'es': 'Todos los favoritos eliminados',
    },
    'noFavoritesYet': {
      'en': 'No favorites yet',
      'es': 'Sin favoritos aún',
    },
    'savedPhrasesAppearHere': {
      'en': 'Saved phrases will appear here',
      'es': 'Las frases que guardes aparecerán aquí',
    },
    'explorePhrases': {
      'en': 'Explore phrases',
      'es': 'Explorar frases',
    },
    'phraseSaved': {
      'en': 'phrase saved',
      'es': 'frase guardada',
    },
    'phrasesSaved': {
      'en': 'phrases saved',
      'es': 'frases guardadas',
    },
    'copiedToClipboard': {
      'en': 'Phrase copied to clipboard',
      'es': 'Frase copiada al portapapeles',
    },
    'phraseCopied': {
      'en': 'Phrase copied to clipboard',
      'es': 'Frase copiada al portapapeles',
    },
    'removeFromFavorites': {
      'en': 'Remove from favorites',
      'es': 'Eliminar de favoritos',
    },
    'confirmRemove': {
      'en': 'Are you sure you want to remove',
      'es': '¿Estás seguro de que quieres eliminar',
    },
    'removedFromFavorites': {
      'en': 'Removed from favorites',
      'es': 'Eliminado de favoritos',
    },
    'confirmDeleteAll': {
      'en': 'Are you sure you want to delete all favorites? This action cannot be undone.',
      'es': '¿Estás seguro de que quieres eliminar todos los favoritos? Esta acción no se puede deshacer.',
    },
    'favoritesAppearHere': {
      'en': 'Saved phrases will appear here',
      'es': 'Las frases que guardes aparecerán aquí',
    },

    // Settings Screen
    'settings': {
      'en': 'Settings',
      'es': 'Configuración',
    },
    'theme': {
      'en': 'Theme',
      'es': 'Tema',
    },
    'appearance': {
      'en': 'Appearance',
      'es': 'Apariencia',
    },
    'selectTheme': {
      'en': 'Select a theme',
      'es': 'Selecciona un tema',
    },
    'dynamicColors': {
      'en': 'Dynamic colors',
      'es': 'Colores dinámicos',
    },
    'dynamicColorsDescription': {
      'en': 'Use Android 12+ colors (Monet)',
      'es': 'Utiliza los colores de Android 12+ (Monet)',
    },
    'darkMode': {
      'en': 'Dark mode',
      'es': 'Modo oscuro',
    },
    'enabled': {
      'en': 'Enabled',
      'es': 'Activado',
    },
    'disabled': {
      'en': 'Disabled',
      'es': 'Desactivado',
    },
    'light': {
      'en': 'Light',
      'es': 'Claro',
    },
    'dark': {
      'en': 'Dark',
      'es': 'Oscuro',
    },
    'currentTheme': {
      'en': 'Current theme',
      'es': 'Tema actual',
    },
    'dynamicMonet': {
      'en': 'Dynamic (Monet)',
      'es': 'Dinámico (Monet)',
    },
    'dynamicColorsNote': {
      'en': 'Colors adapt automatically based on your wallpaper on Android 12+',
      'es': 'Los colores se adaptan automáticamente según tu fondo de pantalla en Android 12+',
    },
    'language': {
      'en': 'Language',
      'es': 'Idioma',
    },
    'selectLanguage': {
      'en': 'Select language',
      'es': 'Seleccionar idioma',
    },

    // Rate Limit Card
    'rateLimitTitle': {
      'en': 'Stop right there!',
      'es': '¡Alto ahí!',
    },
    'rateLimitSubtitle': {
      'en': 'So many noes needed?',
      'es': '¿Tantas negativas necesitas?',
    },
    'rateLimitMessage': {
      'en': 'You have reached the limit of 120 requests',
      'es': 'Has alcanzado el límite de 120 solicitudes',
    },
    'waitAMoment': {
      'en': 'Wait a moment...',
      'es': 'Espera un poco...',
    },
    'viewMyFavoritesRate': {
      'en': 'View my favorites',
      'es': 'Ver mis favoritos',
    },

    // Offline Card
    'offline': {
      'en': 'Offline',
      'es': 'Sin conexión',
    },
    'seenAllOffline': {
      'en': 'You\'ve seen all available offline phrases',
      'es': 'Has visto todas las frases disponibles offline',
    },
    'cachedPhrases': {
      'en': '@count cached phrases',
      'es': '@count frases en caché',
    },
    'viewMyFavorites': {
      'en': 'View my favorites',
      'es': 'Ver mis favoritos',
    },
    'connectionRestored': {
      'en': 'Connection restored!',
      'es': '¡Conexión restablecida!',
    },
    'continuingInSeconds': {
      'en': 'Continuing in @count seconds...',
      'es': 'Continuando en @count segundos...',
    },
    'swipeToContinue': {
      'en': 'Swipe to continue',
      'es': 'Desliza para continuar',
    },
    'continueNow': {
      'en': 'Continue now',
      'es': 'Continuar ahora',
    },
    'loadingNewPhrases': {
      'en': 'Loading new phrases...',
      'es': 'Cargando nuevas frases...',
    },
    'checkConnection': {
      'en': 'Check connection',
      'es': 'Verificar conexión',
    },

    // Error Offline View
    'oops': {
      'en': 'Oops!',
      'es': '¡Ups!',
    },
    'worldWantsYes': {
      'en': 'Looks like the world wants you to say yes',
      'es': 'Parece que el mundo quiere que digas que sí',
    },
    'checkInternet': {
      'en': 'Check your internet connection',
      'es': 'Verifica tu conexión a internet',
    },
    'somethingWentWrong': {
      'en': 'Something went wrong',
      'es': 'Algo salió mal',
    },
    'offlineTitle': {
      'en': 'You\'re offline',
      'es': 'Estás sin conexión',
    },
    'offlineMessage': {
      'en': 'Connect to the internet to discover amazing "No" phrases.',
      'es': 'Conéctate a internet para descubrir frases de "No" increíbles.',
    },
    'viewFavoritesOffline': {
      'en': 'You can still view your saved favorites while offline.',
      'es': 'Aún puedes ver tus favoritos guardados mientras estás sin conexión.',
    },
    'viewFavorites': {
      'en': 'View favorites',
      'es': 'Ver favoritos',
    },
    'retry': {
      'en': 'Retry',
      'es': 'Reintentar',
    },
  };

  /// Get translation for a key in the specified language
  static String get(String key, String languageCode) {
    final translation = _translations[key]?[languageCode];
    if (translation == null) {
      // Fallback to English if translation not found
      return _translations[key]?['en'] ?? key;
    }
    return translation;
  }

  /// Check if a key exists
  static bool hasKey(String key) {
    return _translations.containsKey(key);
  }
}
