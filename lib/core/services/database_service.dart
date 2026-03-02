import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/no_phrase.dart';

/// Database service for managing favorite phrases using SharedPreferences.
///
/// Provides CRUD operations for persisting and retrieving favorite phrases
/// from local storage.
class DatabaseService {
  /// Key used for storing favorites in SharedPreferences
  static const String _favoritesKey = 'no_way_favorites';

  /// Singleton instance
  static DatabaseService? _instance;

  /// SharedPreferences instance
  SharedPreferences? _prefs;

  /// Flag indicating whether the database is initialized
  bool _isInitialized = false;

  /// Constructs a new DatabaseService instance.
  ///
  /// Use [getInstance] for singleton access.
  DatabaseService._();

  /// Returns the singleton instance of DatabaseService.
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// Returns whether the database has been initialized.
  bool get isInitialized => _isInitialized;

  /// Initializes the SharedPreferences instance.
  ///
  /// This must be called before any database operations.
  /// Typically called in the app's main() function.
  Future<void> initialize() async {
    if (_isInitialized && _prefs != null) {
      return;
    }

    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// Adds a phrase to favorites.
  ///
  /// [phrase] - The NoPhrase to add to favorites.
  ///
  /// Returns true if successful.
  /// Throws [Exception] if database is not initialized.
  Future<bool> addFavorite(NoPhrase phrase) async {
    _ensureInitialized();

    final favorites = await getAllFavorites();
    
    // Check if already exists
    if (favorites.any((f) => f.id == phrase.id)) {
      return true;
    }

    favorites.insert(0, phrase);
    return await _saveFavorites(favorites);
  }

  /// Removes a phrase from favorites.
  ///
  /// [phraseId] - The ID of the phrase to remove.
  ///
  /// Returns true if successfully removed.
  /// Throws [Exception] if database is not initialized.
  Future<bool> removeFavorite(String phraseId) async {
    _ensureInitialized();

    final favorites = await getAllFavorites();
    favorites.removeWhere((f) => f.id == phraseId);
    return await _saveFavorites(favorites);
  }

  /// Retrieves all favorite phrases.
  ///
  /// Returns a list of NoPhrase objects sorted by when they were added
  /// (most recently added first).
  /// Throws [Exception] if database is not initialized.
  Future<List<NoPhrase>> getAllFavorites() async {
    _ensureInitialized();

    final jsonString = _prefs!.getString(_favoritesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((item) => NoPhrase.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  /// Checks if a phrase is in favorites.
  ///
  /// [phraseId] - The ID of the phrase to check.
  ///
  /// Returns true if the phrase is in favorites, false otherwise.
  /// Throws [Exception] if database is not initialized.
  Future<bool> isFavorite(String phraseId) async {
    _ensureInitialized();

    final favorites = await getAllFavorites();
    return favorites.any((f) => f.id == phraseId);
  }

  /// Gets a favorite phrase by ID.
  ///
  /// [phraseId] - The ID of the phrase to retrieve.
  ///
  /// Returns the NoPhrase if found, null otherwise.
  /// Throws [Exception] if database is not initialized.
  Future<NoPhrase?> getFavoriteById(String phraseId) async {
    _ensureInitialized();

    final favorites = await getAllFavorites();
    try {
      return favorites.firstWhere((f) => f.id == phraseId);
    } catch (e) {
      return null;
    }
  }

  /// Gets the count of favorite phrases.
  ///
  /// Returns the total number of phrases in favorites.
  /// Throws [Exception] if database is not initialized.
  Future<int> getFavoritesCount() async {
    _ensureInitialized();

    final favorites = await getAllFavorites();
    return favorites.length;
  }

  /// Clears all favorites from storage.
  ///
  /// Use with caution - this will delete all saved favorites.
  /// Throws [Exception] if database is not initialized.
  Future<bool> clearAllFavorites() async {
    _ensureInitialized();

    return await _prefs!.remove(_favoritesKey);
  }

  /// Saves favorites to storage.
  ///
  /// [favorites] - List of NoPhrase to save.
  Future<bool> _saveFavorites(List<NoPhrase> favorites) async {
    final jsonList = favorites.map((f) => f.toJson()).toList();
    final jsonString = json.encode(jsonList);
    return await _prefs!.setString(_favoritesKey, jsonString);
  }

  /// Checks if the database is initialized and throws if not.
  void _ensureInitialized() {
    if (!_isInitialized || _prefs == null) {
      throw Exception(
        'Database not initialized. Call DatabaseService.instance.initialize() first.',
      );
    }
  }

  /// Closes and resets the database.
  ///
  /// Call this when the app is disposed to release resources.
  Future<void> close() async {
    _prefs = null;
    _isInitialized = false;
    _instance = null;
  }
}
