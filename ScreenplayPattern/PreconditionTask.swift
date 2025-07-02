import Foundation

@MainActor
struct PreconditionTask {
    let name: String?
    let action: () -> Void

    init(name: String? = #function, action: @escaping () -> Void) {
        self.name = name
        self.action = action
    }

    func perform() {
        execWithActivityName(name) {
            action()
        }
    }

    private func execWithActivityName(_ name: String?, block: () -> Void) {
        if let name = name {
            XCTContext.runActivity(named: name) { _ in
                block()
            }
        } else {
            block()
        }
    }
}
