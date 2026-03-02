import 'package:flutter/material.dart';
import '../core/models/no_phrase.dart';
import '../core/services/api_service.dart';

/// Enum representing the loading state of phrases.
enum PhrasesLoadingState {
  /// Initial state, no loading has started
  initial,

  /// Currently loading phrases
  loading,

  /// Phrases have been successfully loaded
  loaded,

  /// An error occurred while loading phrases
  error,
}

/// Provider for managing "No" phrases state.
///
/// Manages the list of phrases, loading/error states, and provides
/// methods to fetch random phrases, refresh, etc.
class PhrasesProvider extends ChangeNotifier {
  /// List of "No" phrases
  List<NoPhrase> _phrases = [];

  /// Current random phrase being displayed
  NoPhrase? _currentPhrase;

  /// Current loading state
  PhrasesLoadingState _loadingState = PhrasesLoadingState.initial;

  /// Error message if loading failed
  String? _errorMessage;

  /// API service instance
  final ApiService _apiService;

  /// Creates a new PhrasesProvider instance.
  ///
  /// [apiService] - The API service to use for fetching phrases.
  ///               Defaults to ApiService.instance.
  PhrasesProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance;

  /// Getter for phrases list
  List<NoPhrase> get phrases => _phrases;

  /// Getter for current phrase
  NoPhrase? get currentPhrase => _currentPhrase;

  /// Getter for loading state
  PhrasesLoadingState get loadingState => _loadingState;

  /// Getter for error message
  String? get errorMessage => _errorMessage;

  /// Getter for whether data is currently loading
  bool get isLoading => _loadingState == PhrasesLoadingState.loading;

  /// Getter for whether an error occurred
  bool get hasError => _loadingState == PhrasesLoadingState.error;

  /// Getter for whether data is loaded
  bool get isLoaded => _loadingState == PhrasesLoadingState.loaded;

  /// Getter for whether there's data available
  bool get hasData => _phrases.isNotEmpty;

  /// Getter for phrases count
  int get phrasesCount => _phrases.length;

  /// Fetches all phrases from the API.
  ///
  /// Sets loading state to [PhrasesLoadingState.loading] during fetch.
  /// Sets loading state to [PhrasesLoadingState.loaded] on success.
  /// Sets loading state to [PhrasesLoadingState.error] on failure.
  Future<void> fetchAllPhrases() async {
    _loadingState = PhrasesLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _phrases = await _apiService.getAllPhrases();
      _loadingState = PhrasesLoadingState.loaded;
    } on RateLimitError catch (e) {
      _errorMessage = e.message;
      _loadingState = PhrasesLoadingState.error;
    } on NetworkError catch (e) {
      _errorMessage = e.message;
      _loadingState = PhrasesLoadingState.error;
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _loadingState = PhrasesLoadingState.error;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _loadingState = PhrasesLoadingState.error;
    }

    notifyListeners();
  }

  /// Fetches a random phrase from the API.
  ///
  /// If [addToList] is true, adds the fetched phrase to the phrases list.
  /// Sets [currentPhrase] to the fetched phrase.
  Future<void> fetchRandomPhrase({bool addToList = true}) async {
    _loadingState = PhrasesLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final phrase = await _apiService.getRandomPhrase();
      _currentPhrase = phrase;

      if (addToList && !_phrases.any((p) => p.id == phrase.id)) {
        _phrases.insert(0, phrase);
      }

      _loadingState = PhrasesLoadingState.loaded;
    } on RateLimitError catch (e) {
      _errorMessage = e.message;
      _loadingState = PhrasesLoadingState.error;
    } on NetworkError catch (e) {
      _errorMessage = e.message;
      _loadingState = PhrasesLoadingState.error;
    } on ApiError catch (e) {
      _errorMessage = e.message;
      _loadingState = PhrasesLoadingState.error;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _loadingState = PhrasesLoadingState.error;
    }

    notifyListeners();
  }

  /// Fetches a random phrase if the current phrase is null or
  /// refreshes with a new random phrase.
  ///
  /// This is useful for initial load or refresh functionality.
  Future<void> refresh() async {
    if (_currentPhrase == null) {
      await fetchRandomPhrase();
    } else {
      await fetchRandomPhrase(addToList: false);
    }
  }

  /// Gets a random phrase from the existing list without making an API call.
  ///
  /// If the list is empty, falls back to [fetchRandomPhrase].
  void getRandomFromList() {
    if (_phrases.isEmpty) {
      fetchRandomPhrase();
      return;
    }

    final random = DateTime.now().millisecondsSinceEpoch % _phrases.length;
    _currentPhrase = _phrases[random];
    notifyListeners();
  }

  /// Sets a specific phrase as the current phrase.
  ///
  /// [phrase] - The phrase to set as current.
  void setCurrentPhrase(NoPhrase phrase) {
    _currentPhrase = phrase;
    notifyListeners();
  }

  /// Clears the current phrase.
  void clearCurrentPhrase() {
    _currentPhrase = null;
    notifyListeners();
  }

  /// Adds a phrase to the phrases list.
  ///
  /// [phrase] - The phrase to add.
  void addPhrase(NoPhrase phrase) {
    if (!_phrases.any((p) => p.id == phrase.id)) {
      _phrases.insert(0, phrase);
      notifyListeners();
    }
  }

  /// Removes a phrase from the phrases list.
  ///
  /// [phraseId] - The ID of the phrase to remove.
  void removePhrase(String phraseId) {
    _phrases.removeWhere((p) => p.id == phraseId);
    if (_currentPhrase?.id == phraseId) {
      _currentPhrase = null;
    }
    notifyListeners();
  }

  /// Clears all phrases from the list.
  void clearPhrases() {
    _phrases.clear();
    _currentPhrase = null;
    _loadingState = PhrasesLoadingState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  /// Resets the provider to its initial state.
  void reset() {
    _phrases = [];
    _currentPhrase = null;
    _loadingState = PhrasesLoadingState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  /// Checks if a phrase exists in the list by ID.
  ///
  /// [phraseId] - The ID of the phrase to check.
  bool hasPhrase(String phraseId) {
    return _phrases.any((p) => p.id == phraseId);
  }

  /// Gets a phrase by ID from the list.
  ///
  /// [phraseId] - The ID of the phrase to retrieve.
  NoPhrase? getPhraseById(String phraseId) {
    try {
      return _phrases.firstWhere((p) => p.id == phraseId);
    } catch (e) {
      return null;
    }
  }

  /// Retries the last failed operation.
  ///
  /// If the last state was an error, attempts to fetch a new random phrase.
  Future<void> retry() async {
    if (_loadingState == PhrasesLoadingState.error) {
      await fetchRandomPhrase();
    }
  }
}
