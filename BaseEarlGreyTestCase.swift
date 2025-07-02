import Foundation
import XCTest
import ConcurrencyExtras

@MainActor
class BaseEarlGreyTestCase: XCTestCase, Sendable {

    let mockServer = MockServer.shared

    nonisolated
    static let didRunExecuteOnceBlock = LockIsolated(true)

    var analyticsEvents: [SwiftTestsAnalyticsEvent] = []

    func mainActorSetUp() {
        // implement in subclass
    }

    func mainActorTearDown() {
        // implement in subclass
    }

    override class func setUp() {
        super.setUp()

        // Enable once via class setUp because ivars are not preserved across test functions
        didRunExecuteOnceBlock.setValue(false)

        GREYConfiguration.shared.setValue(
            GREYAppState.pendingNetworkRequest.rawValue
                | GREYAppState.pendingCAAnimation.rawValue
                | GREYAppState.pendingUIAnimation.rawValue,
            forConfigKey: .ignoreAppStates
        )
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        MainActor.assumeIsolated {
            mainActorSetUp()
        }
    }

    override func tearDown() {
        super.tearDown()

        MainActor.assumeIsolated {
            mainActorTearDown()

            stopNetworkMocksServer()
            resetAnalyticsEvents()
        }
    }

    func executeOnceOrIfElementExists(_ elementMatcher: any GREYMatcher, _ block: () -> Void) {
        guard !Self.didRunExecuteOnceBlock.value || EarlGrey.isElementExists(elementMatcher) else {
            return
        }
        Self.didRunExecuteOnceBlock.setValue(true)
        block()
    }
}

extension SwiftTestsHost {
    func setupBusyTracking() {
        setupBusyTracking(onXCTFail: { message in
            XCTFail(message)
        })
    }
}
