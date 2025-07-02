import APICore
import Common

class BaselineMocks {
    private let host = "https://rest.dev.fstr.app"
    private let contentHost = "https://content.cdn-simple-life.com"
    func mocks() -> [ServerMockData] {
        [
            .init(urlTemplate: "\(host)/v1/user", handler: .init { request in
                do {
                    let jwtString = request.request.value(forHTTPHeaderField: "Authorization")?.trimmingPrefix("Bearer ") ?? ""
                    let identityID = try JWTUtils.parseIdentityIdFromAnonymJWT(accessToken: String(jwtString))
                    let mockJson = JSONDataToDict(BundleHelper.loadData("rest_v1_user.json"))
                    let json = JSONOverrideHelper().overriddenStorage(storage: mockJson!, overrides: [
                        "data.id": identityID
                    ])
                    return .ok(.json(json))
                } catch {
                    return .internalServerError(nil)
                }
            }),
            .init(urlTemplate: "\(host)/v1/user/token", handler: .ok(jsonFile: "rest_v1_user_token.json")),

            .init(urlTemplate: "https://telemetry.dataplatform.simple.life/v2/config", handler: .ok(json: [:])),
            .init(urlTemplate: "https://telemetry.dataplatform.simple.life/v2/paltabrain", handler: .ok(json: [:])),
            .init(urlTemplate: "https://telemetry.simple-sandbox.paltabrain.com/v1/config", handler: .ok(json: ["targets": []])),
            .init(urlTemplate: "https://payment-api-dev.simple.life/v2/api/users/:userId/subscription", handler: .ok(json: [:])),
            .init(urlTemplate: "https://assets.simple.life/geo.json", handler: .response(statusCode: .other(code: 403), data: nil)),

            .init(urlTemplate: "\(contentHost)/static/:someDir/:imageName.png", handler: .ok(file: "brain-light.webp", contentType: "image/webp")),
            .init(urlTemplate: "\(contentHost)/static/:someDir/:someDir2/:imageName.png", handler: .ok(file: "brain-light.webp", contentType: "image/webp")),
            .init(urlTemplate: "\(contentHost)/static/:someDir/:someDir2/:someDir3/:imageName.png", handler: .ok(file: "brain-light.webp", contentType: "image/webp")),

            .init(urlTemplate: "\(contentHost)/configs_dev/store_products_ids_v2.json", handler: .ok(jsonFile: "content_store_products_ids_v2.json")),
            .init(urlTemplate: "\(contentHost)/remote_configs_dev/en/welcome_new_layout.json", handler: .ok(jsonFile: "content_welcome_new_layout.json")),
            .init(urlTemplate: "\(contentHost)/remote_configs_dev/en/onboarding_config_v4.json", handler: .ok(jsonFile: "content_onboarding_config_v4.json")),

            .init(urlTemplate: "\(host)/v1/user/day", handler: .ok(json: ["data": ["dayNumber": 1, "nextStartDateTime": DateFormatter.iso8601DateTimeFormatter.string(from: Date().addingTimeInterval(24 * 60 * 60))]])),
            .init(urlTemplate: "\(host)/v1/user/device", handler: .response(statusCode: .noContent, data: nil)),
            .init(urlTemplate: "\(host)/v1/user/settings", handler: .ok(json: ["data": ["settings": [:]]])),
            .init(urlTemplate: "\(host)/v1/user/measurements", handler: .ok(json: ["data": []])),
            .init(urlTemplate: "\(host)/v1/user/measurements/progress", handler: .ok(json: ["data": [:]])),
            .init(urlTemplate: "\(host)/v1/user/activity", handler: .ok(json: ["data": []])),
            .init(urlTemplate: "\(host)/v1/user/flags", handler: .ok(json: ["data": ["flags": [:]]])),
            .init(urlTemplate: "\(host)/v1/user/statistics", handler: .ok(jsonFile: "rest_v1_user_statistics.json")),
            .init(urlTemplate: "\(host)/v2/user/live-activity", handler: .response(statusCode: .noContent, data: nil)),
            .init(urlTemplate: "\(host)/v1/user/goals", handler: .init { request in
                if request.method == "GET" { return .ok(.json(["data": []])) }
                return .ok(.jsonFile("rest_v1_user_goals.json"))
            }),
            .init(urlTemplate: "\(host)/v1/user/program", handler: .init { request in
                if request.method == "GET" { return .ok(.json(["data": NSNull()])) }
                return .ok(.jsonFile("rest_v1_user_program.json"))
            }),
            .init(urlTemplate: "\(host)/users-api/v1/userconfigs/trackers", handler: .ok(jsonFile: "rest_users-api_v1_userconfigs_trackers.json")),
            .init(urlTemplate: "\(host)/users-api/v1/user/tags", handler: .ok(json: ["tags": NSNull()])),
            .init(urlTemplate: "\(host)/user-workouts/api/v1/status", handler: .ok(json: ["status": "unavailable"])),
            .init(urlTemplate: "\(host)/ai-nutrition/v2/dailyCheckInV2/banner", handler: .ok(jsonFile: "rest_ai-nutrition_v2_dailyCheckInV2_banner.json")),
            .init(urlTemplate: "\(host)/ai-nutrition/v2/dailyCheckIn/state", handler: .ok(jsonFile: "rest_ai-nutrition_v2_dailyCheckIn_state.json")),
            .init(urlTemplate: "\(host)/ai-nutrition/v2/messages/unread", handler: .ok(json: ["unreadMessages": 0])),
            .init(urlTemplate: "\(host)/ai-nutrition/v2/migrateToSingleChat", handler: .ok(json: ["data": "completed"])),
            .init(urlTemplate: "\(host)/ai-nutrition/v2/streaks/setupInitialGoal", handler: .response(statusCode: .ok, data: nil)),
            .init(urlTemplate: "\(host)/ai-nutrition/v2/streaks/updateCurrentGoal", handler: .response(statusCode: .ok, data: nil)),
            .init(urlTemplate: "\(host)/api/meals/v1/goals", handler: .ok(jsonFile: "rest_api_meals_v1_goals.json")),
            .init(urlTemplate: "\(host)/ai-nutrition/v2/streaks/calendar", handler: .ok(json: ["streaksCalendar": NSNull()])),
            .init(urlTemplate: "\(host)/ai-nutrition/v2/streaks", handler: .ok(jsonFile: "rest_ai-nutrition_v2_streaks.json")),
            .init(urlTemplate: "\(host)/daily_tasks/api/v3/tasks", handler: .ok(json: ["data": ["tasks": []]])),
            .init(urlTemplate: "\(host)/v2/dashboard/preview", handler: .ok(jsonFile: "rest_v2_dashboard_preview.json")),
            .init(urlTemplate: "\(host)/v2/feed", handler: .ok(jsonFile: "rest_v2_feed.json")),
            .init(urlTemplate: "\(host)/v1/feed/section/homescreen", handler: .ok(jsonFile: "rest_v1_feed_section_homescreen.json")),
            .init(urlTemplate: "\(host)/v1/feed/section/local_triggers", handler: .ok(jsonFile: "rest_v1_feed_section_local_triggers.json")),
            .init(urlTemplate: "\(host)/v1/feed/section/triggered_content", handler: .ok(jsonFile: "rest_v1_feed_section_triggered_content.json")),
            .init(urlTemplate: "\(host)/v1/content/preview", handler: .ok(jsonFile: "rest_v1_content_preview.json"))
        ]
    }
}
