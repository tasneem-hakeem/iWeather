//
//  WeatherBackground.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import SwiftUI

enum TimeOfDay {
    case morning
    case evening

    static var current: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        return (hour >= 5 && hour < 18) ? .morning : .evening
    }

    var foregroundColor: Color {
        switch self {
        case .morning: return .black
        case .evening: return .white
        }
    }
}


struct WeatherBackground: View {

    var body: some View {
        let time = TimeOfDay.current
        ZStack {
            if UIImage(named: backgroundName(time)) != nil {
                Image(backgroundName(time))
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                LinearGradient(
                    gradient: Gradient(colors: gradientColors(time)),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
    }

    private func backgroundName(_ time: TimeOfDay) -> String {
        time == .morning ? "morning_bg" : "evening_bg"
    }

    private func gradientColors(_ time: TimeOfDay) -> [Color] {
        switch time {
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


struct WeatherBackground_Previews: PreviewProvider {
    static var previews: some View {
        WeatherBackground()
    }
}
