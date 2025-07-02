import Foundation
import Common

extension SQLMealIntake {

    static func make(json: [String: Any]) -> SQLMealIntake? {
        guard let id = json["id"] as? String,
              let date = (json["date"] as? String).flatMap(DateFormatter.iso8601DateTimeFormatter.date(from:)) else {
            return nil
        }

        let waterDict = json["water"] as? [String: Any]

        return SQLMealIntake(
            id: UUID().uuidString,
            serverId: id,
            date: date,
            intakeType: (json["type"] as? String).flatMap(SQLMealIntake.IntakeType.from(apiString:)) ?? .snack,
            secondsFromGMT: json["secondsFromGMT"] as? Int,
            startsFasting: (json["startsFasting"] as? Bool) ?? false,
            containsBreaksFastDrink: (waterDict?["breaksFast"] as? Bool) ?? false,
            mealContext: SQLMealContext.make(json: json),
            waterContext: SQLWaterContext.make(json: json),
            fastingContext: SQLFastingContext.make(json: json),
            feedback: SQLFoodFeedback.make(json: json)
        )
    }
}

private extension SQLMealIntake.IntakeType {

    static func from(apiString: String) -> SQLMealIntake.IntakeType? {
        switch apiString {
        case "Meal":
            return .meal
        case "Snack":
            return .snack
        case "Drink":
            return .drink
        default:
            return nil
        }
    }

    var toAPIString: String {
        switch self {
        case .meal: return "Meal"
        case .snack: return "Snack"
        case .drink: return "Drink"
        }
    }
}

extension SQLFoodFeedback {

    static func make(json: [String: Any]) -> SQLFoodFeedback? {
        guard let feedbackJSON = json["feedback"] as? [String: Any],
              let scoreRawValue = feedbackJSON["score"] as? String,
              let score = Score(rawValue: scoreRawValue),
              let labels = (feedbackJSON["labels"] as? [[String: Any]])?.compactMap(SQLFoodFeedback.Label.make),
              let calories = (feedbackJSON["calories"] as? [String: Any]).flatMap(SQLFoodFeedback.Calories.make),
              let nutrients = (feedbackJSON["nutrients"] as? [String: Any]).flatMap(SQLFoodFeedback.Nutrients.make),
              let meals = (feedbackJSON["meals"] as? [String: [String: Any]])?.reduce(into: [SQLFoodFeedback.Meal](), {
                  if let scoreRawValue = $1.value["level"] as? String,
                     let score = SQLFoodFeedback.Score(rawValue: scoreRawValue) {
                      $0.append(SQLFoodFeedback.Meal(id: $1.key, score: score))
                  }
              }) else {
            return nil
        }

        return .init(
            score: score,
            labels: labels,
            calories: calories,
            nutrients: nutrients,
            meals: meals,
            isRecommended: feedbackJSON["isRecommended"] as? Bool
        )
    }
}

private extension SQLFoodFeedback.Label {

    static func make(json: [String: Any]) -> SQLFoodFeedback.Label? {
        guard let nutrientRawValue = json["nutrient"] as? String,
              let nutrient = NutrientType(rawValue: nutrientRawValue),
              let levelRawValue = json["level"] as? String,
              let level = Level(rawValue: levelRawValue),
              let qualityRawValue = json["quality"] as? String,
              let quality = Quality(rawValue: qualityRawValue) else {
            return nil
        }

        return .init(
            nutrient: nutrient,
            level: level,
            quality: quality,
            contributorsFoodItemIds: json["contributorsFoodItemIds"] as? [Int]
        )
    }
}

private extension SQLFoodFeedback.Calories {

    static func make(json: [String: Any]) -> SQLFoodFeedback.Calories? {
        guard let scoreRawValue = json["score"] as? String,
              let score = Score(rawValue: scoreRawValue),
              let value = json["value"] as? Double else {
            return nil
        }

        return .init(score: score, value: value)
    }
}

private extension SQLFoodFeedback.Nutrients {

    static func make(json: [String: Any]) -> SQLFoodFeedback.Nutrients? {
        guard let carbohydrate = (json["carbohydrate"] as? [String: Any]).flatMap(SQLFoodFeedback.Nutrients.Item.make),
              let fat = (json["fat"] as? [String: Any]).flatMap(SQLFoodFeedback.Nutrients.Item.make),
              let protein = (json["protein"] as? [String: Any]).flatMap(SQLFoodFeedback.Nutrients.Item.make) else {
            return nil
        }

        return .init(
            carbohydrate: carbohydrate,
            fat: fat,
            protein: protein
        )
    }
}

private extension SQLFoodFeedback.Nutrients.Item {

    static func make(json: [String: Any]) -> SQLFoodFeedback.Nutrients.Item? {
        guard let percent = json["percent"] as? Double,
              let value = json["value"] as? Double else {
            return nil
        }

        return .init(percent: percent, value: value)
    }
}

private extension SQLFastingContext {

    static func make(json: [String: Any]) -> SQLFastingContext {
        SQLFastingContext(
            fastingSeconds: json["fastingSeconds"] as? Int,
            didConfirmLongFastingPeriod: json["confirmed"] as? Bool,
            moodScore: MoodScore.make(fromAPIValue: json["fastingMoodScore"] as? Int),
            note: json["fastingDescription"] as? String,
            stars: json["fastingStars"] as? Int,
            symptoms: json["fastingSymptoms"] as? [String]
        )
    }
}

private extension SQLFastingContext.MoodScore {

    static func make(fromAPIValue apiValue: Int?) -> SQLFastingContext.MoodScore? {
        switch apiValue {
        case 0:
            return .hard
        case 1:
            return .normal
        case 2:
            return .easy
        default:
            return nil
        }
    }

    var toAPIValue: Int {
        switch self {
        case .hard:
            return 0
        case .normal:
            return 1
        case .easy:
            return 2
        }
    }
}

private extension SQLWaterContext {

    static func make(json: [String: Any]) -> SQLWaterContext? {
        guard let waterJSON = json["water"] as? [String: Any] else { return nil }
        guard let drinksJSON = waterJSON["drinks"] as? [[String: Any]] else { return nil }
        let trackId = waterJSON["trackId"] as? String

        return SQLWaterContext(
            drinks: drinksJSON.compactMap(SQLDrink.make),
            trackId: trackId
        )
    }
}

private extension SQLDrink {

    static func make(json: [String: Any]) -> SQLDrink? {
        guard let drinkId = json["drinkId"] as? String,
              let count = json["count"] as? Int,
              let additionalTagId = json["additionalTagId"] as? String,
              let factor = json["factor"] as? Double,
              let milliliters = json["milliliters"] as? Double else {

            return nil
        }

        let source: UserHealthDataSource = (json["source"] as? String).flatMap(UserHealthDataSource.init(rawValue:))
            ?? ((json["fromAppleHealth"] as? Bool) == true ? .appleHealth : .local) // Backward compatibility

        return SQLDrink(
            drinkId: drinkId,
            additionalTagId: additionalTagId,
            factor: factor,
            milliliters: milliliters,
            count: count,
            source: source
        )
    }
}

private extension SQLMealContext {

    static func make(json: [String: Any]) -> SQLMealContext {
        SQLMealContext(
            mealName: (json["mealName"] as? String).flatMap { .init(rawValue: $0) },
            mealDescription: json["description"] as? String,
            photoURLs: (json["photoUrls"] as? [String])?.compactMap(URL.init(string:)) ?? [],
            meals: (json["meals"] as? [[String: Any]])?.compactMap(SQLMealContext.MealData.make) ?? [],
            trackId: json["trackId"] as? String,
            needParseFreeText: nil,
            needRecognizePhotos: json["needRecognizePhotos"] as? Bool
        )
    }
}

private extension SQLMealContext.MealData {

    static func make(json: [String: Any]) -> SQLMealContext.MealData? {
        guard let dbName = json["dbName"] as? String,
              let dbId = json["dbId"] as? String else {
            return nil
        }

        return SQLMealContext.MealData(
            dbName: dbName,
            dbId: dbId,
            quantity: json["quantity"] as? Double,
            quantityUnitId: json["quantityUnitId"] as? String,
            aliasName: json["aliasName"] as? String
        )
    }
}

extension SQLMealIntake {

    static func mealIntakeToDict(_ intake: SQLMealIntake) -> [String: Any] {
        var result: [String: Any] = [
            "date": DateFormatter.iso8601DateTimeFormatter.string(from: intake.date), // required
            "type": intake.intakeType.toAPIString, // required
            "secondsFromGMT": intake.secondsFromGMT ?? TimeZone.current.secondsFromGMT(), // required
            "startsFasting": intake.startsFasting, // required
            "confirmed": intake.fastingContext.didConfirmLongFastingPeriod ?? NSNull(),
            "fastingMoodScore": intake.fastingContext.moodScore?.toAPIValue ?? NSNull(),
            "fastingDescription": intake.fastingContext.note ?? NSNull(),
            "fastingStars": intake.fastingContext.stars ?? NSNull(),
            "fastingSymptoms": intake.fastingContext.symptoms ?? NSNull()
        ]

        if let mealContext = intake.mealContext {
            result["mealName"] = mealContext.mealName?.rawValue ?? NSNull()
            result["photoUrls"] = mealContext.photoURLsArray.filter { !$0.isFileURL }.map { $0.absoluteString }
            result["description"] = mealContext.mealDescription ?? NSNull()
            result["meals"] = mealContext.meals.map {
                let mealDict = [
                    "dbName": $0.dbName,
                    "dbId": $0.dbId,
                    "quantity": $0.quantity ?? NSNull(),
                    "quantityUnitId": $0.quantityUnitId ?? NSNull(),
                    "aliasName": $0.aliasName ?? NSNull()
                ] as [String: Any]

                return mealDict
            }
            result["trackId"] = mealContext.trackId ?? NSNull()

            if let needRecognizePhotos = mealContext.needRecognizePhotos {
                result["needRecognizePhotos"] = needRecognizePhotos
            }
        }

        if let waterContext = intake.waterContext {
            result["water"] = [
                "breaksFast": intake.containsBreaksFastDrink,
                "drinks": waterContext.drinks.map {
                    [
                        "drinkId": $0.drinkId,
                        "additionalTagId": $0.additionalTagId,
                        "factor": $0.factor,
                        "milliliters": $0.milliliters,
                        "count": $0.count,
                        "source": $0.source.rawValue,
                        "trackId": waterContext.trackId ?? NSNull()
                    ] as [String: Any]
                }
            ] as [String: Any]
        }

        result["id"] = intake.id
        result["fastingSeconds"] = intake.fastingContext.fastingSeconds ?? NSNull()
        if let feedback = intake.feedback {
            result["feedback"] = [
                "score": feedback.score.rawValue,
                "labels": feedback.labels.map {
                    [
                        "nutrient": $0.nutrient.rawValue,
                        "level": $0.level.rawValue,
                        "quality": $0.quality.rawValue
                    ]
                },
                "calories": [
                    "score": feedback.calories.score.rawValue,
                    "value": feedback.calories.value
                ],
                "nutrients": [
                    "carbohydrate": [
                        "percent": feedback.nutrients.carbohydrate.percent,
                        "value": feedback.nutrients.carbohydrate.value
                    ],
                    "fat": [
                        "percent": feedback.nutrients.fat.percent,
                        "value": feedback.nutrients.fat.value
                    ],
                    "protein": [
                        "percent": feedback.nutrients.protein.percent,
                        "value": feedback.nutrients.protein.value
                    ]
                ],
                "meals": feedback.meals.reduce(into: [String: [String: String]](), {
                    $0[$1.id] = ["level": $1.score.rawValue]
                }),
                "isRecommended": feedback.isRecommended ?? NSNull()
            ] as [String: Any]
        }

        return result
    }
}
