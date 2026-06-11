// path: frontend/ios/Runner/AppDelegate.swift
import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    private var multipeerManager: MultipeerManager?
    private var methodChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // 1. 플러터 기본 플러그인 등록
        GeneratedPluginRegistrant.register(with: self)
        
        // 2. 유령 엔진 생성을 막기 위한 안전한 채널 연결 방식
        // window?.rootViewController를 절대 사용하지 않고, 앱 델리게이트 자체의 registrar를 호출합니다.
        let registrar = self.registrar(forPlugin: "com.ldzb.mesh_sos.p2p")!
        methodChannel = FlutterMethodChannel(name: "com.ldzb.mesh_sos/p2p", binaryMessenger: registrar.messenger())
        
        // 3. P2P 매니저 초기화 및 통신 채널(MethodChannel) 수신부 연결
        multipeerManager = MultipeerManager()
        multipeerManager?.onMessageReceived = { [weak self] message in
            self?.methodChannel?.invokeMethod("onMessageReceived", arguments: message)
        }
        
        // 4. 플러터 -> 네이티브 함수 호출 핸들러 세팅
        methodChannel?.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "startP2P":
                self?.multipeerManager?.start()
                result(nil)
            case "stopP2P":
                self?.multipeerManager?.stop()
                result(nil)
            case "sendSos":
                if let args = call.arguments as? [String: Any] {
                    self?.multipeerManager?.sendSosMessage(data: args)
                }
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        })

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}