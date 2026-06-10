//
//  ContentView.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var vm = WeatherViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                WeatherBackground(timeOfDay: vm.timeOfDay)

                Group {
                    if vm.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: vm.timeOfDay.foregroundColor)
                                )
                                .scaleEffect(1.5)
                            Text("Fetching weather...")
                                .foregroundColor(vm.timeOfDay.foregroundColor)
                        }

                    } else if vm.weatherResponse != nil {
                        MainWeatherContent(vm: vm)

                    } else if let err = vm.errorMessage {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.icloud.fill")
                                .font(.system(size: 50))
                                .foregroundColor(vm.timeOfDay.foregroundColor.opacity(0.6))
                            Text(err)
                                .multilineTextAlignment(.center)
                                .foregroundColor(vm.timeOfDay.foregroundColor)
                                .padding(.horizontal, 32)
                            Button("Retry") {
                                vm.fetchWeatherForCurrentLocation()
                            }
                            .foregroundColor(vm.timeOfDay.foregroundColor)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            vm.fetchWeatherForCurrentLocation()
        }
    }
}
