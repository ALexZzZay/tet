import Foundation

public struct FastingContext: Hashable, Codable {
    public var fastingSeconds: Int?
    public var didConfirmLongFastingPeriod: Bool?
    public var moodScore: MoodScore?
    public var note: String?
    public var stars: Int?
    public var symptoms: [String]?

    public init(
        fastingSeconds: Int? = nil,
        didConfirmLongFastingPeriod: Bool? = nil,
        moodScore: MoodScore? = nil,
        note: String? = nil,
        stars: Int? = nil,
        symptoms: [String]? = nil
    ) {
        self.fastingSeconds = fastingSeconds
        self.didConfirmLongFastingPeriod = didConfirmLongFastingPeriod
        self.moodScore = moodScore
        self.note = note
        self.stars = stars
        self.symptoms = symptoms
    }
}

extension FastingContext {
    public enum MoodScore: String, Hashable, Codable {
        case easy
        case normal
        case hard
    }
}
