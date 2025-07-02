@MainActor
enum Allure {
    static func id(_ value: String) {
        label(name: "AS_ID", values: [value])
    }

    static func ids(_ values: [String]) {
        label(name: "AS_ID", values: values)
    }

    static func step(_ name: String, step: () -> Void) {
        XCTContext.runActivity(named: name) { _ in
            step()
        }
    }

    private static func label(name: String, values: [String]) {
        for value in values {
            XCTContext.runActivity(named: "allure.label." + name + ":" + value, block: { _ in })
        }
    }
}
