//
//  HourlyForecastView.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//
import SwiftUI

struct HourlyForecastView: View {

    let forecastDay: ForecastDay
    let timeOfDay: TimeOfDay

    private var textColor: Color { timeOfDay.foregroundColor }

    private var upcomingHours: [Hour] {
        DateHelper.upcomingHours(from: forecastDay.hour)
    }

    var body: some View {
        ZStack {
            WeatherBackground(timeOfDay: timeOfDay)

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(upcomingHours.enumerated()), id: \.element.id) { index, hour in
                        HourlyRowView(
                            hour: hour,
                            isFirst: index == 0,
                            textColor: textColor
                        )

                        if index < upcomingHours.count - 1 {
                            Divider()
                                .background(textColor.opacity(0.3))
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitle(dayLabel, displayMode: .inline)
        .navigationBarColor(textColor)
    }

    private var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today     = formatter.string(from: Date())
        let tomorrow  = formatter.string(
            from: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        )
        if forecastDay.date == today    { return "Today" }
        if forecastDay.date == tomorrow { return "Tomorrow" }
        return DateHelper.dayLabel(for: forecastDay.date, index: 2)
    }
}

struct HourlyRowView: View {
    let hour: Hour
    let isFirst: Bool
    let textColor: Color

    private var iconURL: String {
        var icon = hour.condition.icon
        if icon.hasPrefix("//") { icon = "https:" + icon }
        return icon
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(DateHelper.hourLabel(epoch: hour.timeEpoch, isFirst: isFirst))
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(textColor)
                .frame(width: 80, alignment: .leading)
                .padding(.leading, 24)

            Spacer()

            WeatherIcon(urlString: iconURL, size: 36)

            Spacer()

            Text("\(Int(hour.tempC.rounded()))°")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(textColor)
                .frame(width: 70, alignment: .trailing)
                .padding(.trailing, 24)
        }
        .padding(.vertical, 14)
    }
}

extension View {
    func navigationBarColor(_ color: Color) -> some View {
        self.modifier(NavigationBarColorModifier(color: color))
    }
}

struct NavigationBarColorModifier: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content.onAppear {
            let uiColor = UIColor(color)
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor]
            UINavigationBar.appearance().tintColor = uiColor
        }
    }
}

struct HourlyForecastView_Previews: PreviewProvider {

    static let mockForecastDay = ForecastDay(
        date: "2026-06-07",
        day: Day(
            maxtempC: 32,
            mintempC: 22,
            condition: Condition(
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
                code: 1000
            )
        ),
        hour: [
            Hour(
                timeEpoch: Int(Date().timeIntervalSince1970),
                time: "2026-06-07 12:00",
                tempC: 30,
                condition: Condition(
                    text: "Sunny",
                    icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
                    code: 1000
                )
            ),
            Hour(
                timeEpoch: Int(Date().addingTimeInterval(3600).timeIntervalSince1970),
                time: "2026-06-07 13:00",
                tempC: 31,
                condition: Condition(
                    text: "Partly cloudy",
                    icon: "//cdn.weatherapi.com/weather/64x64/day/116.png",
                    code: 1003
                )
            ),
            Hour(
                timeEpoch: Int(Date().addingTimeInterval(7200).timeIntervalSince1970),
                time: "2026-06-07 14:00",
                tempC: 32,
                condition: Condition(
                    text: "Sunny",
                    icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
                    code: 1000
                )
            )
        ]
    )

    static var previews: some View {
        NavigationView {
            HourlyForecastView(
                forecastDay: mockForecastDay,
                timeOfDay: .evening
            )
        }
    }
}
