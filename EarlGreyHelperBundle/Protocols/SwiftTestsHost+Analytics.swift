import Foundation

extension SwiftTestsHost {

    func setAnalyticsEventCallback(_ callback: @escaping (SwiftTestsAnalyticsEvent) -> Void) {
        let convertedClosure = { (data: Data) in
            // swiftlint:disable:next force_try
            callback(try! SwiftTestsAnalyticsEvent.make(jsonData: data))
        }
        _setAnalyticsEventCallback(convertedClosure)
    }

    func getAnalyticsEvents() -> [SwiftTestsAnalyticsEvent] {
        // swiftlint:disable:next force_try
        return try! SwiftTestsAnalyticsEvent.makeArray(jsonData: _getAnalyticsEvents())
    }
}

struct SwiftTestsAnalyticsEvent {
    var name: String
    var params: [String: Sendable]
    var userProperties: [String: Any]
    var target: Set<Target>

    enum Target: String, Hashable {
        case appsflyer
        case facebook
        case google
        case crashlytics
        case palta
        case braze
    }
}

extension SwiftTestsAnalyticsEvent {

    struct JSONError: Error {}

    static func make(dict: [String: Any]) -> SwiftTestsAnalyticsEvent {
        SwiftTestsAnalyticsEvent(
            name: dict["name"] as? String ?? "",
            params: dict["params"] as? [String: Sendable] ?? [:],
            userProperties: dict["userProperties"] as? [String: Any] ?? [:],
            target: (dict["target"] as? [String]).map { $0.compactMap { Target(rawValue: $0) } }.map(Set.init) ?? Set()
        )
    }

    static func make(jsonData: Data) throws -> SwiftTestsAnalyticsEvent {
        guard let dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Sendable] else {
            throw JSONError()
        }
        return .make(dict: dict)
    }

    static func makeArray(jsonData: Data) throws -> [SwiftTestsAnalyticsEvent] {
        guard let dictArr = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Sendable]] else {
            throw SwiftTestsAnalyticsEvent.JSONError()
        }
        return dictArr.map { SwiftTestsAnalyticsEvent.make(dict: $0) }
    }
}
