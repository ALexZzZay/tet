import Foundation

enum Deeplink {

    /// It doesn't depend on flaky way of entering via Safari
    /// But also doesn't validate proper info.plist setup because it is bypassed via XPC
    static func openViaXPC(_ urlString: String) -> ScreenplayTask {
        ScreenplayTask(name: "Open \(urlString)") {
            appHost().handleDeeplink(URL(string: urlString)!)
        }
    }
}
