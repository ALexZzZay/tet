import Foundation
import RestGenerated

extension Precondition {
    enum Mocks {
        enum Api {
            private static let host = "https://rest.dev.fstr.app"
            private static let contentHost = "https://content.cdn-simple-life.com"

            static func feedPremium() -> [ServerMockData] {
                feedPremiumSections() + [
                    .init(
                        urlTemplate: "\(host)/v2/feed",
                        handler: .ok(jsonFile: "feedOnlyPremium.json")
                    )
                ]
            }

            static func feedPremiumSections() -> [ServerMockData] {
                [
                    .init(
                        urlTemplate: "\(contentHost)/articles/en/592e2926-1dbe-49c4-8674-4c99ac1a38c1.json",
                        handler: .ok(jsonFile: "mocked_content_spanishPaellaRecipe.json")
                    ),
                    .init(
                        urlTemplate: "\(host)/v1/content/592e2926-1dbe-49c4-8674-4c99ac1a38c1",
                        handler: .ok(jsonFile: "mocked_contentItem_spanishPaella.json")
                    ),
                    .init(
                        urlTemplate: "\(host)/v1/feed/sections",
                        handler: .ok(jsonFile: "sectionsOnlyPremium.json")
                    ),
                    .init(
                        urlTemplate: "\(host)/v1/feed/section/triggered_content",
                        handler: .ok(jsonFile: "triggeredContentPremiumOnly.json")
                    )
                ]
            }

            static func mockedWatchConfigEn() -> [ServerMockData] {
                [
                    .init(urlTemplate: "\(contentHost)/configs/en/tracker_config.json",
                          handler: .ok(jsonFile: "mocked_watch_config_en.json")),
                    .init(urlTemplate: "\(contentHost)/configs_dev/en/tracker_config.json",
                          handler: .ok(jsonFile: "mocked_watch_config_en.json"))
                ]
            }

            static func userCheckInDoneState() -> [ServerMockData] {
                [
                    .init(urlTemplate: "\(host)/ai-nutrition/v2/dailyCheckIn/state",
                          handler: .ok(jsonFile: "userCheckInDoneState.json"))
                ]
            }

            static func addTwoWeeksToUserCreatedDate() -> [ServerMockData] {
                [
                    .init(urlTemplate: "\(host)/v1/user",
                          handler: .live(modify: { (userResponse: RestUserResponse) in
                              let createdAt = userResponse.data.createdAt ?? .now
                              userResponse.data.createdAt = createdAt.byAdding(weeks: -2)
                              return userResponse
                          }))
                ]
            }

            static func imageToIntakeResponseBurgerSuccess() -> [ServerMockData] {
                [
                    .init(urlTemplate: "\(host)/api/meals/v1/noting/image-to-intake-text",
                          handler: .ok(jsonFile: "imageToIntakeTextBurgerSuccess.json"))
                ]
            }

            static func unboxingFree() -> [ServerMockData] {
                [
                    .init(
                        urlTemplate: "\(host)/users-api/v1/userconfigs/unboxing",
                        handler: .ok(jsonFile: "unboxing_free.json")
                    )
                ]
            }
        }
    }
}
