import Foundation

class ReusableAppTestCase: BaseEarlGreyTestCase {

    override class func setUp() {
        super.setUp()

        MainActor.assumeIsolated {
            let app = XCUIApplication()
            app.terminate()
        }
    }

    override func record(_ issue: XCTIssue) {
        MainActor.assumeIsolated {
            let app = XCUIApplication()
            app.terminate()
        }
        super.record(issue)
    }

    override func mainActorSetUp() {
        super.mainActorSetUp()

        let app = XCUIApplication()
        if app.state == .runningForeground {
            XCTContext.runActivity(named: "reuseAction()") { _ in
                reuseAction(app: app)
            }
        } else {
            XCTContext.runActivity(named: "launchAction()") { _ in
                launchAction(app: app)
            }
        }
    }

    func launchAction(app: XCUIApplication) {
        willLaunch(app: app)
        app.launch()
        appHost().setupBusyTracking()
        didLaunch(app: app)
    }

    func reuseAction(app: XCUIApplication) {
        appHost().restartAppInTests()
    }

    func willLaunch(app: XCUIApplication) {
        // for override
    }

    func didLaunch(app: XCUIApplication) {
        // for override
    }
}
