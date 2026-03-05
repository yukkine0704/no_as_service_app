import 'dart:async';
import 'package:dio/dio.dart';
import '../models/no_phrase.dart';

/// Custom exception for rate limit errors (HTTP 429).
class RateLimitError implements Exception {
  final String message;
  final DateTime? retryAfter;

  const RateLimitError({
    this.message = 'Rate limit exceeded. Please try again later.',
    this.retryAfter,
  });

  @override
  String toString() => 'RateLimitError: $message';
}

/// Custom exception for network connectivity errors.
class NetworkError implements Exception {
  final String message;
  final dynamic originalError;

  const NetworkError({
    this.message = 'Network connection error. Please check your internet connection.',
    this.originalError,
  });

  @override
  String toString() => 'NetworkError: $message';
}

/// Custom exception for general API errors.
class ApiError implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiError({
    this.message = 'An API error occurred.',
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiError: $message (status: $statusCode)';
}

/// Rate limit interceptor for Dio.
///
/// Implements a token bucket algorithm to enforce 120 requests per minute.
class RateLimitInterceptor extends Interceptor {
  /// Maximum number of requests allowed per minute
  static const int _maxRequestsPerMinute = 120;

  /// Time window in seconds (1 minute)
  static const int _windowSeconds = 60;

  final List<DateTime> _requestTimestamps = [];
  bool _isProcessing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Simple synchronization using a flag
    while (_isProcessing) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    
    _isProcessing = true;
    try {
      final now = DateTime.now();
      final windowStart = now.subtract(const Duration(seconds: _windowSeconds));

      // Remove timestamps outside the current window
      _requestTimestamps.removeWhere((ts) => ts.isBefore(windowStart));

      // Check if we've exceeded the rate limit
      if (_requestTimestamps.length >= _maxRequestsPerMinute) {
        // Calculate retry-after time
        final oldestTimestamp = _requestTimestamps.first;
        final retryAfter = oldestTimestamp.add(const Duration(seconds: _windowSeconds));
        
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 429,
            ),
            error: RateLimitError(
              message: 'Rate limit exceeded. Maximum $_maxRequestsPerMinute requests per minute allowed.',
              retryAfter: retryAfter,
            ),
          ),
          true,
        );
        return;
      }

      // Add current request timestamp
      _requestTimestamps.add(now);
    } finally {
      _isProcessing = false;
    }

    handler.next(options);
  }

  /// Resets the rate limit counter (useful for testing).
  void reset() {
    _requestTimestamps.clear();
  }

  /// Returns the current number of requests in the window.
  int get currentRequestCount => _requestTimestamps.length;
}

/// API service for fetching "No" phrases from the NoWay API.
///
/// Uses Dio as the HTTP client with rate limiting and error handling.
class ApiService {
  /// Base URL for the NoWay API
  static const String _baseUrl = 'https://naas.isalman.dev';

  late final Dio _dio;
  late final RateLimitInterceptor _rateLimitInterceptor;

  /// Singleton instance
  static ApiService? _instance;

  /// Constructs a new ApiService instance.
  ///
  /// Use [getInstance] for singleton access.
  ApiService._() {
    _rateLimitInterceptor = RateLimitInterceptor();
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _rateLimitInterceptor,
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }

  /// Returns the singleton instance of ApiService.
  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  /// Fetches a random "No" phrase from the API.
  ///
  /// Throws [RateLimitError] if rate limit is exceeded.
  /// Throws [NetworkError] if there's a connectivity issue.
  /// Throws [ApiError] for other API errors.
  Future<NoPhrase> getRandomPhrase() async {
    try {
      final response = await _dio.get('/no');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle different response formats
        if (data is Map<String, dynamic>) {
          // Check for nested data structure
          if (data.containsKey('data')) {
            return NoPhrase.fromJson(data['data'] as Map<String, dynamic>);
          }
          return NoPhrase.fromJson(data);
        } else if (data is String) {
          // Handle plain string response
          return NoPhrase(id: '1', phrase: data);
        }
        
        throw const ApiError(message: 'Unexpected response format');
      }

      throw ApiError(
        message: 'Failed to fetch phrase',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetches multiple "No" phrases from the API for initial load.
  ///
  /// Since the API only supports random phrase endpoints, this method
  /// fetches multiple random phrases in parallel to populate the initial
  /// card stack. By default, fetches 5 phrases to ensure smooth swiping.
  ///
  /// [count] - Number of phrases to fetch (default: 5).
  ///
  /// Throws [RateLimitError] if rate limit is exceeded.
  /// Throws [NetworkError] if there's a connectivity issue.
  /// Throws [ApiError] for other API errors.
  Future<List<NoPhrase>> getAllPhrases({int count = 5}) async {
    final phrases = <NoPhrase>[];
    final phraseIds = <String>{}; // Track IDs to avoid duplicates
    
    // Fetch multiple phrases in parallel for faster initial load
    final futures = List.generate(count, (_) => _fetchSinglePhrase());
    
    try {
      final results = await Future.wait(futures, eagerError: false);
      
      for (final phrase in results) {
        if (phrase != null && !phraseIds.contains(phrase.id)) {
          phrases.add(phrase);
          phraseIds.add(phrase.id);
        }
      }
      
      // If we got no phrases, throw an error
      if (phrases.isEmpty) {
        throw const ApiError(message: 'Failed to fetch any phrases');
      }
      
      return phrases;
    } on RateLimitError {
      rethrow;
    } on NetworkError {
      rethrow;
    } on ApiError {
      rethrow;
    } catch (e) {
      throw ApiError(message: 'Failed to fetch phrases: $e');
    }
  }
  
  /// Helper method to fetch a single phrase for batch operations.
  Future<NoPhrase?> _fetchSinglePhrase() async {
    try {
      final response = await _dio.get('/no');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            return NoPhrase.fromJson(data['data'] as Map<String, dynamic>);
          }
          return NoPhrase.fromJson(data);
        } else if (data is String) {
          // Generate a unique ID based on the phrase content
          final id = data.hashCode.toString();
          return NoPhrase(id: id, phrase: data);
        }
      }
      return null;
    } catch (e) {
      // Return null for individual failures in batch operations
      return null;
    }
  }

  /// Fetches a specific "No" phrase by ID.
  ///
  /// [id] - The unique identifier of the phrase.
  ///
  /// Throws [RateLimitError] if rate limit is exceeded.
  /// Throws [NetworkError] if there's a connectivity issue.
  /// Throws [ApiError] for other API errors.
  Future<NoPhrase> getPhraseById(String id) async {
    try {
      final response = await _dio.get('/no/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            return NoPhrase.fromJson(data['data'] as Map<String, dynamic>);
          }
          return NoPhrase.fromJson(data);
        }
        
        throw const ApiError(message: 'Unexpected response format');
      }

      throw ApiError(
        message: 'Failed to fetch phrase',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handles Dio errors and converts them to custom exceptions.
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkError(
          message: 'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.connectionError:
        return NetworkError(
          message: 'Unable to connect to server. Please check your internet connection.',
          originalError: error.error,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        if (statusCode == 429) {
          return RateLimitError(
            message: 'Rate limit exceeded. Please try again later.',
          );
        }
        
        String message = 'Server error occurred.';
        if (responseData is Map<String, dynamic>) {
          message = responseData['message']?.toString() ?? message;
        }
        
        return ApiError(
          message: message,
          statusCode: statusCode,
          data: responseData,
        );
      case DioExceptionType.cancel:
        return const ApiError(message: 'Request was cancelled.');
      default:
        return NetworkError(
          message: 'An unexpected error occurred.',
          originalError: error.error,
        );
    }
  }

  /// Resets the rate limiter (useful for testing).
  void resetRateLimiter() {
    _rateLimitInterceptor.reset();
  }

  /// Disposes of the Dio instance and releases resources.
  void dispose() {
    _dio.close();
    _instance = null;
  }
}
