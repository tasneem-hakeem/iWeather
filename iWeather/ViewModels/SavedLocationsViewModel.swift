//
//  SavedLocationsViewModel.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 10/06/2026.
//

import Foundation

final class SavedLocationsViewModel: ObservableObject {

    private(set) var viewModels: [UUID: WeatherViewModel] = [:]

    
    func sync(with locations: [SavedLocation]) {
        let currentIDs = Set(locations.map(\.id))

        for id in viewModels.keys where !currentIDs.contains(id) {
            viewModels.removeValue(forKey: id)
        }

        for loc in locations where viewModels[loc.id] == nil {
            viewModels[loc.id] = WeatherViewModel(query: loc.query)
        }
    }

    func viewModel(for location: SavedLocation) -> WeatherViewModel {
        if let existing = viewModels[location.id] { return existing }
        let vm = WeatherViewModel(query: location.query)
        viewModels[location.id] = vm
        return vm
    }
}
