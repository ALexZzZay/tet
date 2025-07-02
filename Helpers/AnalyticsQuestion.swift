import Foundation
import AnalyticsEventsChecker

enum Analytics {

    static func events(describedIn scenarioSource: EventsScenarioSource, received: [SwiftTestsAnalyticsEvent]) -> Question {
        Question(name: "should have expected analytics events") {
            check(scenarioSource: scenarioSource, received: received)
        }
    }

    static func events(describedIn scenarioSource: EventsScenarioSource) -> Question {
        Question(name: "should have expected analytics events") {
            check(scenarioSource: scenarioSource, received: appHost().getAnalyticsEvents())
        }
    }
}

private func check(scenarioSource: EventsScenarioSource, received: [SwiftTestsAnalyticsEvent]) {
    do {
        let scenario = try scenarioSource.getScenario()

        let result = EventsCheckerLogic.validate(scenario: scenario, events: received.map(\.toCheckerEvent))
        let errorTexts = result.compactMap { event in
            if !event.errors.isEmpty {
                return "\(event.event): \(event.errors)"
            }
            return nil
        }

        XCTAssertEqual([], errorTexts)
    } catch {
        XCTFail("Can't read events scenario: \(error)")
    }
}

// MARK: - Conversion

extension SwiftTestsAnalyticsEvent {
    var toCheckerEvent: EventsCheckerEngineTypes.AnalyticsEvent {
        .init(
            name: name,
            params: params,
            userProperties: userProperties,
            target: Set(target.map(\.toCheckerEventTarget))
        )
    }
}

private extension SwiftTestsAnalyticsEvent.Target {
    var toCheckerEventTarget: EventsCheckerEngineTypes.AnalyticsEvent.Target {
        switch self {
        case .appsflyer: .appsflyer
        case .facebook: .facebook
        case .google: .google
        case .crashlytics: .crashlytics
        case .palta: .palta
        case .braze: .braze
        }
    }
}
