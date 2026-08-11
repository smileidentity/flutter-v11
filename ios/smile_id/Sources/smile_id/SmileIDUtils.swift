import Foundation
import SmileID
import UIKit

/// Runs `work` on the platform (main) thread, synchronously when already there.
///
/// Everything this wrapper does with a native result has to happen on the platform thread: a
/// `FlutterMethodChannel` message sent from any other thread is undefined ("Platform channel
/// messages must be sent on the platform thread", per the engine's own diagnostic), and detaching
/// the hosting view controller is UIKit. The native SDK does not contract which queue it calls
/// back on — a result produced inside a submission `Task` arrives on a cooperative-pool thread —
/// so the hop belongs here rather than being assumed.
///
/// Staying synchronous when already on the main thread keeps the ordering unchanged for the
/// callbacks that already arrive there.
func onPlatformThread(_ work: @escaping () -> Void) {
    if Thread.isMainThread {
        work()
    } else {
        DispatchQueue.main.async(execute: work)
    }
}

/// Wraps a Pigeon completion so its reply crosses the channel on the platform thread.
func platformThreadReply<T>(_ completion: @escaping (Result<T, Error>) -> Void) -> (Result<T, Error>) -> Void {
    { result in onPlatformThread { completion(result) } }
}

/// Reported when a result cannot be serialised for the channel.
///
/// Every callback has to end in `onSuccess` or `onError`: a result the wrapper cannot encode and
/// therefore drops leaves the caller waiting on a future that never completes.
let resultEncodingErrorMessage = "Failed to encode the capture result"

extension String {
    func isValidUrl() -> Bool {
        if let url = URL(string: self) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
}

func getCurrentIsoTimestamp() -> String {
    let pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    let formatter = DateFormatter()
    formatter.dateFormat = pattern
    formatter.locale = Locale(identifier: "en_US")
    formatter.timeZone = TimeZone(identifier: "UTC")
    return formatter.string(from: Date())
}

extension AutoCapture {
    static func from(_ string: String?) -> AutoCapture {
        switch string?.lowercased() {
        case "autocapture":
            return .autoCapture
        case "autocaptureonly":
            return .autoCaptureOnly
        case "manualcaptureonly":
            return .manualCaptureOnly
        default:
            return .autoCapture
        }
    }
}

extension SmileSensitivity {
    static func from(_ string: String?) -> SmileSensitivity {
        switch string?.lowercased() {
        case "normal":
            return .normal
        case "relaxed":
            return .relaxed
        default:
            return .normal
        }
    }
}
