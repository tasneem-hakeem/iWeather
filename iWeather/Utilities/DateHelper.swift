//
//  DateHelper.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import Foundation

enum DateHelper {

    static var isMorning: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 5 && hour < 18
    }

    static func dayLabel(for dateString: String, index: Int) -> String {
        switch index {
        case 0: return "Today"
        case 1: return "Tomorrow"
        default:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard let date = formatter.date(from: dateString) else { return dateString }
            let display = DateFormatter()
            display.dateFormat = "EEE"
            return display.string(from: date)
        }
    }

    static func hourLabel(epoch: Int, isFirst: Bool) -> String {
        if isFirst { return "Now" }
        let date = Date(timeIntervalSince1970: TimeInterval(epoch))
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: date)
    }

    static func upcomingHours(from hours: [Hour]) -> [Hour] {
        let currentEpoch = Int(Date().timeIntervalSince1970)

        let currentHourEpoch = (currentEpoch / 3600) * 3600
        return hours.filter { $0.timeEpoch >= currentHourEpoch }
    }
}
