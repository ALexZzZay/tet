import Foundation

class FeedContentDynamicMocks {

    private let host = "https://rest.dev.fstr.app"

    let contentUUID = UUID().uuidString
    var isContentLiked = false
    var isContentBookmarked = false
    var isContentRecentlyViewed = false

    func mocks() -> [ServerMockData] {
        [
            .init(urlTemplate: "\(host)/v2/feed",
                  handler: .init(run: { [weak self] _ in
                      guard let self = self else {
                          return .internalServerError(nil)
                      }
                      let json = self.feedJSON()
                      return .ok(.jsonValue(json))
                  })),
            .init(urlTemplate: "\(host)/v1/content/:content_id/like",
                  handler: .withJSONRequestBody(process: { [weak self] request, json in
                      guard let self = self else {
                          return .internalServerError(nil)
                      }
                      guard request.params[":content_id"] == self.contentUUID else {
                          return .notAcceptable(nil)
                      }
                      let newValue = json.object!["likeValue"]!.bool!
                      self.isContentLiked = newValue
                      return .ok(.json(["data": newValue]))
                  })),
            .init(urlTemplate: "\(host)/v1/content/:content_id/bookmark",
                  handler: .withJSONRequestBody(process: { [weak self] request, json in
                      guard let self = self else {
                          return .internalServerError(nil)
                      }
                      guard request.params[":content_id"] == self.contentUUID else {
                          return .notAcceptable(nil)
                      }
                      let newValue = json.object!["bookmarkValue"]!.bool!
                      self.isContentBookmarked = newValue
                      return .ok(.json(["data": newValue]))
                  })),
            .init(urlTemplate: "\(host)/v1/content/preview",
                  handler: .withJSONRequestBody(process: { [weak self] _, json in
                      guard let self = self else {
                          return .internalServerError(nil)
                      }
                      let ids = json.object!["ids"]!.array!.map { $0.string! }
                      guard ids == [self.contentUUID] else {
                          return .notAcceptable(nil)
                      }

                      let json = self.contentPreviewJSON()
                      return .ok(.jsonValue(json))
                  })),
            .init(urlTemplate: "\(host)/v1/content/\(contentUUID)",
                  handler: .init(run: { [weak self] _ in
                      guard let self = self else {
                          return .internalServerError(nil)
                      }

                      let json = self.contentItemJSON(premium: false)
                      return .ok(.jsonValue(json))
                  }))
        ] + Precondition.Mocks.Api.feedPremiumSections()
    }

    func feedJSON() -> JSONValue {
        let data = BundleHelper.loadData("feedBookmarkedAndViewed.json")
        var json = JSONValue.fromData(data)

        json[objectValue: "data"]?[objectValue: "tabs"]?.editArrayInPlace { tab in
            let tabID = tab.object!["id"]!.string!

            tab[objectValue: "sections"]?.editArray { sections in
                sections.removeAll { _ in
                    switch tabID {
                    case "recently_viewed":
                        return !self.isContentRecentlyViewed
                    case "bookmarks":
                        return !self.isContentBookmarked
                    default:
                        return false
                    }
                }
                sections.mapInPlace { section in
                    section[objectValue: "items"]?.editArrayInPlace { item in
                        item[objectValue: "contentItem"]?.editObject { contentItem in
                            contentItem["id"] = .string(self.contentUUID)
                            contentItem["isLiked"] = .bool(self.isContentLiked)
                            contentItem["isBookmarked"] = .bool(self.isContentBookmarked)
                        }
                    }
                }
            }
        }

        return json
    }

    func contentPreviewJSON() -> JSONValue {
        let data = BundleHelper.loadData("contentPreviewVerticalList.json")
        var json = JSONValue.fromData(data)

        json[objectValue: "data"]?[objectValue: "items"]?.editArrayInPlace { item in
            item[objectValue: "contentItem"]?.editObject { contentItem in
                contentItem["id"] = .string(self.contentUUID)
                contentItem["isLiked"] = .bool(self.isContentLiked)
                contentItem["isBookmarked"] = .bool(self.isContentBookmarked)
            }
        }

        return json
    }

    func contentItemJSON(premium: Bool) -> JSONValue {
        let data = BundleHelper.loadData("contentItem.json")
        var json = JSONValue.fromData(data)
        json[objectValue: "data"]?.editObject { contentItem in
            contentItem["id"] = .string(self.contentUUID)
            contentItem["isPremium"] = .bool(premium)
            contentItem["isLiked"] = .bool(isContentLiked)
            contentItem["isBookmarked"] = .bool(isContentBookmarked)
        }
        return json
    }
}
