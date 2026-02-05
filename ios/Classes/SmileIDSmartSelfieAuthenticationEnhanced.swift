import Flutter
import UIKit
import SmileID
import SwiftUI

class SmileIDSmartSelfieAuthenticationEnhanced : NSObject, FlutterPlatformView, SmartSelfieResultDelegate {
    private var _view: UIView
    private var _channel: FlutterMethodChannel
    private var _childViewController: UIViewController?

    static let VIEW_TYPE_ID = "SmileIDSmartSelfieAuthenticationEnhanced"

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: [String: Any?],
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        _channel = FlutterMethodChannel(
            name: "\(SmileIDSmartSelfieAuthenticationEnhanced.VIEW_TYPE_ID)_\(viewId)",
            binaryMessenger: messenger
        )
        _childViewController = nil
        super.init()
        let screen = EnhancedSelfieAuthenticationRootView(
            userId: args["userId"] as? String ?? "user-\(UUID().uuidString)",
            allowNewEnroll: args["allowNewEnroll"] as? Bool ?? false,
            showAttribution: args["showAttribution"] as? Bool ?? true,
            showInstructions: args["showInstructions"] as? Bool ?? true,
            skipApiSubmission: args["skipApiSubmission"] as? Bool ?? false,
            extraPartnerParams: args["extraPartnerParams"] as? [String: String] ?? [:],
            delegate: self
        )
        _childViewController = embedView(screen, in: _view, frame: frame)
    }

    func view() -> UIView {
        return _view
    }

    func didSucceed(selfieImage: URL, livenessImages: [URL], apiResponse: SmartSelfieResponse?) {
        _childViewController?.removeFromParent()
        let successData = SmartSelfieSuccessData(
            selfieFile: selfieImage.absoluteString,
            livenessFiles: livenessImages.map {
                $0.absoluteString
            },
            apiResponse: apiResponse
        )

        if let jsonString = successData.toJSONString() {
            _channel.invokeMethod("onSuccess", arguments: jsonString)
        }
    }

    func didError(error: Error) {
        print("[Smile ID] An error occurred - \(error.localizedDescription)")
        _channel.invokeMethod("onError", arguments: error.localizedDescription)
    }

    class Factory : NSObject, FlutterPlatformViewFactory {
        private var messenger: FlutterBinaryMessenger
        init(messenger: FlutterBinaryMessenger) {
            self.messenger = messenger
            super.init()
        }

        func create(
            withFrame frame: CGRect,
            viewIdentifier viewId: Int64,
            arguments args: Any?
        ) -> FlutterPlatformView {
            return SmileIDSmartSelfieAuthenticationEnhanced(
                frame: frame,
                viewIdentifier: viewId,
                arguments: args as! [String: Any?],
                binaryMessenger: messenger
            )
        }

        public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
              return FlutterStandardMessageCodec.sharedInstance()
        }
    }
}

struct EnhancedSelfieAuthenticationRootView: View {
    let userId: String
    let allowNewEnroll: Bool
    let showAttribution: Bool
    let showInstructions: Bool
    let skipApiSubmission: Bool
    let extraPartnerParams: [String: String]
    let delegate: SmartSelfieResultDelegate

    var body: some View {
        NavigationView {
            SmileID.smartSelfieAuthenticationScreenEnhanced(
                userId: userId,
                allowNewEnroll: allowNewEnroll,
                showAttribution: showAttribution,
                showInstructions: showInstructions,
                skipApiSubmission: skipApiSubmission,
                extraPartnerParams: extraPartnerParams,
                delegate: delegate
            )
        }
    }
}
