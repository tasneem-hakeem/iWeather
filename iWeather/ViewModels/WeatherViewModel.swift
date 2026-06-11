//
//  WeatherViewModel.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import Foundation
import CoreLocation

final class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var weatherResponse: WeatherResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let service: WeatherServiceProtocol
    private let locationManager = CLLocationManager()

    init(service: WeatherServiceProtocol = WeatherService()) {
        self.service = service
        super.init()
        //locationManager.delegate = self
        //locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    convenience init(query: String, service: WeatherServiceProtocol = WeatherService()) {
        self.init(service: service)
        fetch(query: query)
    }

    func fetchWeatherForCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer

        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            fetch(query: "30.0715495,31.0215953")
        }
    }

    func fetch(query: String) {
        isLoading    = true
        errorMessage = nil
        service.fetchWeather(query: query) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                self.weatherResponse = response
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        let query = "\(loc.coordinate.latitude),\(loc.coordinate.longitude)"
        fetch(query: query)
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {

        fetch(query: "30.0715495,31.0215953")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else if status == .denied || status == .restricted {
            fetch(query: "30.0715495,31.0215953")
        }
    }

    var locationName: String { weatherResponse?.location.name ?? "--" }
    var currentTemp: String  {
        guard let t = weatherResponse?.current.tempC else { return "--" }
        return "\(Int(t.rounded()))°"
    }
    var conditionText: String { weatherResponse?.current.condition.text ?? "" }
    var conditionIcon: String {
        guard var icon = weatherResponse?.current.condition.icon else { return "" }
        if icon.hasPrefix("//") { icon = "https:" + icon }
        return icon
    }

    var highTemp: String {
        guard let d = weatherResponse?.forecast.forecastday.first?.day else { return "--" }
        return "H:\(Int(d.maxtempC.rounded()))°"
    }
    var lowTemp: String {
        guard let d = weatherResponse?.forecast.forecastday.first?.day else { return "--" }
        return "L:\(Int(d.mintempC.rounded()))°"
    }

    var visibility: String {
        guard let v = weatherResponse?.current.visKm else { return "--" }
        return "\(Int(v)) km"
    }
    var humidity: String {
        guard let h = weatherResponse?.current.humidity else { return "--" }
        return "\(h)%"
    }
    var feelsLike: String {
        guard let f = weatherResponse?.current.feelslikeC else { return "--" }
        return "\(Int(f.rounded()))°"
    }
    var pressure: String {
        guard let p = weatherResponse?.current.pressureMb else { return "--" }
        return "\(Int(p))"
    }

    var forecastDays: [ForecastDay] { weatherResponse?.forecast.forecastday ?? [] }

    var timeOfDay: TimeOfDay {
        guard let localtime = weatherResponse?.location.localtime else {
            return TimeOfDay.fromDeviceClock()
        }
        return TimeOfDay.from(localtime: localtime)
    }
}
