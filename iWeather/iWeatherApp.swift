//
//  iWeatherApp.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import SwiftUI

@main
struct iWeatherApp: App {
    @StateObject private var locationStore = LocationStore()

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    ContentView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Weather", systemImage: "cloud.sun.fill")
                }

                NavigationView {          
                    SearchView(locationStore: locationStore)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Label("Locations", systemImage: "map.fill")
                }
            }
        }
    }
}
