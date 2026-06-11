//
//  WeatherService.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case serverError(Int)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL."
        case .noData: return "No data received from server."
        case .decodingFailed(let e): return "Failed to decode response: \(e.localizedDescription)"
        case .serverError(let code): return "Server returned error code \(code)."
        case .unknown(let e): return e.localizedDescription
        }
    }
}

protocol WeatherServiceProtocol {
    func fetchWeather(query: String,
                      completion: @escaping (Result<WeatherResponse, NetworkError>) -> Void)
    
    func searchLocations(query: String,
                         completion: @escaping (Result<[LocationSuggestion], NetworkError>) -> Void)

}

final class WeatherService: WeatherServiceProtocol {

    private let apiKey = "a72a6943cbc2438daba161251260606"
    private let baseURL = "https://api.weatherapi.com/v1/forecast.json"

    func fetchWeather(query: String,
                      completion: @escaping (Result<WeatherResponse, NetworkError>) -> Void) {

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "days", value: "3"),
            URLQueryItem(name: "aqi", value: "yes"),
            URLQueryItem(name: "alerts", value: "no")
        ]

        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.unknown(error))) }
                return
            }

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    completion(.failure(.serverError(httpResponse.statusCode)))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decodingFailed(error))) }
            }
        }
        task.resume()
    }
    
    func searchLocations(query: String,
                         completion: @escaping (Result<[LocationSuggestion], NetworkError>) -> Void) {
        var components = URLComponents(string: "https://api.weatherapi.com/v1/search.json")
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: query)
        ]
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.unknown(error))) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                return
            }
            do {
                let decoded = try JSONDecoder().decode([LocationSuggestion].self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decodingFailed(error))) }
            }
        }.resume()
    }
}
