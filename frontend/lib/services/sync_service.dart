// path: frontend/lib/services/sync_service.dart
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../database/database_helper.dart';
import '../models/sos_message.dart';

/**
 * 네트워크 연결 감지 및 서버 동기화 로직
 * - 로컬 테스트를 위해 127.0.0.1:8080 사용 (iOS 시뮬레이터 기준)
 * - 실물 기기 테스트 시에는 서버 PC의 사설 IP로 변경 필요
 */
class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final String serverUrl = "http://127.0.0.1:8080/api/v1/sync/bulk";

  void startMonitoring() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        _syncPendingMessages();
      }
    });
  }

  Future<void> _syncPendingMessages() async {
    final pending = await _dbHelper.getUnsyncedMessages();
    if (pending.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(pending.map((m) => m.toMap()).toList()),
      );

      if (response.statusCode == 200) {
        await _dbHelper.markAsSynced(pending.map((m) => m.id).toList());
        print("Successfully synced ${pending.length} messages to server.");
      }
    } catch (e) {
      print("Sync failed: $e");
    }
  }
}
