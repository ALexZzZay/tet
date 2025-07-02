import Foundation
import SwiftUI
import Common
import CommonSceneUI
import CommonServices
import CommonServicesInterface
import FastingUI
import SimpleFramework
import Photos
import IssueReporting

private class NonIsolated {
    static func makeBlock(_ text: String) -> GREYDescribeToBlock {
        return { description in
            description.appendText(text)
        }
    }
}

@MainActor
extension GREYHostApplicationDistantObject: @preconcurrency SwiftTestsHost {

    func countMatcher(block: @escaping () -> Void) -> GREYMatcher {
        GREYElementMatcherBlock.matcher(
            matchesBlock: { _ in
                block()
                return false
            },
            descriptionBlock: NonIsolated.makeBlock("Count of Matcher")
        )
    }

    func countOfElements(viewModelClassName className: String, expected: Int) -> GREYAssertion {
        GREYAssertionBlock(name: "countOfElementsViewModelClassName") { (element: Any?, errorOrNil: UnsafeMutablePointer<NSError?>?) in
            guard let collectionView = (element as? UICollectionView) else { return false }
            guard let dataSource = collectionView.dataSource as? CommonCollectionViewDataSource else { return false }
            let actual = dataSource.rows.filter { Utility.classNameAsString($0) == className }.count
            let ok = expected == actual
            if !ok {
                errorOrNil?.pointee = makeGreyError(reason: "\(className) count expected \(expected), actual: \(actual)")
                return false
            }
            return ok
        }
    }

    func matcherForLabelContainsText(text: String) -> GREYMatcher {
        GREYElementMatcherBlock.matcher(
            matchesBlock: { element in
                if (element as? UIView)?.accessibilityLabel?.contains(text) ?? false {
                    return true
                }

                if let elementObject = (element as? NSObject),
                   elementObject.responds(to: #selector(getter: UILabel.text)),
                   let elementText = elementObject.perform(#selector(getter: UILabel.text), with: nil)?
                   .takeUnretainedValue() as? String {
                    return elementText.contains(text)
                }

                let selector = #selector(UIAccessibilityElement.accessibilityLabel)
                if let object = element as? NSObjectProtocol,
                   object.responds(to: selector),
                   let string = object.perform(selector)?.takeUnretainedValue() as? String,
                   string.contains(text) {
                    return true
                }

                return false
            },
            descriptionBlock: NonIsolated.makeBlock("containsText(\(text))")
        )
    }

    func matcherPickerColumnSetToValue(column: Int, value: String) -> GREYMatcher {

        let prefix = "pickerColumnAtIndex"
        let extractTextFromView = { (view: UIView?) -> String? in
            if let labelView = (view as? UILabel) {
                return labelView.text
            }
            if let labels = view?.grey_childrenAssignable(from: UILabel.self) as? [UILabel] {
                return labels.first?.text
            }
            return nil
        }

        let textMatcher = GREYElementMatcherBlock.matcher(
            matchesBlock: { element in
                guard let element = element as? UIPickerView else {
                    return false
                }

                guard column < element.numberOfComponents else {
                    return false
                }

                let row = element.selectedRow(inComponent: column)
                let delegate = element.delegate
                let actualText: String? = delegate?.pickerView?(element, titleForRow: row, forComponent: column)?.nonEmpty
                    ?? delegate?.pickerView?(element, attributedTitleForRow: row, forComponent: column)?.string.nonEmpty
                    ?? extractTextFromView(delegate?.pickerView?(element, viewForRow: row, forComponent: column, reusing: nil))

                return actualText == value
            },
            descriptionBlock: NonIsolated.makeBlock("\(prefix)(\(column)) value('\(value)')")
        )

        return grey_allOf([
            GREYMatchers.matcherForKind(of: UIPickerView.self),
            textMatcher
        ])
    }

    func matcherTextViewIsEditable() -> GREYMatcher {
        GREYElementMatcherBlock.matcher(
            matchesBlock: { element in
                guard let element = element as? UITextView else {
                    return false
                }

                return element.isEditable
            },
            descriptionBlock: NonIsolated.makeBlock("text view is editable")
        )
    }

    func setPickerToValueContaining(string: String, column: Int, caseSensitive: Bool) -> GREYAction {
        GREYActionBlock(name: "setPickerColumnToValueContainingString", constraints: nil) { element, errorOrNil in
            guard let element = element as? UIPickerView else {
                errorOrNil?.pointee = makeGreyError(reason: "\(String(describing: element)) is not a UIPickerView")
                return false
            }

            var matching = [(index: Int, value: String)]()
            for row in 0..<element.numberOfRows(inComponent: column) {
                guard let value = element.delegate?.pickerView?(element, titleForRow: row, forComponent: column) else {
                    continue
                }
                let matches = caseSensitive ? value.contains(string) : value.lowercased().contains(string.lowercased())
                if matches {
                    matching.append((index: row, value: value))
                }
            }

            if matching.isEmpty {
                errorOrNil?.pointee = makeGreyError(reason: "No matching values found for '\(string)'")
                return false
            }

            if matching.count > 1 {
                errorOrNil?.pointee = makeGreyError(reason: "Multiple matching values found for '\(string)': \(matching)")
                return false
            }

            element.selectRow(matching[0].index, inComponent: column, animated: false)

            return true
        }
    }

    func setRangeCircularSliderStartValue(_ startValue: CGFloat) -> GREYAction {
        updateRangeCircularSlider { element in
            element.selectedThumb = .startThumb
            element.startPointValue = startValue
        }
    }

    func setRangeCircularSliderEndValue(_ endValue: CGFloat) -> GREYAction {
        updateRangeCircularSlider { element in
            element.selectedThumb = .endThumb
            element.endPointValue = endValue
        }
    }

    func shouldRequestPhotoAppAuthStatus() -> Bool {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .notDetermined
    }

    func requestPhotoAppAuthStatus() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in }
    }

    func addImagesToPhotoApp(_ images: [UIImage], completion: @escaping ([String]) -> Void) {
        var identifiers = [String]()

        PHPhotoLibrary.shared().performChanges({
            for image in images.reversed() {
                let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let localIdentifier = creationRequest.placeholderForCreatedAsset?.localIdentifier ?? ""
                identifiers.append(localIdentifier)
            }
        }, completionHandler: { _, _ in
            completion(identifiers)
        })
    }

    func removeImagesFromPhotoApp(identifiers: [String], completion: @escaping () -> Void) {
        PHPhotoLibrary.shared().performChanges({
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
            PHAssetChangeRequest.deleteAssets(assets)
        }, completionHandler: { _, _ in
            completion()
        })
    }

    private func updateRangeCircularSlider(perform: @escaping (RangeCircularSlider) -> Void) -> GREYAction {
        GREYActionBlock(name: "setRangeCircularSliderToStartValue", constraints: nil) { element, errorOrNil in
            guard let element = element as? RangeCircularSlider else {
                errorOrNil?.pointee = makeGreyError(reason: "\(String(describing: element)) is not a RangeCircularSlider")
                return false
            }

            perform(element)
            element.sendActions(for: .valueChanged)

            return true
        }
    }

    func prepareEmptyUser(metricSystem: Bool, consents: [String]) {
        testingSupport.prepareEmptyUser(metricSystem: metricSystem, consents: consents)
    }

    func isPrepareEmptyUserCompleted() -> Bool {
        testingSupport.isPrepareEmptyUserCompleted
    }

    func logoutFromRevenueCat() {
        testingSupport.logoutFromRevenueCat()
    }

    func isLogoutFromRevenueCatCompleted() -> SwiftTestsPerformActionResult {
        switch testingSupport.isLogoutFromRevenueCatCompleted {
        case .inProgress: .inProgress
        case .success: .success
        case .fail: .fail
        }
    }

    public func setShouldShowCameraTipInAvo() {
        testingSupport.setShouldShowCameraTipInAvo()
    }

    public func prepareNotOnboardedUser() {
        testingSupport.prepareNotOnboardedUser()
    }

    func isPrepareNotOnboardedUserCompleted() -> Bool {
        testingSupport.isPrepareNotOnboardedUserCompleted
    }

    func setURLMocks(_ mocks: [SwiftTestsURLMockProtocol]) {
        testingSupport.setURLMocks(mocks.map { mock in
            (port: mock.port, urlTemplate: mock.urlTemplate)
        })
    }

    func setBlockOtherURLRequests(block: Bool) {
        testingSupport.setBlockOtherURLRequests(block: block)
    }

    func handleDeeplink(_ url: URL) {
        testingSupport.handleDeeplink(url)
    }

    func overrideRemoteConfig(key: String, value: String) {
        testingSupport.overrideRemoteConfig(key: key, value: value)
    }

    func setUserFlag(key: String, value: Bool) {
        testingSupport.setUserFlag(key: key, value: value)
    }

    func setFeatureToggle(key: String, value: Bool) {
        testingSupport.setFeatureToggle(key: key, value: value)
    }

    func updateUserMeasurementSystem(metric: NSNumber?) {
        testingSupport.updateUserMeasurementSystem(metric: metric?.boolValue)
    }

    func setFastingTimeAdjustment(_ time: TimeInterval) {
        testingSupport.setFastingTimeAdjustment(time)
    }

    func setupBusyTracking(onXCTFail: @escaping @Sendable (_ message: String) -> Void) {
        IssueReporters.current = [XCTFailReporter(onXCTFail: onXCTFail)]

        TestingHelper.Configuration.onBeginEarlGreyBusyTracker.setValue({
            guard let object = GREYAppStateTracker.sharedInstance().trackState(.pendingUIAnimation, for: $0) else {
                return nil
            }
            return object
        })
        TestingHelper.Configuration.onEndEarlGreyBusyTracker.setValue({
            guard let object = $0 as? GREYAppStateTrackerObject else {
                return
            }
            GREYAppStateTracker.sharedInstance().untrackState(.pendingUIAnimation, for: object) // spellr:disable:line
        })
    }

    func restartAppInTests() {
        testingSupport.restartAppInTests()
    }

    func _setAnalyticsEventCallback(_ callback: @escaping (Data) -> Void) {
        let convertClosure: (AnalyticsEvent) -> Void = { (event: AnalyticsEvent) in
            // swiftlint:disable:next force_try
            try! callback(SwiftTestsAnalyticsEvent(event).toJSON())
        }
        testingSupport.setAnalyticsEventCallback(convertClosure)
    }

    func _getAnalyticsEvents() -> Data {
        // swiftlint:disable:next force_try
        try! Array(testingSupport.getAnalyticsEvents().map(SwiftTestsAnalyticsEvent.init)).toJSON()
    }

    func setAnimationEnabled(_ isEnabled: Bool) {
        testingSupport.setAnimationEnabled(isEnabled)
    }
}

private extension GREYHostApplicationDistantObject {
    @MainActor
    var testingSupport: TestingSupport {
        let appDelegate = (UIApplication.shared.delegate as! TestingAppDelegate)
        return appDelegate.testingSupport
    }
}

extension SwiftTestsAnalyticsEvent {
    init(_ event: AnalyticsEvent) {
        self.init(
            name: event.name,
            params: event.params,
            userProperties: event.userProperties.data,
            target: Set(event.target.map(\.toTestsAnalyticsTarget))
        )
    }

    func toDict() -> [String: Any] {
        [
            "name": name,
            "params": sanitize(params),
            "userProperties": sanitize(userProperties),
            "target": Array(target.map(\.rawValue))
        ]
    }

    func toJSON() throws -> Data {
        try JSONSerialization.data(withJSONObject: self.toDict())
    }

    private func sanitize(_ obj: Any) -> Any {
        if let date = obj as? Date {
            return date.description // same as Amplitude does
        }
        if let arr = obj as? [Any] {
            return Array(arr.map(sanitize))
        }
        if let dict = obj as? [String: Any] {
            return dict.mapValues(sanitize)
        }
        return obj
    }
}

extension AnalyticsEvent.Target {
    var toTestsAnalyticsTarget: SwiftTestsAnalyticsEvent.Target {
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

extension [SwiftTestsAnalyticsEvent] {

    func toDictArr() -> [[String: Any]] {
        map { $0.toDict() }
    }

    func toJSON() throws -> Data {
        try JSONSerialization.data(withJSONObject: self.toDictArr())
    }
}

private struct XCTFailReporter: IssueReporter {
    let onXCTFail: @Sendable (_ message: String) -> Void

    func reportIssue(_ message: @autoclosure () -> String?, fileID: StaticString, filePath: StaticString, line: UInt, column: UInt) {
        onXCTFail("\(fileID):\(line):\(column): \(message() ?? "")")
    }
}
