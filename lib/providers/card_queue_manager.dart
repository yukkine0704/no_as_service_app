import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/models/no_phrase.dart';
import '../core/enums/offline_card_state.dart';

export '../core/enums/offline_card_state.dart';

/// Manages the card queue and offline state for the swiping system.
///
/// Features:
/// - Tracks cached phrases for offline access
/// - Monitors connectivity when offline card is visible
/// - Auto-reveals pending cards when connection is restored
/// - Handles re-appearance if dismissed while still offline
class CardQueueManager extends ChangeNotifier {
  /// Current offline card state
  OfflineCardState _offlineCardState = OfflineCardState.hidden;

  /// Cached phrases available offline
  List<NoPhrase> _cachedPhrases = [];

  /// Whether we're currently offline
  bool _isOffline = false;

  /// Whether we were previously offline (for tracking restoration)
  bool _wasOffline = false;

  /// Timer for periodic connectivity checks
  Timer? _connectivityTimer;

  /// Timer for auto-reveal after connection restored
  Timer? _autoRevealTimer;

  /// Timer for stable connection detection (prevents flickering)
  Timer? _stableConnectionTimer;

  /// Timestamp when offline mode was activated
  DateTime? _offlineActivatedAt;

  /// Connectivity instance
  final Connectivity _connectivity = Connectivity();

  // Getters
  OfflineCardState get offlineCardState => _offlineCardState;
  List<NoPhrase> get cachedPhrases => List.unmodifiable(_cachedPhrases);
  bool get isOffline => _isOffline;
  bool get wasOffline => _wasOffline;
  bool get isMonitoring => _connectivityTimer != null;
  DateTime? get offlineActivatedAt => _offlineActivatedAt;

  /// Whether the offline card should be shown
  bool get shouldShowOfflineCard =>
      _offlineCardState == OfflineCardState.visibleOffline ||
      _offlineCardState == OfflineCardState.connectedWaiting;

  /// Whether auto-reveal is in progress
  bool get isAutoRevealing =>
      _offlineCardState == OfflineCardState.autoRevealing;

  /// Called when connectivity changes from the ConnectivityProvider
  void onConnectivityChanged(bool isConnected) {
    final wasOffline = _isOffline;
    _isOffline = !isConnected;

    if (wasOffline && isConnected) {
      // Connection restored
      _wasOffline = true;
      // Defer state change to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleConnectionRestored();
      });
    } else if (!wasOffline && !isConnected) {
      // Connection lost
      // Defer state change to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleConnectionLost();
      });
    }

    // Only notify if state actually changed and we're not in build phase
    if (wasOffline != _isOffline) {
      // Defer notification to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Handles connection restoration logic
  void _handleConnectionRestored() {
    debugPrint('[CardQueueManager] Connection restored');

    // Cancel any pending stable connection timer
    _stableConnectionTimer?.cancel();

    // Require stable connection for 2 seconds before acting
    _stableConnectionTimer = Timer(const Duration(seconds: 2), () {
      if (_offlineCardState == OfflineCardState.visibleOffline) {
        // Transition to connected waiting state
        _offlineCardState = OfflineCardState.connectedWaiting;
        debugPrint('[CardQueueManager] Transitioned to connectedWaiting');
        notifyListeners();

        // Start auto-reveal timer
        _startAutoRevealTimer();
      }
    });
  }

  /// Handles connection loss logic
  void _handleConnectionLost() {
    debugPrint('[CardQueueManager] Connection lost');

    // Cancel stable connection timer if running
    _stableConnectionTimer?.cancel();

    // If we were in connected waiting state, go back to offline
    if (_offlineCardState == OfflineCardState.connectedWaiting) {
      _offlineCardState = OfflineCardState.visibleOffline;
      debugPrint('[CardQueueManager] Reverted to visibleOffline');
      notifyListeners();
    }
  }

  /// Activate offline mode when reaching end of cached phrases
  void activateOfflineMode(List<NoPhrase> currentPhrases) {
    debugPrint('[CardQueueManager] Activating offline mode');

    _cachedPhrases = List.from(currentPhrases);
    _isOffline = true;
    _wasOffline = false;
    _offlineActivatedAt = DateTime.now();
    _offlineCardState = OfflineCardState.visibleOffline;

    _startConnectivityMonitoring();
    notifyListeners();
  }

  /// Start periodic connectivity monitoring
  void _startConnectivityMonitoring() {
    _connectivityTimer?.cancel();
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkConnectivity(),
    );
    debugPrint('[CardQueueManager] Started connectivity monitoring');
  }

  /// Stop connectivity monitoring
  void _stopConnectivityMonitoring() {
    _connectivityTimer?.cancel();
    _connectivityTimer = null;
    debugPrint('[CardQueueManager] Stopped connectivity monitoring');
  }

  /// Check current connectivity
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final isConnected = results.isNotEmpty &&
          !results.contains(ConnectivityResult.none);

      if (isConnected && _isOffline) {
        onConnectivityChanged(true);
      } else if (!isConnected && !_isOffline) {
        onConnectivityChanged(false);
      }
    } catch (e) {
      debugPrint('[CardQueueManager] Connectivity check error: $e');
    }
  }

  /// Start auto-reveal timer
  void _startAutoRevealTimer() {
    _autoRevealTimer?.cancel();
    _autoRevealTimer = Timer(const Duration(seconds: 3), () {
      if (_offlineCardState == OfflineCardState.connectedWaiting) {
        debugPrint('[CardQueueManager] Auto-revealing cards');
        _offlineCardState = OfflineCardState.autoRevealing;
        notifyListeners();
      }
    });
  }

  /// Cancel auto-reveal timer
  void _cancelAutoRevealTimer() {
    _autoRevealTimer?.cancel();
    _autoRevealTimer = null;
  }

  /// Called when user attempts to dismiss the offline card
  /// Returns true if dismiss was successful, false if should re-show
  Future<bool> onOfflineCardDismissed() async {
    debugPrint('[CardQueueManager] User attempting to dismiss offline card');

    // Check current connectivity
    try {
      final results = await _connectivity.checkConnectivity();
      final isConnected = results.isNotEmpty &&
          !results.contains(ConnectivityResult.none);

      if (!isConnected) {
        // Still offline, reject dismiss and re-show
        debugPrint('[CardQueueManager] Rejecting dismiss - still offline');
        _offlineCardState = OfflineCardState.visibleOffline;
        notifyListeners();
        return false;
      }

      // Connection is back, allow dismiss
      debugPrint('[CardQueueManager] Accepting dismiss - connection restored');
      _resetToNormal();
      return true;
    } catch (e) {
      debugPrint('[CardQueueManager] Error checking connectivity: $e');
      // Assume offline on error
      _offlineCardState = OfflineCardState.visibleOffline;
      notifyListeners();
      return false;
    }
  }

  /// Force dismiss the offline card (for programmatic dismiss)
  void forceDismiss() {
    debugPrint('[CardQueueManager] Force dismissing offline card');
    _resetToNormal();
  }

  /// Reset to normal state
  void _resetToNormal() {
    _offlineCardState = OfflineCardState.hidden;
    _isOffline = false;
    _stopConnectivityMonitoring();
    _cancelAutoRevealTimer();
    _stableConnectionTimer?.cancel();
    notifyListeners();
  }

  /// Pause monitoring (e.g., when app is backgrounded)
  void pauseMonitoring() {
    if (_connectivityTimer != null) {
      debugPrint('[CardQueueManager] Pausing monitoring');
      _connectivityTimer?.cancel();
    }
  }

  /// Resume monitoring (e.g., when app is foregrounded)
  void resumeMonitoring() {
    if (shouldShowOfflineCard) {
      debugPrint('[CardQueueManager] Resuming monitoring');
      _startConnectivityMonitoring();
      // Immediate check
      _checkConnectivity();
    }
  }

  /// Manually check connection and update state
  Future<void> checkConnection() async {
    await _checkConnectivity();
  }

  @override
  void dispose() {
    _stopConnectivityMonitoring();
    _cancelAutoRevealTimer();
    _stableConnectionTimer?.cancel();
    super.dispose();
  }
}
