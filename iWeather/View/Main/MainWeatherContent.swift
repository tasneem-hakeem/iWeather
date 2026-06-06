//
//  MainWeatherContent.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import SwiftUI

struct MainWeatherContent: View {

    @ObservedObject var vm: WeatherViewModel

    private var time: TimeOfDay { TimeOfDay.current }
    private var textColor: Color { time.foregroundColor }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                VStack(spacing: 4) {
                    Text(vm.locationName)
                        .font(.system(size: 34, weight: .medium))
                        .foregroundColor(textColor)

                    Text(vm.currentTemp)
                        .font(.system(size: 80, weight: .thin))
                        .foregroundColor(textColor)

                    Text(vm.conditionText)
                        .font(.title3)
                        .foregroundColor(textColor.opacity(0.85))

                    Text("\(vm.highTemp)  \(vm.lowTemp)")
                        .font(.subheadline)
                        .foregroundColor(textColor.opacity(0.75))

                    WeatherIcon(urlString: vm.conditionIcon, size: 72)
                        .padding(.top, 4)
                }
                .padding(.top, 60)
                .padding(.bottom, 24)

                VStack(alignment: .leading, spacing: 0) {
                    Text("3-DAY FORECAST")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(textColor.opacity(0.7))
                        .tracking(1.5)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 6)

                    Divider().background(textColor.opacity(0.3))

                    ForEach(Array(vm.forecastDays.enumerated()), id: \.element.id) { index, day in
                        NavigationLink(
                            destination: HourlyForecastView(
                                forecastDay: day,
                                timeOfDay: time
                            )
                        ) {
                            ForecastRowView(
                                forecastDay: day,
                                index: index,
                                textColor: textColor
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        if index < vm.forecastDays.count - 1 {
                            Divider()
                                .background(textColor.opacity(0.3))
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .background(Color.white.opacity(0.15))
                .cornerRadius(16)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)

                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        StatTileView(label: "Visibility", value: vm.visibility,   textColor: textColor)
                        StatTileView(label: "Humidity",   value: vm.humidity,     textColor: textColor)
                    }
                    HStack(spacing: 12) {
                        StatTileView(label: "Feels Like", value: vm.feelsLike,   textColor: textColor)
                        StatTileView(label: "Pressure",   value: vm.pressure,    textColor: textColor)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
    }
}
