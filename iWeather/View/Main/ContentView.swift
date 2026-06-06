//
//  ContentView.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var vm = WeatherViewModel()

    private var time: TimeOfDay { TimeOfDay.current }
    private var textColor: Color { time.foregroundColor }

    var body: some View {
        NavigationView {
            ZStack {
                WeatherBackground()

                Group {
                    if vm.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: textColor)
                                )
                                .scaleEffect(1.5)
                            Text("Fetching weather...")
                                .foregroundColor(textColor)
                        }

                    } else if vm.weatherResponse != nil {
                        MainWeatherContent(vm: vm)

                    } else if let err = vm.errorMessage {
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.icloud.fill")
                                .font(.system(size: 50))
                                .foregroundColor(textColor.opacity(0.6))
                            Text(err)
                                .multilineTextAlignment(.center)
                                .foregroundColor(textColor)
                                .padding(.horizontal, 32)
                            Button("Retry") {
                                vm.fetchWeatherForCurrentLocation()
                            }
                            .foregroundColor(textColor)
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
