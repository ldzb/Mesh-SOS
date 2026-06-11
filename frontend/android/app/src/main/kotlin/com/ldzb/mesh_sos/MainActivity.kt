// path: frontend/android/app/src/main/kotlin/com/ldzb/mesh_sos/MainActivity.kt
package com.ldzb.mesh_sos

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.nearby.Nearby
import com.google.android.gms.nearby.connection.*
import org.json.JSONObject
import java.nio.charset.StandardCharsets

/**
 * Android Nearby Connections API를 활용한 P2P 통신 브릿지
 * - Strategy.P2P_CLUSTER: 모든 기기가 서로 연결될 수 있는 Mesh 구조 지원
 * - MethodChannel: Flutter의 P2PService와 동일한 인터페이스 제공
 */
class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ldzb.mesh_sos/p2p"
    private var methodChannel: MethodChannel? = null
    
    // Nearby Connections 클라이언트 및 설정
    private val connectionsClient by lazy { Nearby.getConnectionsClient(this) }
    private val SERVICE_ID = "com.ldzb.mesh_sos.p2p"
    // 중앙 서버 없이 모두가 연결되는 거미줄(Mesh) 형태의 P2P 클러스터 전략
    private val STRATEGY = Strategy.P2P_CLUSTER 
    
    // 현재 연결된 기기들의 ID를 저장하는 셋
    private val connectedEndpoints = mutableSetOf<String>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 플러터와 통신할 채널 개통 (iOS와 이름이 완벽히 동일해야 함)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startP2P" -> {
                    startP2P()
                    result.success(null)
                }
                "stopP2P" -> {
                    stopP2P()
                    result.success(null)
                }
                "sendSos" -> {
                    val args = call.arguments as? Map<String, Any>
                    if (args != null) {
                        sendSosMessage(args)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startP2P() {
        startAdvertising()
        startDiscovery()
    }

    private fun stopP2P() {
        connectionsClient.stopAdvertising()
        connectionsClient.stopDiscovery()
        connectionsClient.stopAllEndpoints()
        connectedEndpoints.clear()
        Log.d("P2P", "Stopped all P2P operations.")
    }

    // 1. 내 존재를 주변에 알림 (Advertising)
    private fun startAdvertising() {
        val advertisingOptions = AdvertisingOptions.Builder().setStrategy(STRATEGY).build()
        val nickname = "Galaxy_Node_" + System.currentTimeMillis().toString().takeLast(4)
        
        connectionsClient.startAdvertising(nickname, SERVICE_ID, connectionLifecycleCallback, advertisingOptions)
            .addOnSuccessListener { Log.d("P2P", "Advertising started") }
            .addOnFailureListener { e -> Log.e("P2P", "Advertising failed: ", e) }
    }

    // 2. 주변 기기를 탐색함 (Discovery)
    private fun startDiscovery() {
        val discoveryOptions = DiscoveryOptions.Builder().setStrategy(STRATEGY).build()
        connectionsClient.startDiscovery(SERVICE_ID, endpointDiscoveryCallback, discoveryOptions)
            .addOnSuccessListener { Log.d("P2P", "Discovery started") }
            .addOnFailureListener { e -> Log.e("P2P", "Discovery failed: ", e) }
    }

    // 3. 누군가 발견되었을 때의 콜백
    private val endpointDiscoveryCallback = object : EndpointDiscoveryCallback() {
        override fun onEndpointFound(endpointId: String, info: DiscoveredEndpointInfo) {
            Log.d("P2P", "Found endpoint: $endpointId. Requesting connection...")
            // 발견 즉시 연결 요청
            connectionsClient.requestConnection("LocalNode", endpointId, connectionLifecycleCallback)
        }
        override fun onEndpointLost(endpointId: String) {}
    }

    // 4. 기기 간 연결 성사 및 끊김을 관리하는 콜백
    private val connectionLifecycleCallback = object : ConnectionLifecycleCallback() {
        override fun onConnectionInitiated(endpointId: String, connectionInfo: ConnectionInfo) {
            // 구조용 앱이므로, 보안 코드 확인 없이 무조건 연결 수락 (자동화)
            connectionsClient.acceptConnection(endpointId, payloadCallback)
        }

        override fun onConnectionResult(endpointId: String, result: ConnectionResolution) {
            if (result.status.isSuccess) {
                Log.d("P2P", "Connected to: $endpointId")
                connectedEndpoints.add(endpointId)
            } else {
                Log.d("P2P", "Connection failed with: $endpointId")
            }
        }

        override fun onDisconnected(endpointId: String) {
            Log.d("P2P", "Disconnected from: $endpointId")
            connectedEndpoints.remove(endpointId)
        }
    }

    // 5. 데이터를 주고받을 때의 콜백 (핵심!)
    private val payloadCallback = object : PayloadCallback() {
        override fun onPayloadReceived(endpointId: String, payload: Payload) {
            if (payload.type == Payload.Type.BYTES) {
                val byteData = payload.asBytes()
                if (byteData != null) {
                    val jsonString = String(byteData, StandardCharsets.UTF_8)
                    Log.d("P2P", "Received message: $jsonString")
                    
                    try {
                        val jsonObject = JSONObject(jsonString)
                        val messageMap = jsonObject.toMap()
                        
                        // 받은 데이터를 메인 스레드에서 플러터(Dart)로 쏘아 올림
                        runOnUiThread {
                            methodChannel?.invokeMethod("onMessageReceived", messageMap)
                        }
                    } catch (e: Exception) {
                        Log.e("P2P", "Failed to parse JSON", e)
                    }
                }
            }
        }
        override fun onPayloadTransferUpdate(endpointId: String, update: PayloadTransferUpdate) {}
    }

    // 6. 플러터에서 SOS 전송 버튼을 눌렀을 때 실행되는 함수
    private fun sendSosMessage(data: Map<String, Any>) {
        if (connectedEndpoints.isEmpty()) {
            Log.w("P2P", "No connected devices to send SOS.")
            return
        }

        try {
            val jsonObject = JSONObject(data)
            val bytes = jsonObject.toString().toByteArray(StandardCharsets.UTF_8)
            val payload = Payload.fromBytes(bytes)
            
            // 연결된 모든 기기(Mesh)에게 데이터를 브로드캐스트
            connectionsClient.sendPayload(connectedEndpoints.toList(), payload)
            Log.d("P2P", "SOS sent to ${connectedEndpoints.size} devices.")
        } catch (e: Exception) {
            Log.e("P2P", "Failed to send SOS", e)
        }
    }

    // JSONObject를 Map으로 변환하는 확장 함수 (Flutter로 넘기기 위함)
    private fun JSONObject.toMap(): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        val keysItr = this.keys()
        while (keysItr.hasNext()) {
            val key = keysItr.next()
            val value = this.get(key)
            map[key] = value
        }
        return map
    }
}
