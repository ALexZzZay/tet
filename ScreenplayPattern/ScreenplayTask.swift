import Foundation

struct ScreenplayTask {
    let name: String?
    let perform: () -> Void

    init(name: String? = nil, perform: @escaping () -> Void) {
        self.name = name
        self.perform = perform
    }
}

extension ScreenplayTask {
    static func tap(id: String, name: String? = nil) -> ScreenplayTask {
        .init(name: name ?? "tap on \(id)") {
            let matcher = grey_accessibilityID(id)
            EarlGrey.selectElement(with: matcher).perform(grey_tap())
        }
    }
}
