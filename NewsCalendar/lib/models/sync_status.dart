// Tracks sync state
class SyncStatus {
  final DateTime lastSync;
  final bool isSyncing;
  final int pendingOperations;

  SyncStatus({
    required this.lastSync,
    required this.isSyncing,
    required this.pendingOperations,
  });
}
