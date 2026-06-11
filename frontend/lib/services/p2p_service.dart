import 'package:flutter/services.dart';
import '../models/sos_message.dart';

class P2PService {
  static const _channel = MethodChannel('com.ldzb.mesh_sos/p2p');
  
  Function(SosMessage)? onMessageReceived;

  P2PService() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<void> _handleMethod(MethodCall call) async {
    if (call.method == 'onMessageReceived') {
      final Map<String, dynamic> args = Map<String, dynamic>.from(call.arguments);
      onMessageReceived?.call(SosMessage.fromMap(args));
    }
  }

  Future<void> startP2P() async {
    await _channel.invokeMethod('startP2P');
  }

  Future<void> stopP2P() async {
    await _channel.invokeMethod('stopP2P');
  }

  Future<void> sendSos(SosMessage message) async {
    await _channel.invokeMethod('sendSos', message.toMap());
  }
}
