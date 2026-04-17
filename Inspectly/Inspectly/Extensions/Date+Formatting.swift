//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

extension Date {
    /// Format as relative time (e.g., "2m ago", "1h ago")
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// Format as full timestamp
    var fullTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm:ss a"
        return formatter.string(from: self)
    }

    /// Format as time only
    var timeOnly: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a"
        return formatter.string(from: self)
    }

    /// Format as short date
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }

    /// Format as group heading
    var groupHeading: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: self)
        }
    }

    /// Date for mock data generation
    static func mockDate(minutesAgo: Int) -> Date {
        Date().addingTimeInterval(-Double(minutesAgo) * 60)
    }

    static func mockDate(hoursAgo: Int) -> Date {
        Date().addingTimeInterval(-Double(hoursAgo) * 3600)
    }

    static func mockDate(daysAgo: Int) -> Date {
        Date().addingTimeInterval(-Double(daysAgo) * 86400)
    }
}
