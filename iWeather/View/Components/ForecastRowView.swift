//
//  ForecastRowView.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import SwiftUI

struct ForecastRowView: View {
    let forecastDay: ForecastDay
    let index: Int
    let textColor: Color

    private var iconURL: String {
        var icon = forecastDay.day.condition.icon
        if icon.hasPrefix("//") { icon = "https:" + icon }
        return icon
    }

    var body: some View {
        HStack {
            Text(DateHelper.dayLabel(for: forecastDay.date, index: index))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(textColor)
                .frame(width: 90, alignment: .leading)

            Spacer()

            WeatherIcon(urlString: iconURL, size: 28)

            Spacer()

            Text(
                "\(Int(forecastDay.day.mintempC.rounded()))° - \(Int(forecastDay.day.maxtempC.rounded()))°"
            )
            .font(.subheadline)
            .foregroundColor(textColor)
            .frame(width: 100, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
    }
}


struct ForecastRowView_Previews: PreviewProvider {

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
                timeEpoch: 1780800000,
                time: "2026-06-07 12:00",
                tempC: 30,
                condition: Condition(
                    text: "Sunny",
                    icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
                    code: 1000
                )
            )
        ]
    )

    static var previews: some View {
        ForecastRowView(
            forecastDay: mockForecastDay,
            index: 0,
            textColor: .white
        )
        .padding()
        .background(Color.blue)
        .previewLayout(.sizeThatFits)
    }
}
