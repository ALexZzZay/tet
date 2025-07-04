import Foundation

class AvoCameraTipTests: BaseEarlGreyTestCase {

    override func mainActorSetUp() {
        super.mainActorSetUp()

        let app = XCUIApplication()
        app.resetAuthorizationStatus(for: .camera)
        app.launch()

        appHost().setupBusyTracking()

        Precondition.newEmptyUser(consents: ["health_data_processing_consent"]).perform()
        Precondition.setDefaultAvoPolicyType().perform()
        Precondition.shouldShowCameraTipInAvo().perform()
    }

    override func mainActorTearDown() {
        super.mainActorTearDown()
        closeRemainingAlertsIfAny()
    }

    func test_tapOnTooltip() {
        Allure.id("51950")

        alice.attemptsTo(TabBar.openTab(.avo))
        alice.attemptsTo(AINutritionistChat.waitForInputIsEnabled())
        alice.sees(SmartCamera.seesTipOverlayButton())
        alice.attemptsTo(SmartCamera.tapTipOverlayButton())
        alice.attemptsTo(closeSystemDialog("Camera", allow: false))
        alice.sees(SmartCamera.seesCameraPermissionsCTA())
    }

    func test_tapOutOfTooltip() {
        Allure.id("51952")

        alice.attemptsTo(TabBar.openTab(.avo))
        alice.attemptsTo(AINutritionistChat.waitForInputIsEnabled())
        alice.sees(SmartCamera.seesTipOverlayButton())
        TabBar.Actions.pressTabButton(.profile)
        alice.sees(AINutritionistChat.seeScreen())
        alice.sees(SmartCamera.notVisibleTipOverlayButton())
    }
}
