import Foundation

extension GREYMatcher {

    func interactable() -> GREYMatcher {
        self.and(grey_interactable())
    }

    func sufficientlyVisible() -> GREYMatcher {
        self.and(grey_sufficientlyVisible())
    }

    func and(_ matcher: GREYMatcher) -> GREYMatcher {
        grey_allOf([self, matcher])
    }
}

extension GREYMatcher {

    var occurrences: Int {
        var count = 0
        let countMatcher = self.and(appHost().countMatcher { count += 1 })
        EarlGrey.selectElement(with: countMatcher).assert(grey_nil())
        return count
    }

    func waitForOccurrences(_ expected: Int) {
        let didFind = GREYCondition(name: "waiting for \(expected) occurrences") { [weak self] in
            self?.occurrences == expected
        }.wait(withTimeout: 10, pollInterval: 0.3)
        GREYAssertTrue(didFind, "Failed to wait for \(expected) occurrences")
    }
}

/// For SwiftUI merged accessibilityIdentifiers, example: "someID1-someID2-SomeID3"
@MainActor
func grey_accessibilityIDMerged(contains accessibilityID: String) -> any GREYMatcher {
    return GREYElementMatcherBlock { element in
        let selector = #selector(getter: UIAccessibilityIdentification.accessibilityIdentifier)
        guard let object = element as? NSObjectProtocol,
              object.responds(to: selector),
              let actualIdentifier = object.perform(selector)?.takeUnretainedValue() as? String else {
            return false
        }

        if actualIdentifier == accessibilityID {
            return true
        }
        return actualIdentifier.components(separatedBy: "-").contains(accessibilityID)
    } descriptionBlock: { description in
        description.appendText("grey_accessibilityIDMerged('\(accessibilityID)')")
    }
}

extension EarlGrey {

    @discardableResult
    static func scrollDown(_ scrollElement: GREYMatcher, untilElementIsVisible element: GREYMatcher, amount: CGFloat = 300, visibility: CGFloat = 0.9) -> GREYInteraction {
        let visible = grey_minimumVisiblePercent(visibility)
        return EarlGrey.selectElement(with: grey_allOf([element, visible]))
            .usingSearch(
                action: grey_scrollInDirection(.down, amount),
                onElementWith: scrollElement.interactable()
            )
            .assert(grey_notNil())
    }

    static func scrollDown(_ scrollElement: GREYMatcher, ensureElementNotVisible element: GREYMatcher, amount: CGFloat = 300) {
        EarlGrey.selectElement(with: element.sufficientlyVisible())
            .usingSearch(
                action: grey_scrollInDirection(.down, amount),
                onElementWith: scrollElement.interactable()
            )
            .assert(grey_nil())
    }

    /// Used for actions that can fail because of delayed interactivity (activity indicators)
    static func selectElement(
        with matcher: GREYMatcher,
        timeout seconds: CFTimeInterval,
        pollInterval interval: CFTimeInterval,
        action: @escaping (GREYInteraction, NSErrorPointer) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var error: NSError?
        let success = GREYCondition(name: "Wait for selectElement/(timeout) to succeed") {
            let element = EarlGrey.selectElement(with: matcher)
            error = nil
            action(element, &error)

            return error == nil
        }.wait(withTimeout: seconds, pollInterval: interval)
        if !success {
            GREYFail(
                "Failed to selectElement(timeout)",
                error?.localizedFailureReason ?? String(describing: error),
                file: file, line: line
            )
        }
    }

    static func waitForElement(
        _ elementMatcher: GREYMatcher,
        inRoot: GREYMatcher? = nil,
        timeout: CFTimeInterval = 10,
        pollInterval: CFTimeInterval = 0.3,
        perform action: GREYAction? = nil
    ) {
        EarlGrey.selectElement(
            with: elementMatcher,
            timeout: timeout,
            pollInterval: pollInterval,
            action: {
                if let inRoot {
                    $0.inRoot(inRoot).assert(grey_notNil(), error: $1)
                } else {
                    $0.assert(grey_notNil(), error: $1)
                }
            }
        )
        if let action {
            EarlGrey.selectElement(with: elementMatcher).perform(action)
        }
    }

    static func waitForElement(
        _ elementMatcher: GREYMatcher,
        inRoot: GREYMatcher? = nil,
        timeout: CFTimeInterval = 10,
        pollInterval: CFTimeInterval = 0.3,
        assert assertion: GREYAssertion
    ) {
        EarlGrey.selectElement(
            with: elementMatcher,
            timeout: timeout,
            pollInterval: pollInterval,
            action: {
                if let inRoot {
                    $0.inRoot(inRoot).assert(assertion, error: $1)
                } else {
                    $0.assert(assertion, error: $1)
                }
            }
        )
    }

    static func waitForElement(
        _ elementMatcher: GREYMatcher,
        inRoot: GREYMatcher? = nil,
        timeout: CFTimeInterval = 10,
        pollInterval: CFTimeInterval = 0.3,
        assert matcher: GREYMatcher
    ) {
        EarlGrey.selectElement(
            with: elementMatcher,
            timeout: timeout,
            pollInterval: pollInterval,
            action: {
                if let inRoot {
                    $0.inRoot(inRoot).assert(matcher, error: $1)
                } else {
                    $0.assert(matcher, error: $1)
                }
            }
        )
    }

    static func isElementExists(
        _ elementMatcher: GREYMatcher
    ) -> Bool {
        var error: NSError?
        EarlGrey.selectElement(with: elementMatcher).assert(grey_notNil(), error: &error)
        return error == nil
    }

    static func isElementExists(
        _ elementMatcher: GREYMatcher,
        timeout seconds: CFTimeInterval,
        pollInterval interval: CFTimeInterval = 0.2
    ) -> Bool {
        let success = GREYCondition(name: "Wait for isElementExists to succeed") {
            let element = EarlGrey.selectElement(with: elementMatcher)
            var error: NSError?
            element.assert(grey_notNil(), error: &error)

            return error == nil
        }.wait(withTimeout: seconds, pollInterval: interval)
        return success
    }
}
