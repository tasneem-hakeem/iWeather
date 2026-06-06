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
                ContentView()
                    .tabItem {
                        Label("Weather", systemImage: "cloud.sun.fill")
                    }

                SearchView(locationStore: locationStore)
                    .tabItem {
                        Label("Locations", systemImage: "map.fill")
                    }
            }
        }
    }
}
