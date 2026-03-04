/// Enum representing the different states of the offline card.
enum OfflineCardState {
  /// Card is hidden (normal operation)
  hidden,

  /// Card is visible showing offline state
  visibleOffline,

  /// Connection restored, waiting for user action or auto-reveal
  connectedWaiting,

  /// Auto-revealing pending cards
  autoRevealing,
}

/// Extension to provide helper methods for OfflineCardState
extension OfflineCardStateExtension on OfflineCardState {
  /// Whether the card should be visible
  bool get isVisible =>
      this == OfflineCardState.visibleOffline ||
      this == OfflineCardState.connectedWaiting;

  /// Whether the card shows offline UI
  bool get showsOfflineUI => this == OfflineCardState.visibleOffline;

  /// Whether the card shows connected UI
  bool get showsConnectedUI => this == OfflineCardState.connectedWaiting;

  /// Whether auto-reveal is in progress
  bool get isAutoRevealing => this == OfflineCardState.autoRevealing;
}
