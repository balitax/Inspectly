//
//  Created by Agus Cahyono on 2026-04-17.
//  GitHub: https://github.com/balitax
//

import Foundation

// MARK: - Request Group

struct RequestGroup: Identifiable {
    let id: String
    let title: String
    let date: Date
    var requests: [NetworkRequest]

    init(title: String, date: Date, requests: [NetworkRequest]) {
        self.id = title
        self.title = title
        self.date = date
        self.requests = requests
    }
}

extension RequestGroup {
    /// Groups requests by date using relative date formatting
    static func groupByDate(_ requests: [NetworkRequest]) -> [RequestGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: requests) { request -> String in
            if calendar.isDateInToday(request.timestamp) {
                return "Today"
            } else if calendar.isDateInYesterday(request.timestamp) {
                return "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMM d"
                return formatter.string(from: request.timestamp)
            }
        }

        return grouped.map { key, requests in
            let date = requests.first?.timestamp ?? Date()
            return RequestGroup(
                title: key,
                date: date,
                requests: requests.sorted { $0.timestamp > $1.timestamp }
            )
        }
        .sorted { $0.date > $1.date }
    }
}
