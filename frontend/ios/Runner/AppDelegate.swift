import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  
  private var multipeerManager: MultipeerManager?
  private var methodChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    methodChannel = FlutterMethodChannel(name: "com.ldzb.mesh_sos/p2p",
                                              binaryMessenger: controller.binaryMessenger)
    
    multipeerManager = MultipeerManager()
    multipeerManager?.onMessageReceived = { [weak self] message in
        self?.methodChannel?.invokeMethod("onMessageReceived", arguments: message)
    }
    
    methodChannel?.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
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

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
