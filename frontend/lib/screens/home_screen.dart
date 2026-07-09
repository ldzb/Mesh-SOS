// path: frontend/lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sos_message.dart';
import '../services/p2p_service.dart';
import '../services/sync_service.dart';
import '../database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final P2PService _p2pService = P2PService();
  final SyncService _syncService = SyncService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  final List<SosMessage> _receivedMessages = [];

  @override
  void initState() {
    super.initState();
    
    // 앱이 켜지자마자 가장 먼저 권한 팝업을 띄움
    _requestPermissions().then((_) {
      // 권한 요청이 끝나면(허락하든 안 하든) 네트워크 상태 감시 시작
      _syncService.startMonitoring();
      
      // P2P로 진짜 메시지가 들어왔을 때의 처리 로직
      _p2pService.onMessageReceived = (message) async {
        await _dbHelper.insertMessage(message);
        setState(() {
          _receivedMessages.insert(0, message);
        });
        // 메시지 수신 즉시 서버로 강제 동기화 시도
        _syncService.forceSync();
      };
    });
  }

  // 📱 안드로이드 & iOS 필수 권한 요청 함수
  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.nearbyWifiDevices,
    ].request();

    // 터미널 디버그용 출력
    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
        print('${permission.toString()} 권한이 거부되었습니다.');
      }
    });

    if (allGranted) {
      print('✅ 모든 필수 권한이 허용되었습니다. P2P 통신을 시작할 수 있습니다.');
    } else {
      print('⚠️ 일부 권한이 거부되어 기능이 제한될 수 있습니다.');
    }
  }

  // 1대의 기기로 A -> B -> Server 흐름을 흉내내는 테스트 함수
  Future<void> _simulateReceiveAndSync() async {
    final mockMessage = SosMessage(
      senderId: "Test_Device_A_${DateTime.now().second}",
      latitude: 37.5665,
      longitude: 126.9780,
      message: "테스트 구조 요청입니다!",
      timestamp: DateTime.now(),
    );

    await _dbHelper.insertMessage(mockMessage);
    
    setState(() {
      _receivedMessages.insert(0, mockMessage);
    });

    await _syncService.forceSync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mesh-SOS 테스트 노드')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _simulateReceiveAndSync,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              ),
              child: Text("테스트: 가상 SOS 수신 및 서버 동기화", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _receivedMessages.length,
              itemBuilder: (context, index) {
                final msg = _receivedMessages[index];
                return ListTile(
                  leading: Icon(Icons.warning, color: Colors.orange),
                  title: Text('발신자: ${msg.senderId}'),
                  subtitle: Text('${msg.message}\n${DateFormat('HH:mm:ss').format(msg.timestamp)}'),
                  isThreeLine: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}