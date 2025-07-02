extension XCTestCase {

    func closeSystemDialog(_ dialog: String, allow: Bool, timeout: TimeInterval = 15) -> ScreenplayTask {
        ScreenplayTask(name: "wait and close system dialog \(dialog), allow: \(allow)") {
            XCTAssertTrue(self.grey_wait(forAlertVisibility: true, withTimeout: timeout))
            if allow {
                XCTAssertTrue(self.grey_acceptSystemDialogWithError(nil))
            } else {
                XCTAssertTrue(self.grey_denySystemDialogWithError(nil))
            }
            XCTAssertTrue(self.grey_wait(forAlertVisibility: false, withTimeout: timeout))
        }
    }

    func closeRemainingAlertsIfAny() {
        let visible = grey_wait(forAlertVisibility: true, withTimeout: 1)
        if visible {
            grey_denySystemDialogWithError(nil)
        }
    }
}
