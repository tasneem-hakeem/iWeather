//
//  SearchViewModel.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import Foundation

final class SearchViewModel: ObservableObject {

    @Published var searchText: String = ""
    @Published var searchResult: WeatherResponse?
    @Published var isSearching: Bool = false
    @Published var errorMessage: String?

    private let service: WeatherServiceProtocol

    init(service: WeatherServiceProtocol = WeatherService()) {
        self.service = service
    }

    func search() {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }

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
        errorMessage = nil
    }
}
