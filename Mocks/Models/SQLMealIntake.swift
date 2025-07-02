import Foundation

typealias SQLWaterContext = WaterContext
typealias SQLDrink = Drink
typealias SQLFastingContext = FastingContext
typealias SQLFoodFeedback = FoodFeedbackDTO

struct SQLMealIntake: Codable {

    var id: String
    var serverId: String?
    var date: Date
    var intakeType: IntakeType
    var secondsFromGMT: Int?
    var startsFasting: Bool
    var containsBreaksFastDrink: Bool
    var mealContext: SQLMealContext?
    var waterContext: SQLWaterContext?
    var fastingContext: SQLFastingContext
    var feedback: SQLFoodFeedback?
}

extension SQLMealIntake {
    public enum IntakeType: String, Hashable, Codable, Equatable, CaseIterable {
        case meal
        case snack
        case drink
    }
}
