import Flutter
import UIKit
import SmileID
import SwiftUI

class SmileIDBiometricKYC : NSObject, FlutterPlatformView, BiometricKycResultDelegate {
    private var _view: UIView
    private var _channel: FlutterMethodChannel
    private var _childViewController: UIViewController?
    
    static let VIEW_TYPE_ID = "SmileIDBiometricKYC"
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: [String: Any?],
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = UIView()
        _channel = FlutterMethodChannel(
            name: "\(SmileIDBiometricKYC.VIEW_TYPE_ID)_\(viewId)",
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

        let screen = SmileID.biometricKycScreen(
            idInfo: IdInfo(
                country:  args["country"] as? String ?? "",
                idType:  args["idType"] as? String,
                idNumber:  args["idNumber"] as? String,
                firstName:  args["firstName"] as? String,
                middleName:  args["middleName"] as? String,
                lastName:  args["lastName"] as? String,
                dob:  args["dob"] as? String,
                bankCode:  args["bankCode"] as? String,
                entered:  args["entered"] as? Bool
            ),
            userId: args["userId"] as? String ?? generateUserId(),
            jobId: args["jobId"] as? String ?? generateJobId(),
            allowNewEnroll: args["allowNewEnroll"] as? Bool ?? false,
            allowAgentMode: args["allowAgentMode"] as? Bool ?? false,
            showAttribution: args["showAttribution"] as? Bool ?? true,
            showInstructions: args["showInstructions"] as? Bool ?? true,
            smileSensitivity: SmileSensitivity.from(args["smileSensitivity"] as? String),
            useStrictMode: args["useStrictMode"] as? Bool ?? false,
            extraPartnerParams: args["extraPartnerParams"] as? [String: String] ?? [:],
            consentInformation: consentInformation,
            delegate: self
        )
        _childViewController = embedView(screen, in: _view, frame: frame)
    }
    
    func view() -> UIView {
        return _view
    }
    
    func didSucceed(selfieImage: URL, livenessImages: [URL], didSubmitBiometricJob: Bool) {
        _childViewController?.removeFromParent()
        let arguments: [String: Any] = [
            "selfieFile": selfieImage.absoluteString,
            "livenessFiles": livenessImages.map {
                $0.absoluteString
            },
            "didSubmitBiometricKycJob": didSubmitBiometricJob,
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
            return SmileIDBiometricKYC(
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
