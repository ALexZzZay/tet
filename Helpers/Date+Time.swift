import Foundation

extension Calendar {

    static let gregorianCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.GMTTimeZone
        calendar.locale = Locale.current

        return calendar
    }()
}

extension TimeZone {

    static let GMTTimeZone = TimeZone(abbreviation: "GMT")!
}

extension Date {

    func with(timeZone: TimeZone, for date: Date? = nil) -> Date {
        with(timeZoneSecondsFromGMT: timeZone.secondsFromGMT(for: date ?? self))
    }

    func with(timeZoneSecondsFromGMT: Int) -> Date {
        addingTimeInterval(-TimeInterval(timeZoneSecondsFromGMT))
    }

    func bySetting(hours: Int) -> Date {
        let gregorianCalendar = Calendar.gregorianCalendar
        var components = gregorianCalendar.dateComponents([.hour, .minute, .second, .day, .month, .year], from: self)
        components.hour = hours

        if let result = gregorianCalendar.date(from: components) {
            return result
        }

        return self
    }
}
