import Foundation

class FeedStoryDynamicMocks {

    private let host = "https://rest.dev.fstr.app"
    private let contentHost = "https://content.cdn-simple-life.com"

    let storyID = UUID().uuidString

    var progress: Double = 0
    var isLiked = false
    var isBookmarked = false

    func mocks() -> [ServerMockData] {
        [
            .init(urlTemplate: "\(host)/v1/content/\(storyID)/progress",
                  handler: .withJSONRequestBody(process: { [weak self] _, json in
                      let progress: Double
                      switch json.object!["progress"]! {
                      case .double(let value):
                          progress = value
                      case .int(let value):
                          progress = Double(value)
                      default:
                          return .notAcceptable(nil)
                      }
                      self?.progress = progress
                      puts("\(Self.self): progress = \(progress)")
                      return .ok(.json(["data": progress]))
                  })),
            .init(urlTemplate: "\(contentHost)/articles/en/\(storyID).json",
                  handler: .init(run: { [weak self] _ in
                      guard let self = self else {
                          return .internalServerError(nil)
                      }
                      let data = BundleHelper.loadData("contentStoryArticle.json")
                      var json = JSONValue.fromData(data)

                      json[objectValue: "id"] = .string(self.storyID)

                      return .ok(.jsonValue(json))
                  })),
            .init(urlTemplate: "\(host)/v1/content/preview",
                  handler: .withJSONRequestBody(process: { [weak self] _, json in
                      guard let self = self else {
                          return .internalServerError(nil)
                      }
                      let ids = json.object!["ids"]!.array!.map { $0.string! }
                      guard ids == [self.storyID] else {
                          return .notAcceptable(nil)
                      }

                      let data = BundleHelper.loadData("contentPreviewVerticalListStory.json")
                      var json = JSONValue.fromData(data)

                      json[objectValue: "data"]?[objectValue: "items"]?.editArrayInPlace { item in
                          item[objectValue: "contentItem"]?.editObject { contentItem in
                              self.updateContentItem(&contentItem)
                          }
                      }

                      return .ok(.jsonValue(json))
                  })),
            .init(urlTemplate: "\(host)/v1/feed/section/triggered_content",
                  handler: .init(run: { [weak self] _ in
                      guard let self = self else {
                          return .internalServerError(nil)
                      }
                      let data = BundleHelper.loadData("triggeredContentPremiumOnly.json")
                      var json = JSONValue.fromData(data)

                      json[objectValue: "data"]?[objectValue: "items"]?.editArrayInPlace { item in
                          item[objectValue: "contentItem"]?.editObject { contentItem in
                              self.updateContentItem(&contentItem)
                          }
                      }

                      return .ok(.jsonValue(json))
                  })),
            .init(urlTemplate: "\(host)/v1/feed/sections",
                  handler: .init(run: { [weak self] _ in
                      guard let self = self else {
                          return .internalServerError(nil)
                      }
                      let data = BundleHelper.loadData("sectionsOnlyPremium.json")
                      var json = JSONValue.fromData(data)

                      json[objectValue: "data"]?[objectValue: "sections"]?.editArrayInPlace { section in
                          section[objectValue: "items"]?.editArrayInPlace { item in
                              item[objectValue: "contentItem"]?.editObject { contentItem in
                                  self.updateContentItem(&contentItem)
                              }
                          }
                      }

                      return .ok(.jsonValue(json))
                  })),
            .init(urlTemplate: "\(host)/v1/content/:content_id/like",
                  handler: .withJSONRequestBody(process: { [weak self] request, json in
                      guard let self = self else {
                          return .internalServerError(nil)
                      }
                      guard request.params[":content_id"] == self.storyID else {
                          return .notAcceptable(nil)
                      }
                      let newValue = json.object!["likeValue"]!.bool!
                      self.isLiked = newValue
                      return .ok(.json(["data": newValue]))
                  })),
            .init(urlTemplate: "\(host)/v1/content/:content_id/bookmark",
                  handler: .withJSONRequestBody(process: { [weak self] request, json in
                      guard let self = self else {
                          return .internalServerError(nil)
                      }
                      guard request.params[":content_id"] == self.storyID else {
                          return .notAcceptable(nil)
                      }
                      let newValue = json.object!["bookmarkValue"]!.bool!
                      self.isBookmarked = newValue
                      return .ok(.json(["data": newValue]))
                  })),
            .init(urlTemplate: "\(host)/v1/content/\(storyID)",
                  handler: .init(run: { [weak self] _ in
                      guard let self = self else {
                          return .internalServerError(nil)
                      }

                      let json = self.contentItemJSON()
                      return .ok(.jsonValue(json))
                  })),

            feedMock()
        ]
    }

    private func feedMock() -> ServerMockData {
        .init(urlTemplate: "\(host)/v2/feed",
              handler: .init(run: { [weak self] _ in
                  guard let self = self else {
                      return .internalServerError(nil)
                  }

                  let itemsJson: JSONValue = {
                      let data = BundleHelper.loadData("triggeredContentPremiumOnly.json")
                      var json = JSONValue.fromData(data)

                      json[objectValue: "data"]?[objectValue: "items"]?.editArrayInPlace { item in
                          item[objectValue: "contentItem"]?.editObject { contentItem in
                              self.updateContentItem(&contentItem)
                          }
                      }

                      return json[objectValue: "data"]![objectValue: "items"]!
                  }()

                  let data = BundleHelper.loadData("feedBookmarkedAndViewed.json")
                  var json = JSONValue.fromData(data)

                  json[objectValue: "data"]?[objectValue: "tabs"]?.editArrayInPlace { tab in
                      let tabID = tab.object!["id"]!.string!

                      tab[objectValue: "sections"]?.editArray { sections in
                          sections.removeAll { _ in
                              switch tabID {
                              case "recently_viewed":
                                  return true
                              case "bookmarks":
                                  return !self.isBookmarked
                              default:
                                  return false
                              }
                          }
                          sections.mapInPlace { section in
                              if tabID == "all" {
                                  section[objectValue: "type"] = .string("verticalList")
                              }
                              section[objectValue: "items"] = itemsJson
                          }
                      }
                  }

                  return .ok(.jsonValue(json))
              }))
    }

    private func contentItemJSON() -> JSONValue {
        let data = BundleHelper.loadData("contentItemStory.json")
        var json = JSONValue.fromData(data)
        json[objectValue: "data"]?.editObject { contentItem in
            updateContentItem(&contentItem)
        }
        return json
    }

    private func updateContentItem(_ contentItem: inout [String: JSONValue]) {
        contentItem["id"] = .string(self.storyID)
        contentItem["progress"] = .double(self.progress)
        contentItem["isLiked"] = .bool(self.isLiked)
        contentItem["isBookmarked"] = .bool(self.isBookmarked)
        contentItem["tags"] = .object([:])
    }
}
