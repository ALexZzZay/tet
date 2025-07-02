import Foundation
import AnalyticsEventsChecker

extension BaseEarlGreyTestCase {

    func setupAnalyticsEventsListening() {
        appHost().setAnalyticsEventCallback { [weak self] event in
            self?.analyticsEvents.append(event)
        }
        resetAnalyticsEvents()
    }

    func resetAnalyticsEvents() {
        analyticsEvents = []
    }
}
