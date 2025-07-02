import Foundation
import RestGenerated

struct MealFreeTextParsingResponse: Codable, Sendable {

    struct Portion: Codable, Sendable {
        let quantity: Double?
        let quantityUnitId: String?
    }

    let feedback: FoodFeedbackDTO?
    let foodItems: [MealSearchResponse.Meal]
    let portions: [String: Portion]
    let nameAliases: [String: String]

    enum CodingKeys: String, CodingKey {
        case feedback
        case foodItems
        case portions
        case nameAliases
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        feedback = try container.decodeIfPresent(FoodFeedbackDTO.self, forKey: .feedback)
        foodItems = try container.decodeArrayIfPresent(.foodItems) ?? []
        portions = try container.decodeIfPresent([String: Portion].self, forKey: .portions) ?? [:]
        nameAliases = try container.decodeIfPresent([String: String].self, forKey: .nameAliases) ?? [:]
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(feedback, forKey: .feedback)
        try container.encode(foodItems, forKey: .foodItems)
        try container.encode(portions, forKey: .portions)
        try container.encode(nameAliases, forKey: .nameAliases)
    }

    init(
        feedback: FoodFeedbackDTO? = nil,
        foodItems: [MealSearchResponse.Meal],
        portions: [String: Portion],
        nameAliases: [String: String]
    ) {
        self.feedback = feedback
        self.foodItems = foodItems
        self.portions = portions
        self.nameAliases = nameAliases
    }

    static let empty = MealFreeTextParsingResponse(foodItems: [], portions: [:], nameAliases: [:])
}
