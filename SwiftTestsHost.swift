import Foundation

@objc protocol SwiftTestsHost {
    func countMatcher(block: @escaping () -> Void) -> GREYMatcher
    func countOfElements(viewModelClassName className: String, expected: Int) -> GREYAssertion
    func matcherForLabelContainsText(text: String) -> GREYMatcher

    // custom matcher that support viewForColumn, because grey_pickerColumnSetToValue does not work with viewForColumn
    // although grey_setPickerColumnToValue work fine with viewForColumn
    // waiting for PR merge https://github.com/google/EarlGrey/pull/1810
    func matcherPickerColumnSetToValue(column: Int, value: String) -> GREYMatcher

    func matcherTextViewIsEditable() -> GREYMatcher
    func setPickerToValueContaining(string: String, column: Int, caseSensitive: Bool) -> GREYAction

    func setRangeCircularSliderStartValue(_ startValue: CGFloat) -> GREYAction
    func setRangeCircularSliderEndValue(_ endValue: CGFloat) -> GREYAction

    func prepareEmptyUser(metricSystem: Bool, consents: [String])
    func isPrepareEmptyUserCompleted() -> Bool

    func logoutFromRevenueCat()
    func isLogoutFromRevenueCatCompleted() -> SwiftTestsPerformActionResult

    func prepareNotOnboardedUser()
    func isPrepareNotOnboardedUserCompleted() -> Bool

    func setURLMocks(_ mocks: [SwiftTestsURLMockProtocol])
    func setBlockOtherURLRequests(block: Bool)

    func handleDeeplink(_ url: URL)
    func overrideRemoteConfig(key: String, value: String)

    func setUserFlag(key: String, value: Bool)
    func setFeatureToggle(key: String, value: Bool)

    func setShouldShowCameraTipInAvo()

    func updateUserMeasurementSystem(metric: NSNumber?)

    func setFastingTimeAdjustment(_ time: TimeInterval)

    func shouldRequestPhotoAppAuthStatus() -> Bool
    func requestPhotoAppAuthStatus()
    func addImagesToPhotoApp(_ images: [UIImage], completion: @escaping ([String]) -> Void)
    func removeImagesFromPhotoApp(identifiers: [String], completion: @escaping () -> Void)

    func setupBusyTracking(onXCTFail: @escaping @Sendable (_ message: String) -> Void)
    func restartAppInTests()

    func _setAnalyticsEventCallback(_ callback: @escaping (Data) -> Void) // json serialized SwiftTestsAnalyticsEvent
    func _getAnalyticsEvents() -> Data // json serialized [SwiftTestsAnalyticsEvent]

    func setAnimationEnabled(_ isEnabled: Bool)
}

@objc protocol SwiftTestsURLMockProtocol {
    var port: Int { get }
    var urlTemplate: String { get }
}

@objc enum SwiftTestsPerformActionResult: Int {
    case inProgress
    case success
    case fail
}
