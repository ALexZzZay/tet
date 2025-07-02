import Foundation

struct Question {
    let name: String?
    let ask: () -> Void

    init(name: String? = nil, ask: @escaping () -> Void) {
        self.name = name
        self.ask = ask
    }
}

extension Question {
    static func sees(id: String, name: String? = nil) -> Question {
        .init(name: name ?? "should see \(id)") {
            let matcher = grey_accessibilityID(id)
            EarlGrey.waitForElement(matcher, assert: grey_sufficientlyVisible())
        }
    }

    static func notVisible(id: String, name: String? = nil) -> Question {
        .init(name: name ?? "should not see \(id)") {
            let matcher = grey_accessibilityID(id)
            EarlGrey.selectElement(with: matcher).assert(grey_notVisible())
        }
    }
}
