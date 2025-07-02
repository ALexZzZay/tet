import Foundation
import Common

struct SQLMealContext: Codable {
    enum MealName: String, Codable, Hashable, Sendable {
        case breakfast
        case lunch
        case dinner
        case snack
    }

    var mealName: MealName?
    var mealDescription: String?
    private var photoURLs: [String]
    var meals: [MealData]
    var trackId: String?
    var needParseFreeText: Bool? // local only
    var needRecognizePhotos: Bool?

    init(
        mealName: MealName?,
        mealDescription: String?,
        photoURLs: [URL],
        meals: [MealData],
        trackId: String?,
        needParseFreeText: Bool?,
        needRecognizePhotos: Bool?
    ) {
        self.mealName = mealName
        self.mealDescription = mealDescription
        self.photoURLs = photoURLs.map(absoluteURLToString)
        self.meals = meals
        self.trackId = trackId
        self.needParseFreeText = needParseFreeText
        self.needRecognizePhotos = needRecognizePhotos
    }

    var photoURLsArray: [URL] {
        get { photoURLs.compactMap(urlStringToAbsoluteURL) }
        set { photoURLs = newValue.map(absoluteURLToString) }
    }

    private enum Keys: String, CodingKey {
        case mealName
        case mealDescription
        case photoURLs
        case meals
        case trackId
        case needParseFreeText
        case needRecognizePhotos
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        mealName = try container.decodeIfPresent(MealName.self, forKey: .mealName)
        mealDescription = try container.decodeIfPresent(String.self, forKey: .mealDescription)
        photoURLs = try container.decode([String].self, forKey: .photoURLs)
        meals = try container.decodeArrayIfPresentSkipFailed(of: MealData.self, forKey: .meals) ?? []
        trackId = try container.decodeIfPresent(String.self, forKey: .trackId)
        needParseFreeText = try container.decodeIfPresent(Bool.self, forKey: .needParseFreeText)
        needRecognizePhotos = try container.decodeIfPresent(Bool.self, forKey: .needRecognizePhotos)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encodeIfPresent(mealName, forKey: .mealName)
        try container.encode(mealDescription, forKey: .mealDescription)
        try container.encode(photoURLs, forKey: .photoURLs)
        try container.encode(meals, forKey: .meals)
        try container.encodeIfPresent(trackId, forKey: .trackId)
        try container.encodeIfPresent(needParseFreeText, forKey: .needParseFreeText)
        try container.encodeIfPresent(needRecognizePhotos, forKey: .needRecognizePhotos)
    }
}

extension SQLMealContext {

    struct MealData: Codable, Equatable {
        let dbName: String
        let dbId: String
        let quantity: Double?
        let quantityUnitId: String?
        let aliasName: String?
    }
}

// MARK: - URLS

private func urlStringToAbsoluteURL(_ urlString: String) -> URL? {
    guard let url = URL(string: urlString) else { return nil }
    let isFileUrl = url.scheme == nil

    return isFileUrl
        ? URL(fileURLWithPath: urlString, relativeTo: nil)
        : url
}

private func absoluteURLToString(_ url: URL) -> String {
    if url.isFileURL {
        return url.relativeString
    } else {
        return url.absoluteString
    }
}
