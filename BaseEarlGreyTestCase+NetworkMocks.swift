import Foundation
import XCTest

/*

 ==== Example of network mocking before launching app:

 let mocksLaunchArgument = addNetworkMocksBeforeAppLaunch([
     .init(
         urlTemplate: "https://rest.dev.fstr.app/v2/feed",
         handler: .ok(jsonFile: "FeedPremiumSections.json")
     )
 ])

 let app = XCUIApplication()
 app.launchArguments = [mocksLaunchArgument]
 app.launch()

 ==== Example of network mocking after launching app:

 XCUIApplication().launch()

 addNetworkMocksAfterAppLaunch([
     .init(
         urlTemplate: "https://rest.dev.fstr.app/v2/feed",
         handler: .ok(jsonFile: "FeedPremiumSections.json")
     ),
     .init(
         urlTemplate: "https://rest.dev.fstr.app/v2/user.html",
         handler: .init { request in .ok(.html("<body>\(request.method)")) }
     )
 ])

 addNetworkMockAfterAppLaunch(
     .init(
         urlTemplate: "https://rest.dev.fstr.app/v1/user",
         handler: .ok(jsonString: """
 {
     "data": {
         "id": "2aed5c76-db24-4905-92f0-7cb5d64ff522",
         "name": "Anonymous",
         "avatarUrl": "https://content.cdn-simple-life.com/avatars/female/12.png",
         "isAnonymous": true,
         "isThirdParty": false,
         "isOnboarded": false,
         "data": "{\"drugs\":[\"no\"],\"remoteConfig\":{\"content_explore_recipes_instead_news\":\"treat\"},\"gender\":[\"female\"]}",
         "createdAt": "2022-08-02T14:31:54.588Z",
         "createdOn": "ios"
     }
 }
 """))
 )

 */

extension BaseEarlGreyTestCase {

    func stopNetworkMocksServer() {
        if XCUIApplication().state != .notRunning {
            appHost().setURLMocks([])
        }
        mockServer.stop()
    }

    /// - Returns: XCUIApplication launch argument
    func addNetworkMocksBeforeAppLaunch(_ mocks: [ServerMockData], matchAll: Bool = false) -> String {
        mockServer.mocks.append(contentsOf: mocks)
        mockServer.start()

        let matchAllParts = matchAll ? [
            "\(Int(mockServer.port)):https://*",
            "\(Int(mockServer.port)):http://*"
        ] : []
        let argumentParts = mocks
            .filter { $0.isValid() }
            .map { "\(Int(mockServer.port)):\($0.urlTemplate)" }

        let parts = argumentParts + matchAllParts
        if parts.isEmpty {
            return ""
        }
        return "-NetworkMocks=\(parts.joined(separator: "#"))"
    }

    func addNetworkMockAfterAppLaunch(_ mocks: [ServerMockData]) {
        mockServer.mocks.append(contentsOf: mocks)
        mockServer.start()

        sendAllMocksViaXPC()
    }

    func addNetworkMockAfterAppLaunch(_ mock: ServerMockData) {
        mockServer.mocks.append(mock)
        mockServer.start()

        sendAllMocksViaXPC()
    }

    func blockAllOtherNetworkRequestsBeforeAppLaunch() -> String {
        "-NetworkBlock"
    }

    func blockAllOtherNetworkRequestsAfterAppLaunch(block: Bool = true) {
        appHost().setBlockOtherURLRequests(block: block)
    }

    private func sendAllMocksViaXPC() {
        let redirectMocks: [SwiftTestsURLMock] = mockServer.mocks
            .filter { $0.isValid() }
            .map { .init(port: Int(mockServer.port), urlTemplate: $0.urlTemplate) }
        appHost().setURLMocks(redirectMocks)
    }
}

class SwiftTestsURLMock: SwiftTestsURLMockProtocol {
    var port: Int
    var urlTemplate: String

    init(port: Int, urlTemplate: String) {
        self.port = port
        self.urlTemplate = urlTemplate
    }
}
