//
//  SearchViewModel.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var suggestions: [LocationSuggestion] = []
    @Published var searchResult: WeatherResponse?
    @Published var isSearching: Bool = false
    @Published var isSuggesting: Bool = false
    @Published var errorMessage: String?

    private let service: WeatherServiceProtocol
    private var suggestTask: DispatchWorkItem?

    init(service: WeatherServiceProtocol = WeatherService()) {
        self.service = service
    }

    func onSearchTextChanged() {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        searchResult = nil
        errorMessage = nil

        guard query.count >= 2 else {
            suggestions = []
            return
        }

        suggestTask?.cancel()
        let task = DispatchWorkItem { [weak self] in
            self?.fetchSuggestions(query: query)
        }
        suggestTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
    }

    private func fetchSuggestions(query: String) {
        isSuggesting = true
        service.searchLocations(query: query) { [weak self] result in
            guard let self = self else { return }
            self.isSuggesting = false
            switch result {
            case .success(let results):
                self.suggestions = results
            case .failure:
                self.suggestions = []
            }
        }
    }

    func select(suggestion: LocationSuggestion) {
        searchText = "\(suggestion.name), \(suggestion.country)"
        suggestions = []
        isSearching = true
        errorMessage = nil
        let query = "\(suggestion.lat),\(suggestion.lon)"
        service.fetchWeather(query: query) { [weak self] result in
            guard let self = self else { return }
            self.isSearching = false
            switch result {
            case .success(let response):
                self.searchResult = response
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func search() {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }
        suggestions = []
        isSearching = true
        errorMessage = nil
        searchResult = nil
        service.fetchWeather(query: query) { [weak self] result in
            guard let self = self else { return }
            self.isSearching = false
            switch result {
            case .success(let response):
                self.searchResult = response
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func reset() {
        searchText = ""
        searchResult = nil
        suggestions = []
        errorMessage = nil
        suggestTask?.cancel()
    }
}
