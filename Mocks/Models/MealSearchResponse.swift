import Foundation
public import Common

public struct MealSearchResponse: Codable {

    public struct Meal: Codable, Equatable, Sendable {
        public let id: String?
        public let dbId: String?
        public let dbName: String?
        public let name: String
        public let imageURL: ContentImage?
        public let units: [Unit]
        public let beverageInfo: BeverageInfo?
        public let serving: Serving?
        public let labels: [Label]?
        public let tags: [String]?
        public let date: Date?
        public let quantity: Double?
        public let quantityUnitId: String?
        public let isFruit: Bool?
        public let isVegetable: Bool?

        public var mealId: String {
            if let id {
                return id
            }

            if let dbId, dbName == nil {
                return dbId
            }

            if let dbId, let dbName {
                return dbId + dbName
            }

            return name
        }
    }

    public struct Label: Codable, Equatable, Sendable {
        public enum LabelType: String, Codable, Sendable {
            case protein
            case fiber
            case plainText = "plain_text"
        }

        public let labelType: LabelType
        public let text: String
    }

    public struct Unit: Codable, Equatable, Sendable {
        let id: String
        let weight: Double
        let name: String
    }

    public struct BeverageInfo: Codable, Equatable, Sendable {
        let breakFast: Bool
        let hydrationRatio: Double
    }

    public struct Serving: Codable, Equatable, Sendable {
        let id: String
        let number: Double
        let unitId: String
    }

    let data: [Meal]
}
