import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Enum representing the different connectivity states.
enum ConnectivityStatus {
  /// Connected via WiFi
  wifi,

  /// Connected via mobile data
  mobile,

  /// Connected via ethernet
  ethernet,

  /// No connectivity
  none,

  /// Connectivity status is unknown
  unknown,
}

/// Provider for managing network connectivity state.
///
/// Listens to connectivity changes and provides the current
/// connectivity status to the app.
class ConnectivityProvider extends ChangeNotifier {
  /// Current connectivity status
  ConnectivityStatus _status = ConnectivityStatus.unknown;

  /// List of current connectivity results
  List<ConnectivityResult> _connectionStatus = [];

  /// Stream subscription for connectivity changes
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Connectivity instance
  final Connectivity _connectivity;

  /// Whether the provider is currently listening for changes
  bool _isListening = false;

  /// Creates a new ConnectivityProvider instance.
  ///
  /// [connectivity] - The connectivity instance to use.
  ///                  Defaults to Connectivity().
  ConnectivityProvider({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Getter for current connectivity status
  ConnectivityStatus get status => _status;

  /// Getter for connection status list
  List<ConnectivityResult> get connectionStatus => _connectionStatus;

  /// Getter for whether connected to any network
  bool get isConnected =>
      _status != ConnectivityStatus.none && _status != ConnectivityStatus.unknown;

  /// Getter for whether connected via WiFi
  bool get isWifi => _status == ConnectivityStatus.wifi;

  /// Getter for whether connected via mobile data
  bool get isMobile => _status == ConnectivityStatus.mobile;

  /// Getter for whether connected via ethernet
  bool get isEthernet => _status == ConnectivityStatus.ethernet;

  /// Getter for whether there's no connectivity
  bool get isDisconnected =>
      _status == ConnectivityStatus.none || _status == ConnectivityStatus.unknown;

  /// Getter for whether provider is listening
  bool get isListening => _isListening;

  /// Getter for status as a human-readable string
  String get statusText {
    switch (_status) {
      case ConnectivityStatus.wifi:
        return 'WiFi';
      case ConnectivityStatus.mobile:
        return 'Mobile Data';
      case ConnectivityStatus.ethernet:
        return 'Ethernet';
      case ConnectivityStatus.none:
        return 'No Connection';
      case ConnectivityStatus.unknown:
        return 'Unknown';
    }
  }

  /// Getter for whether status is good (has active connection)
  bool get hasGoodConnection =>
      _status == ConnectivityStatus.wifi ||
      _status == ConnectivityStatus.mobile ||
      _status == ConnectivityStatus.ethernet;

  /// Initializes the provider by checking current connectivity
  /// and starting to listen for changes.
  Future<void> initialize() async {
    // Check initial connectivity
    await checkConnectivity();

    // Start listening for changes
    startListening();
  }

  /// Checks the current connectivity status.
  ///
  /// Updates [_status] and [_connectionStatus] based on the result.
  Future<void> checkConnectivity() async {
    try {
      _connectionStatus = await _connectivity.checkConnectivity();
      _updateStatus();
      notifyListeners();
    } catch (e) {
      _status = ConnectivityStatus.unknown;
      _connectionStatus = [];
      notifyListeners();
    }
  }

  /// Starts listening for connectivity changes.
  void startListening() {
    if (_isListening) return;

    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        _connectionStatus = result;
        _updateStatus();
        notifyListeners();
      },
      onError: (error) {
        _status = ConnectivityStatus.unknown;
        notifyListeners();
      },
    );

    _isListening = true;
  }

  /// Stops listening for connectivity changes.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }

  /// Updates the status based on connection results.
  void _updateStatus() {
    if (_connectionStatus.isEmpty ||
        _connectionStatus.contains(ConnectivityResult.none)) {
      _status = ConnectivityStatus.none;
      return;
    }

    // Check for specific connection types (priority: wifi > mobile > ethernet)
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      _status = ConnectivityStatus.wifi;
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      _status = ConnectivityStatus.mobile;
    } else if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      _status = ConnectivityStatus.ethernet;
    } else if (_connectionStatus.contains(ConnectivityResult.vpn)) {
      // VPN counts as connected but we don't have a specific status for it
      _status = ConnectivityStatus.wifi;
    } else if (_connectionStatus.contains(ConnectivityResult.other)) {
      // Other connection types
      _status = ConnectivityStatus.wifi;
    } else {
      _status = ConnectivityStatus.unknown;
    }
  }

  /// Gets the status as an IconData for UI display.
  IconData get statusIcon {
    switch (_status) {
      case ConnectivityStatus.wifi:
        return Icons.wifi;
      case ConnectivityStatus.mobile:
        return Icons.signal_cellular_alt;
      case ConnectivityStatus.ethernet:
        return Icons.cable;
      case ConnectivityStatus.none:
        return Icons.wifi_off;
      case ConnectivityStatus.unknown:
        return Icons.signal_wifi_off;
    }
  }

  /// Gets the status as a Color for UI display.
  Color get statusColor {
    switch (_status) {
      case ConnectivityStatus.wifi:
        return Colors.green;
      case ConnectivityStatus.mobile:
        return Colors.blue;
      case ConnectivityStatus.ethernet:
        return Colors.purple;
      case ConnectivityStatus.none:
        return Colors.red;
      case ConnectivityStatus.unknown:
        return Colors.grey;
    }
  }

  /// Checks if a specific connection type is available.
  ///
  /// [result] - The connectivity result to check.
  bool hasConnectionType(ConnectivityResult result) {
    return _connectionStatus.contains(result);
  }

  /// Resets the provider to its initial state.
  void reset() {
    stopListening();
    _status = ConnectivityStatus.unknown;
    _connectionStatus = [];
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
