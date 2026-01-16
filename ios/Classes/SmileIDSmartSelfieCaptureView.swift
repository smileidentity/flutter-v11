import Combine
import Flutter
import SmileID
import SwiftUI

class SmileIDSmartSelfieCaptureView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var _childViewController: UIViewController?
    private let _viewModel: SelfieViewModel
    private let _channel: FlutterMethodChannel

    static let VIEW_TYPE_ID = "SmileIDSmartSelfieCaptureView"

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: [String: Any?],
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        let showConfirmationDialog = args["showConfirmationDialog"] as? Bool ?? true
        let showInstructions = args["showInstructions"] as? Bool ?? true
        let showAttribution = args["showAttribution"] as? Bool ?? true
        let allowAgentMode = args["allowAgentMode"] as? Bool ?? true
        let useStrictMode = args["useStrictMode"] as? Bool ?? false
        let smileSensitivity = SmileSensitivity.from(args["smileSensitivity"] as? String)

        _viewModel = SelfieViewModel(
            isEnroll: false,
            userId: generateUserId(),
            jobId: generateJobId(),
            allowNewEnroll: false,
            skipApiSubmission: true,
            extraPartnerParams: [:]
        )

        _view = UIView()
        _channel = FlutterMethodChannel(
            name: "\(SmileIDSmartSelfieCaptureView.VIEW_TYPE_ID)_\(viewId)",
            binaryMessenger: messenger
        )
        _childViewController = nil

        super.init()

        let rootView = SmileIDRootView(
            viewModel: _viewModel,
            showConfirmationDialog: showConfirmationDialog,
            showInstructions: showInstructions,
            allowAgentMode: allowAgentMode,
            showAttribution: showAttribution,
            useStrictMode: useStrictMode,
            smileSensitivity: smileSensitivity,
            channel: _channel
        )
        _childViewController = embedView(rootView, in: _view, frame: frame)
    }

    func view() -> UIView {
        return _view
    }
}

struct SmileIDRootView: View {
    @ObservedObject var viewModel: SelfieViewModel
    @State private var acknowledgedInstructions = false
    let showConfirmationDialog: Bool
    let showInstructions: Bool
    let allowAgentMode: Bool
    let showAttribution: Bool
    let useStrictMode: Bool
    let smileSensitivity: SmileSensitivity
    let channel: FlutterMethodChannel
    static let shared = FileManager()
    private let fileManager = Foundation.FileManager.default

    var body: some View {
        selfieCaptureScreen
            .preferredColorScheme(.light)
    }

    private var selfieCaptureScreen: some View {
        ZStack {
            if useStrictMode {
                SmileID.smartSelfieEnrollmentScreenEnhanced(
                    userId: generateUserId(),
                    showAttribution: showAttribution,
                    showInstructions: showInstructions,
                    skipApiSubmission: true,
                    delegate: self
                )
            } else {
                legacySelfieCaptureScreen
            }
        }
    }

    private var legacySelfieCaptureScreen: some View {
        ZStack {
            if showInstructions, !acknowledgedInstructions {
                SmartSelfieInstructionsScreen(showAttribution: showAttribution) {
                    acknowledgedInstructions = true
                }
                .padding()
            } else if viewModel.processingState != nil {
                Color.clear.onAppear {
                    self.viewModel.onFinished(callback: self)
                }
            } else if let selfieToConfirm = viewModel.selfieToConfirm {
                if showConfirmationDialog {
                    ImageCaptureConfirmationDialog(
                        title: SmileIDResourcesHelper.localizedString(
                            for: "Confirmation.GoodSelfie"),
                        subtitle: SmileIDResourcesHelper.localizedString(
                            for: "Confirmation.FaceClear"),
                        image: UIImage(data: selfieToConfirm)!,
                        confirmationButtonText: SmileIDResourcesHelper.localizedString(
                            for: "Confirmation.YesUse"),
                        onConfirm: viewModel.submitJob,
                        retakeButtonText: SmileIDResourcesHelper.localizedString(
                            for: "Confirmation.Retake"),
                        onRetake: viewModel.onSelfieRejected,
                        scaleFactor: 1.25
                    )
                    .preferredColorScheme(.light)
                } else {
                    Color.clear.onAppear {
                        self.viewModel.submitJob()
                    }
                }
            } else {
                SelfieCaptureScreen(
                    viewModel: viewModel,
                    allowAgentMode: allowAgentMode,
                    smileSensitivity: smileSensitivity,
                ).preferredColorScheme(.light)
            }
        }
    }

    private func encodeToJSONString<T: Encodable>(_ value: T) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonData = try? encoder.encode(value) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }

    private func sendSuccessMessage(with arguments: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: arguments, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                channel.invokeMethod("onSuccess", arguments: jsonString)
            }
        } catch {
            channel.invokeMethod("onError", arguments: error.localizedDescription)
        }
    }
}

extension SmileIDRootView: SmartSelfieResultDelegate {
    func didSucceed(selfieImage: URL, livenessImages: [URL], apiResponse: SmartSelfieResponse?) {
        var arguments: [String: Any] = [
            "selfieFile": selfieImage.absoluteString,
            "livenessFiles": livenessImages.map { $0.absoluteString },
        ]
        if let apiResponse = apiResponse {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            if let jsonData = try? encoder.encode(apiResponse),
                let jsonString = String(data: jsonData, encoding: .utf8)
            {
                arguments["apiResponse"] = jsonString
            }
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: arguments, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                channel.invokeMethod("onSuccess", arguments: jsonString)
            }
        } catch {
            didError(error: error)
        }
    }

    func didError(error: Error) {
        channel.invokeMethod("onError", arguments: error.localizedDescription)
    }
}

// MARK: - Factory

extension SmileIDSmartSelfieCaptureView {
    class Factory: NSObject, FlutterPlatformViewFactory {
        private let messenger: FlutterBinaryMessenger

        init(messenger: FlutterBinaryMessenger) {
            self.messenger = messenger
            super.init()
        }

        func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
            -> FlutterPlatformView
        {
            return SmileIDSmartSelfieCaptureView(
                frame: frame,
                viewIdentifier: viewId,
                arguments: args as? [String: Any?] ?? [:],
                binaryMessenger: messenger
            )
        }

        func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
            return FlutterStandardMessageCodec.sharedInstance()
        }
    }
}
