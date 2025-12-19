import Foundation
import SmileID

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
