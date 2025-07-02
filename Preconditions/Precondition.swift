import Foundation

@MainActor
enum Precondition {

    static func isOffline(_ offline: Bool = true) -> PreconditionTask {
        .init {
            appHost().setBlockOtherURLRequests(block: offline)
        }
    }

    static func newEmptyUser(
        metricSystem: Bool = true,
        consents: [String] = [],
        waitForTabBar: Bool = true
    ) -> PreconditionTask {
        .init {
            appHost().prepareEmptyUser(metricSystem: metricSystem, consents: consents)

            let didCreateEmptyUser = GREYCondition(name: "waiting for new empty user") {
                appHost().isPrepareEmptyUserCompleted()
            }.wait(withTimeout: 25, pollInterval: 1)
            GREYAssertTrue(didCreateEmptyUser, "can't create empty user")

            if waitForTabBar {
                alice.attemptsTo(TabBar.waitForTabBarIsVisible())
            }
        }
    }

    static func shouldShowCameraTipInAvo() -> PreconditionTask {
        .init {
            appHost().setShouldShowCameraTipInAvo()
        }
    }

    static func hasPremium() -> PreconditionTask {
        .init {
            Deeplink.openViaXPC("fstr://redeem?code=FuCKpayWA11$").perform()
        }
    }

    static func hasNoPremium() -> PreconditionTask {
        .init {
            Deeplink.openViaXPC("fstr://remove_redeem").perform()
            logoutFromRevenueCat()
        }
    }

    static func hasFinishedUnboxing() -> PreconditionTask {
        .init {
            appHost().setUserFlag(key: "did_finish_unboxing_v5", value: true)
        }
    }

    static func auth0(enabled: Bool) -> PreconditionTask {
        .init {
            appHost().setFeatureToggle(key: "DEV-9980", value: false)
        }
    }

    static func notOnboardedUser() -> PreconditionTask {
        .init {
            appHost().prepareNotOnboardedUser()

            let didCreateEmptyUser = GREYCondition(name: "waiting for not onboarded user") {
                appHost().isPrepareNotOnboardedUserCompleted()
            }.wait(withTimeout: 15, pollInterval: 1)
            GREYAssertTrue(didCreateEmptyUser, "can't create not onboarded user")
        }
    }

    static func mockedWelcomeConfig(allowSkipAuth: Bool) -> PreconditionTask {
        .init {
            appHost().overrideRemoteConfig(
                key: .welcomeNewLayout,
                value: RemoteConfigMock.jsonFile("mocked_welcome_new_layout.json")
            )
            appHost().overrideRemoteConfig(
                key: .canSkipAuthorizationOnWelcome,
                value: allowSkipAuth ? "1" : "0"
            )
        }
    }

    static func mockedOnboardingConfig() -> PreconditionTask {
        .init {
            appHost().overrideRemoteConfig(
                key: .onboardingConfig,
                value: RemoteConfigMock.jsonFile("mocked_onboarding_config.json")
            )
            mockedPaywallConfigs().perform()
        }
    }

    static func mockedAssessment() -> PreconditionTask {
        .init {
            appHost().overrideRemoteConfig(
                key: .isAssessmentCancellationFlowEnabled,
                value: "1"
            )
        }
    }

    static func setDefaultAvoPolicyType() -> PreconditionTask {
        .init {
            appHost().overrideRemoteConfig(
                key: .customAvoConsentType,
                value: "default"
            )
        }
    }

    static func foodFeedbackRateDisplayedOnEveryIntake() -> PreconditionTask {
        .init {
            appHost().overrideRemoteConfig(
                key: .foodFeedbackRatingFrequency,
                value: "1"
            )
        }
    }

    static func fastingPlan(hours: Int, startOffset: TimeInterval) -> PreconditionTask {
        .init {
            let nowSeconds = Date().daySeconds(in: .current)
            alice.attemptsTo(TabBar.openTab(.tracker))
            alice.attemptsTo(MainStatus.openFastingPlan())
            alice.attemptsTo(FastingPlan.changeSelectedGoal(containing: "Fast \(hours)"))
            alice.attemptsTo(FastingPlan.changeSchedule(startFastingAt: nowSeconds + startOffset))
            alice.attemptsTo(FastingPlan.save())
        }
    }

    static func mockedPaywallConfigs() -> PreconditionTask {
        .init {
            appHost().overrideRemoteConfig(
                key: .onboardPaywallLayout,
                value: RemoteConfigMock.jsonFile("mocked_onboarding_paywall.json")
            )
            appHost().overrideRemoteConfig(
                key: .proPaywallLayout,
                value: RemoteConfigMock.jsonFile("mocked_onboarding_paywall.json")
            )
            appHost().overrideRemoteConfig(
                key: .offerPaywallLayout,
                value: RemoteConfigMock.jsonFile("mocked_offer_paywall_layout.json")
            )
        }
    }

    private static func logoutFromRevenueCat() {
        appHost().logoutFromRevenueCat()
        let didLogoutRevenueUser = GREYCondition(name: "waiting for revenue cat user to log out") {
            appHost().isLogoutFromRevenueCatCompleted() != SwiftTestsPerformActionResult.inProgress
        }.wait(withTimeout: 10, pollInterval: 0.5)
        GREYAssertTrue(didLogoutRevenueUser, "can't log out from revenue cat")
    }
}
