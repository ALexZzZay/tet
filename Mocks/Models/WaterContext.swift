import Foundation

public struct WaterContext: Hashable, Codable {
    public var drinks: [Drink]
    public var trackId: String?

    public init(drinks: [Drink], trackId: String?) {
        self.drinks = drinks
        self.trackId = trackId
    }
}

public struct Drink: Hashable, Codable {
    public var drinkId: String
    public var additionalTagId: String
    public var factor: Double
    public var milliliters: Double
    public var count: Int
    public var source: UserHealthDataSource

    public init(
        drinkId: String,
        additionalTagId: String,
        factor: Double,
        milliliters: Double,
        count: Int,
        source: UserHealthDataSource
    ) {
        self.drinkId = drinkId
        self.additionalTagId = additionalTagId
        self.factor = factor
        self.milliliters = milliliters
        self.count = count
        self.source = source
    }
}

public enum UserHealthDataSource: String, Hashable, Codable {
    case local
    case appleHealth
    case fitbit
    case googleFit
    case samsungHealth

    public var isExternal: Bool {
        self != .local
    }
}
