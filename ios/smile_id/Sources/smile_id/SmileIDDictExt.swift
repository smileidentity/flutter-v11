extension Dictionary where Key == String, Value == Any {
    func toJSONCompatibleDictionary() -> [String: Any] {
        var jsonCompatibleDict = [String: Any]()
        for (key, value) in self {
            if let arrayValue = value as? [Any] {
                jsonCompatibleDict[key] = arrayValue.map { convertToJSONCompatible($0) }
            } else {
                jsonCompatibleDict[key] = convertToJSONCompatible(value)
            }
        }
        return jsonCompatibleDict
    }

    private func convertToJSONCompatible(_ value: Any) -> Any {
        switch value {
        case let url as URL:
            return url.absoluteString
        case let bool as Bool:
            return bool
        case let string as String:
            return string
        case let number as NSNumber:
            return number
        case let dict as [String: Any]:
            return dict.toJSONCompatibleDictionary()
        default:
            return String(describing: value)
        }
    }
}
