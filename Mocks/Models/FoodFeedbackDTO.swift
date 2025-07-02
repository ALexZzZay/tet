import Foundation
import Common

public struct FoodFeedbackDTO: Hashable, Sendable {

    private struct MealItem: Codable {
        let level: Score
    }

    public struct Meal: Hashable, Codable, Sendable {

        public let id: String
        public let score: Score

        public init(id: String, score: Score) {
            self.id = id
            self.score = score
        }
    }

    public enum Score: String, Codable, Sendable {
        case low
        case fair
        case good
        case optimal
    }

    public struct Calories: Hashable, Codable, Sendable {

        public enum Score: String, Codable, Sendable {
            case low
            case moderate
            case high
        }

        public let score: Score
        public let value: Double

        public init(score: Score, value: Double) {
            self.score = score
            self.value = value
        }
    }

    public struct Label: Hashable, Codable, Sendable {

        public enum NutrientType: String, Codable, Sendable {
            case protein
            case sugar
            case fiber
            case calories
            case satFat
            case unsatFatsToSatFats
            case calcium
            case sodium
        }

        public enum Level: String, Codable, Sendable {
            case low
            case high
            case moderate
        }

        public enum Quality: String, Codable, Sendable {
            case bad
            case good
        }

        public let nutrient: NutrientType
        public let level: Level
        public let quality: Quality
        public let contributorsFoodItemIds: [Int]?

        public init(nutrient: NutrientType, level: Level, quality: Quality, contributorsFoodItemIds: [Int]?) {
            self.nutrient = nutrient
            self.level = level
            self.quality = quality
            self.contributorsFoodItemIds = contributorsFoodItemIds
        }
    }

    public struct Nutrients: Hashable, Codable, Sendable {

        public struct Item: Hashable, Codable, Sendable {

            public let percent: Double
            public let value: Double

            public init(percent: Double, value: Double) {
                self.percent = percent
                self.value = value
            }
        }

        public let carbohydrate: Item
        public let fat: Item
        public let protein: Item

        public init(carbohydrate: Item, fat: Item, protein: Item) {
            self.carbohydrate = carbohydrate
            self.fat = fat
            self.protein = protein
        }
    }

    public let score: Score
    public let labels: [Label]
    public let calories: Calories
    public let nutrients: Nutrients
    public let meals: [Meal]
    public let isRecommended: Bool?

    public init(score: Score, labels: [Label], calories: Calories, nutrients: Nutrients, meals: [Meal], isRecommended: Bool?) {
        self.score = score
        self.labels = labels
        self.calories = calories
        self.nutrients = nutrients
        self.meals = meals.sorted(by: { $0.id < $1.id })
        self.isRecommended = isRecommended
    }
}

extension FoodFeedbackDTO: Decodable {

    private enum CodingKeys: String, CodingKey {
        case score
        case labels
        case calories
        case nutrients
        case meals
        case isRecommended
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        score = try container.decode(Score.self, forKey: .score)
        labels = try container.decodeArraySkipFailed(of: Label.self, forKey: .labels)
        calories = try container.decode(Calories.self, forKey: .calories)
        nutrients = try container.decode(Nutrients.self, forKey: .nutrients)

        if let v1Meals = try? Self.decodeMealsV1(from: container) {
            meals = v1Meals.sorted(by: { $0.id < $1.id })
        } else {
            meals = try Self.decodeMealsV2(from: container).sorted(by: { $0.id < $1.id })
        }

        isRecommended = try container.decodeIfPresent(Bool.self, forKey: .isRecommended)
    }

    private static func decodeMealsV1(from container: KeyedDecodingContainer<CodingKeys>) throws -> [Meal] {
        let mealsList = try container.decode([SafeDecodable<Meal>].self, forKey: .meals)
        return mealsList.compactMap { $0.value }
    }

    private static func decodeMealsV2(from container: KeyedDecodingContainer<CodingKeys>) throws -> [Meal] {
        let mealsDict = try container.decode([String: SafeDecodable<MealItem>].self, forKey: .meals)
        return mealsDict.compactMapValues { $0.value }.map { Meal(id: $0.key, score: $0.value.level) }
    }
}

extension FoodFeedbackDTO: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(score, forKey: .score)
        try container.encode(labels, forKey: .labels)
        try container.encode(calories, forKey: .calories)
        try container.encode(nutrients, forKey: .nutrients)
        try container.encode(Self.encodeMeals(from: meals), forKey: .meals)
        try container.encodeIfPresent(isRecommended, forKey: .isRecommended)
    }

    private static func encodeMeals(from meals: [Meal]) -> [String: MealItem] {
        return meals.reduce(into: [:]) { $0[$1.id] = MealItem(level: $1.score) }
    }
}
