import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sos_message.dart';
import '../services/p2p_service.dart';
import '../services/sync_service.dart';
import '../database/database_helper.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final P2PService _p2pService = P2PService();
  final SyncService _syncService = SyncService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  final List<SosMessage> _receivedMessages = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _syncService.startMonitoring();
    
    _p2pService.onMessageReceived = (message) async {
      await _dbHelper.insertMessage(message);
      setState(() {
        _receivedMessages.insert(0, message);
      });
    };
  }

  void _toggleP2P() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _p2pService.startP2P();
      } else {
        _p2pService.stopP2P();
      }
    });
  }

  void _sendTestSos() {
    final testMsg = SosMessage(
      senderId: "Device-${DateTime.now().millisecond}",
      latitude: 37.5665,
      longitude: 126.9780,
      message: "HELP! Test SOS",
      timestamp: DateTime.now(),
    );
    _p2pService.sendSos(testMsg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesh-SOS MVP'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.portable_wifi_off : Icons.wifi_tethering),
            onPressed: _toggleP2P,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _sendTestSos,
              child: Text('SEND EMERGENCY SOS', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _receivedMessages.length,
              itemBuilder: (context, index) {
                final msg = _receivedMessages[index];
                return ListTile(
                  leading: Icon(Icons.warning, color: Colors.orange),
                  title: Text('From: ${msg.senderId}'),
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
