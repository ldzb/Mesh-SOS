// path: frontend/lib/services/sync_service.dart
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../database/database_helper.dart';
import '../models/sos_message.dart';

/**
 * 네트워크 연결 감지 및 서버 동기화 로직
 * - 로컬 테스트를 위해 127.0.0.1:8080 사용 (iOS 시뮬레이터 기준 맥북 로컬 서버 접근)
 */
class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  // iOS 시뮬레이터에서 로컬 호스트(맥북)에 띄운 스프링 부트로 접근하는 IP
  final String serverUrl = "http://127.0.0.1:8080/api/v1/sync/bulk";

  void startMonitoring() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // 네트워크 연결이 감지되면 자동으로 서버 동기화 시도
      if (results.any((r) => r != ConnectivityResult.none)) {
        forceSync();
      }
    });
  }

  // 외부(버튼 등)에서 강제로 동기화를 트리거할 수 있도록 public 메서드로 개방
  Future<void> forceSync() async {
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
      } else {
        print("Server returned status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Sync failed: $e");
    }
  }
}
