import Flutter
import UIKit
import SmileID
import SwiftUI

class SmileIDEnhancedDocumentVerification : NSObject, FlutterPlatformView, EnhancedDocumentVerificationResultDelegate {
    private var _view: UIView
    private var _channel: FlutterMethodChannel
    private var _childViewController: UIViewController?
    
    static let VIEW_TYPE_ID = "SmileIDEnhancedDocumentVerification"
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: [String: Any?],
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        _channel = FlutterMethodChannel(
            name: "\(SmileIDEnhancedDocumentVerification.VIEW_TYPE_ID)_\(viewId)",
            binaryMessenger: messenger
        )
        _childViewController = nil
        super.init()

        let consentInformation: ConsentInformation? = {
            guard
                let consentGrantedDate = args["consentGrantedDate"] as? String,
                let personalDetails = args["personalDetailsConsentGranted"] as? Bool,
                let contactInformation = args["contactInfoConsentGranted"] as? Bool,
                let documentInformation = args["documentInfoConsentGranted"] as? Bool
            else {
                return nil
            }

            return ConsentInformation(
                consented: ConsentedInformation(
                    consentGrantedDate: consentGrantedDate,
                    personalDetails: personalDetails,
                    contactInformation: contactInformation,
                    documentInformation: documentInformation
                )
            )
        }()

        let bypassSelfieCaptureWithFile = (args["bypassSelfieCaptureWithFile"] as? String)
            .flatMap { URL(string: $0) }

        let screen = SmileID.enhancedDocumentVerificationScreen(
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
            skipApiSubmission: args["skipApiSubmission"] as? Bool ?? false,
            showAttribution: args["showAttribution"] as? Bool ?? true,
            useStrictMode: args["useStrictMode"] as? Bool ?? false,
            extraPartnerParams: args["extraPartnerParams"] as? [String: String] ?? [:],
            consentInformation: consentInformation,
            delegate: self
        )
        let navView = NavigationView{screen}
        _childViewController = embedView(navView, in: _view, frame: frame)
    }
    
    func view() -> UIView {
        return _view
    }
    
    func didSucceed(selfie: URL, documentFrontImage: URL, documentBackImage: URL?, didSubmitEnhancedDocVJob: Bool) {
        _childViewController?.removeFromParent()
        let arguments: [String: Any] = [
            "selfieFile": selfie.absoluteString,
            "documentFrontFile": documentFrontImage.absoluteString,
            "didSubmitEnhancedDocVJob": didSubmitEnhancedDocVJob
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
            return SmileIDEnhancedDocumentVerification(
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
