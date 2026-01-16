import Flutter
import UIKit
import SmileID
import SwiftUI

class SmileIDSmartSelfieEnrollmentEnhanced: NSObject, FlutterPlatformView, SmartSelfieResultDelegate
{
    private var _view: UIView
    private var _channel: FlutterMethodChannel
    private var _childViewController: UIViewController?

    static let VIEW_TYPE_ID = "SmileIDSmartSelfieEnrollmentEnhanced"

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: [String: Any?],
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        _channel = FlutterMethodChannel(
            name: "\(SmileIDSmartSelfieEnrollmentEnhanced.VIEW_TYPE_ID)_\(viewId)",
            binaryMessenger: messenger
        )
        _childViewController = nil
        super.init()
        let screen = EnhancedSelfieEnrollmentRootView.init(
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

    class Factory: NSObject, FlutterPlatformViewFactory {
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
            return SmileIDSmartSelfieEnrollmentEnhanced(
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

struct SmartSelfieSuccessData: Encodable {
    let selfieFile: String
    let livenessFiles: [String]
    let apiResponse: SmartSelfieResponse?

    func toJSONString() -> String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .withoutEscapingSlashes
        let json = try? jsonEncoder.encode(self)
        guard let data = json,
            let jsonString = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return jsonString
    }
}

struct EnhancedSelfieEnrollmentRootView: View {
    let userId: String
    let allowNewEnroll: Bool
    let showAttribution: Bool
    let showInstructions: Bool
    let skipApiSubmission: Bool
    let extraPartnerParams: [String: String]
    let delegate: SmartSelfieResultDelegate

    var body: some View {
        SmileID.smartSelfieEnrollmentScreenEnhanced(
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
