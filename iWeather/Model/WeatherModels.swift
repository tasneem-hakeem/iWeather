//
//  WeatherModels.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import Foundation

struct WeatherResponse: Codable {
    let location: Location
    let current: Current
    let forecast: Forecast
}

struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let localtime: String
}

struct Current: Codable {
    let tempC: Double
    let feelslikeC: Double
    let humidity: Int
    let visKm: Double
    let pressureMb: Double
    let condition: Condition

    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case feelslikeC = "feelslike_c"
        case humidity
        case visKm = "vis_km"
        case pressureMb = "pressure_mb"
        case condition
    }
}

struct Condition: Codable {
    let text: String
    let icon: String
    let code: Int
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Identifiable {
    var id: String { date }
    let date: String
    let day: Day
    let hour: [Hour]
}

struct Day: Codable {
    let maxtempC: Double
    let mintempC: Double
    let condition: Condition

    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case condition
    }
}

struct Hour: Codable, Identifiable {
    var id: String { timeEpoch.description }
    let timeEpoch: Int
    let time: String
    let tempC: Double
    let condition: Condition

    enum CodingKeys: String, CodingKey {
        case timeEpoch  = "time_epoch"
        case time
        case tempC      = "temp_c"
        case condition
    }
}

struct SavedLocation: Codable, Identifiable {
    let id: UUID
    let name: String
    let query: String   

    init(id: UUID = UUID(), name: String, query: String) {
        self.id    = id
        self.name  = name
        self.query = query
    }
}
