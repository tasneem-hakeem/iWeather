//
//  WeatherBackground.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import SwiftUI

enum TimeOfDay {
    case morning   // 5:00 AM – 5:59 PM
    case evening   // 6:00 PM – 4:59 AM

    static func from(localtime: String) -> TimeOfDay {
        let parts = localtime.split(separator: " ")
        guard parts.count == 2 else { return .fromDeviceClock() }
        let timePart = String(parts[1])
        let components = timePart.split(separator: ":")
        guard let hour = components.first.flatMap({ Int($0) }) else {
            return .fromDeviceClock()
        }
        return (hour >= 5 && hour < 18) ? .morning : .evening
    }

    static func fromDeviceClock() -> TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        return (hour >= 5 && hour < 18) ? .morning : .evening
    }

    var foregroundColor: Color {
        switch self {
        case .morning: return .black
        case .evening: return .white
        }
    }

    var backgroundColor: Color {
        // return Color(red: 91, green: 102, blue: 122)
        switch self {
        case .morning: return Color(red: 0.44, green: 0.72, blue: 0.92)
        case .evening: return Color(red: 0.07, green: 0.07, blue: 0.25)
        }
    }
}


struct WeatherBackground: View {

    var timeOfDay: TimeOfDay

    var body: some View {
        if UIImage(named: imageName) != nil {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        } else {
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    private var imageName: String {
        timeOfDay == .morning ? "morning_bg" : "evening_bg"
    }

    private var gradientColors: [Color] {
        switch timeOfDay {
        case .morning:
            return [
                Color(red: 0.53, green: 0.81, blue: 0.98),
                Color(red: 0.99, green: 0.86, blue: 0.55)
            ]
        case .evening:
            return [
                Color(red: 0.05, green: 0.05, blue: 0.20),
                Color(red: 0.25, green: 0.10, blue: 0.40)
            ]
        }
    }
}
