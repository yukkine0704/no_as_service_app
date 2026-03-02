import 'package:flutter/material.dart';
import '../core/models/no_phrase.dart';
import '../core/services/database_service.dart';

/// Provider for managing favorite phrases.
///
/// Manages the list of favorite phrases and syncs with DatabaseService
/// for persistence.
class FavoritesProvider extends ChangeNotifier {
  /// List of favorite phrases
  List<NoPhrase> _favorites = [];

  /// Whether favorites are currently loading
  bool _isLoading = false;

  /// Error message if an operation failed
  String? _errorMessage;

  /// Database service instance
  final DatabaseService _databaseService;

  /// Whether the provider has been initialized
  bool _isInitialized = false;

  /// Creates a new FavoritesProvider instance.
  ///
  /// [databaseService] - The database service to use.
  ///                     Defaults to DatabaseService.instance.
  FavoritesProvider({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  /// Getter for favorites list
  List<NoPhrase> get favorites => _favorites;

  /// Getter for isLoading status
  bool get isLoading => _isLoading;

  /// Getter for error message
  String? get errorMessage => _errorMessage;

  /// Getter for whether provider is initialized
  bool get isInitialized => _isInitialized;

  /// Getter for favorites count
  int get favoritesCount => _favorites.length;

  /// Getter for whether favorites is empty
  bool get isEmpty => _favorites.isEmpty;

  /// Getter for whether favorites is not empty
  bool get isNotEmpty => _favorites.isNotEmpty;

  /// Initializes the provider by loading favorites from database.
  ///
  /// This must be called before any operations.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _databaseService.initialize();
      await loadFavorites();
      _isInitialized = true;
    } catch (e) {
      _errorMessage = 'Failed to initialize favorites: $e';
      notifyListeners();
    }
  }

  /// Loads all favorites from the database.
  Future<void> loadFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _favorites = await _databaseService.getAllFavorites();
    } catch (e) {
      _errorMessage = 'Failed to load favorites: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Adds a phrase to favorites.
  ///
  /// [phrase] - The phrase to add to favorites.
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> addFavorite(NoPhrase phrase) async {
    // Check if already in favorites
    if (isFavorite(phrase.id)) {
      return true;
    }

    _errorMessage = null;

    try {
      final success = await _databaseService.addFavorite(phrase);
      if (success) {
        _favorites.insert(0, phrase);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to add favorite: $e';
      notifyListeners();
      return false;
    }
  }

  /// Removes a phrase from favorites.
  ///
  /// [phraseId] - The ID of the phrase to remove.
  ///
  /// Returns true if successfully removed, false otherwise.
  Future<bool> removeFavorite(String phraseId) async {
    _errorMessage = null;

    try {
      final success = await _databaseService.removeFavorite(phraseId);
      if (success) {
        _favorites.removeWhere((f) => f.id == phraseId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to remove favorite: $e';
      notifyListeners();
      return false;
    }
  }

  /// Toggles a phrase's favorite status.
  ///
  /// [phrase] - The phrase to toggle.
  ///
  /// Returns true if the phrase is now a favorite, false otherwise.
  Future<bool> toggleFavorite(NoPhrase phrase) async {
    if (isFavorite(phrase.id)) {
      await removeFavorite(phrase.id);
      return false;
    } else {
      await addFavorite(phrase);
      return true;
    }
  }

  /// Checks if a phrase is in favorites.
  ///
  /// [phraseId] - The ID of the phrase to check.
  ///
  /// Returns true if the phrase is in favorites, false otherwise.
  bool isFavorite(String phraseId) {
    return _favorites.any((f) => f.id == phraseId);
  }

  /// Gets a favorite phrase by ID.
  ///
  /// [phraseId] - The ID of the phrase to retrieve.
  ///
  /// Returns the NoPhrase if found, null otherwise.
  NoPhrase? getFavoriteById(String phraseId) {
    try {
      return _favorites.firstWhere((f) => f.id == phraseId);
    } catch (e) {
      return null;
    }
  }

  /// Clears all favorites from the provider and database.
  ///
  /// Use with caution - this will delete all saved favorites.
  Future<bool> clearAllFavorites() async {
    _errorMessage = null;

    try {
      final success = await _databaseService.clearAllFavorites();
      if (success) {
        _favorites.clear();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to clear favorites: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clears the error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Resets the provider to its initial state.
  void reset() {
    _favorites = [];
    _isLoading = false;
    _errorMessage = null;
    _isInitialized = false;
    notifyListeners();
  }

  /// Refreshes favorites from the database.
  Future<void> refresh() async {
    await loadFavorites();
  }

  /// Gets all favorite IDs as a set for quick lookup.
  Set<String> get favoriteIds {
    return _favorites.map((f) => f.id).toSet();
  }

  /// Checks if a list of phrases contains any favorites.
  ///
  /// [phrases] - The list of phrases to check.
  ///
  /// Returns true if any phrase is a favorite.
  bool hasAnyFavorite(List<NoPhrase> phrases) {
    final favoriteIdsSet = favoriteIds;
    return phrases.any((p) => favoriteIdsSet.contains(p.id));
  }

  /// Filters a list to only include favorite phrases.
  ///
  /// [phrases] - The list of phrases to filter.
  ///
  /// Returns a list of phrases that are favorites.
  List<NoPhrase> filterFavorites(List<NoPhrase> phrases) {
    final favoriteIdsSet = favoriteIds;
    return phrases.where((p) => favoriteIdsSet.contains(p.id)).toList();
  }
}
