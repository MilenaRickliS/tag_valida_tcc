import 'package:shared_preferences/shared_preferences.dart';

class SyncStatusService {
  static const String _keyLastSyncMs = 'last_sync_ms';
  static const String _keySyncStatus = 'last_sync_status';

  static Future<void> setPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySyncStatus, 'pending');
  }

  static Future<void> setSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySyncStatus, 'success');
    await prefs.setInt(
      _keyLastSyncMs,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<void> setError() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySyncStatus, 'error');
  }

  static Future<Map<String, dynamic>> getStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final ms = prefs.getInt(_keyLastSyncMs);
    final status = prefs.getString(_keySyncStatus) ?? 'pending';

    return {
      'status': status,
      'lastSync': ms != null
          ? DateTime.fromMillisecondsSinceEpoch(ms)
          : null,
    };
  }
}