import Flutter
import UIKit
import SmileID
import SwiftUI

class SmileIDDocumentVerification : NSObject, FlutterPlatformView, DocumentVerificationResultDelegate {
    private var _view: UIView
    private var _channel: FlutterMethodChannel
    private var _childViewController: UIViewController?

    static let VIEW_TYPE_ID = "SmileIDDocumentVerification"

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: [String: Any?],
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        _channel = FlutterMethodChannel(
            name: "\(SmileIDDocumentVerification.VIEW_TYPE_ID)_\(viewId)",
            binaryMessenger: messenger
        )
        _childViewController = nil
        super.init()
        let bypassSelfieCaptureWithFile = (args["bypassSelfieCaptureWithFile"] as? String)
            .flatMap { URL(string: $0) }
        let screen = SmileID.documentVerificationScreen(
            userId: args["userId"] as? String ?? "user-\(UUID().uuidString)",
            jobId: args["jobId"] as? String ?? "job-\(UUID().uuidString)",
            allowNewEnroll: args["allowNewEnroll"] as? Bool ?? false,
            countryCode: args["countryCode"] as! String,
            documentType: args["documentType"] as? String,
            idAspectRatio: args["idAspectRatio"] as? Double,
            bypassSelfieCaptureWithFile: bypassSelfieCaptureWithFile,
            autoCaptureTimeout: (args["autoCaptureTimeout"] as? Int).map { TimeInterval($0) / 1000.0 } ?? 10.0,
            autoCapture: AutoCapture.from(args["autoCapture"] as? String),
            captureBothSides: args["captureBothSides"] as? Bool ?? true,
            allowAgentMode: args["allowAgentMode"] as? Bool ?? false,
            allowGalleryUpload: args["allowGalleryUpload"] as? Bool ?? false,
            showInstructions: args["showInstructions"] as? Bool ?? true,
            showAttribution: args["showAttribution"] as? Bool ?? true,
            smileSensitivity: SmileSensitivity.from(args["smileSensitivity"] as? String),
            skipApiSubmission: args["skipApiSubmission"] as? Bool ?? false,
            useStrictMode: args["useStrictMode"] as? Bool ?? false,
            extraPartnerParams: args["extraPartnerParams"] as? [String: String] ?? [:],
            delegate: self
        )
        _childViewController = embedView(screen, in: _view, frame: frame)
    }

    func view() -> UIView {
        return _view
    }
    
    func didSucceed(selfie: URL, documentFrontImage: URL, documentBackImage: URL?, didSubmitDocumentVerificationJob: Bool) {
        _childViewController?.removeFromParent()
        let arguments: [String: Any] = [
            "selfieFile": selfie.absoluteString,
            "documentFrontFile": documentFrontImage.absoluteString,
            "didSubmitDocumentVerificationJob": didSubmitDocumentVerificationJob
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: arguments, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                _channel.invokeMethod("onSuccess", arguments: jsonString)
            }
        } catch {
            didError(error: error)
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
            return SmileIDDocumentVerification(
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
