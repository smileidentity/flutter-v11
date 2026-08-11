import Flutter
import SwiftUI
import UIKit

extension FlutterPlatformView {
    /// Embeds a SwiftUI view into a UIKit view hierarchy for a view class that conforms to `FlutterPlatformView`
    /// - Parameters:
    ///   - swiftUIView: The SwiftUI view to be integrated. This can be any view conforming
    ///     to the `View` protocol.
    ///   - parentView: The UIKit view that will contain the SwiftUI view.
    ///   - frame: The frame to be used for the hosted SwiftUI view.
    /// - Returns: The `UIViewController` (specifically, a `UIHostingController`) that hosts
    ///   the SwiftUI view. This can be used for further configuration or management.
    ///
    /// - Note: This function attempts to find the appropriate parent view controller to add
    ///   the hosting controller as a child. It first checks for a `UINavigationController`
    ///   with a `FlutterViewController`, which is common in Flutter-based apps with SwiftUI
    ///   integration. If not found, it falls back to the root view controller.
    ///
    /// - Important: Ensure that you maintain a strong reference to the returned view controller
    ///   to prevent it from being deallocated.
    func embedView<T: View>(
        _ swiftUIView: T,
        in parentView: UIView,
        frame: CGRect
    ) -> UIViewController {
        let hostingController = UIHostingController(rootView: swiftUIView)

        hostingController.view.frame = frame
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentView.addSubview(hostingController.view)

        if let navigationController = UIApplication.shared.windows.first?.rootViewController
            as? UINavigationController,
            let flutterViewController = navigationController.viewControllers.first
                as? FlutterViewController {
            flutterViewController.addChild(hostingController)
            parentView.addSubview(hostingController.view)
            hostingController.view.setNeedsLayout()
            hostingController.view.layoutIfNeeded()
        } else {
            let rootViewController = UIApplication.shared.windows.first?.rootViewController
            rootViewController?.addChild(hostingController)
        }
        hostingController.overrideUserInterfaceStyle = .light
        return hostingController
    }
}
