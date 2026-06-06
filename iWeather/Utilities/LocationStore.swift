//
//  LocationStore.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import Foundation

final class LocationStore: ObservableObject {

    @Published private(set) var savedLocations: [SavedLocation] = []

    private let key = "saved_locations"

    init() {
        load()
    }

    func add(_ location: SavedLocation) {
        guard !savedLocations.contains(where: { $0.query == location.query }) else { return }
        savedLocations.append(location)
        save()
    }

    func remove(at offsets: IndexSet) {
        savedLocations.remove(atOffsets: offsets)
        save()
    }

    func remove(id: UUID) {
        savedLocations.removeAll { $0.id == id }
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(savedLocations) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let locations = try? JSONDecoder().decode([SavedLocation].self, from: data) else {
            return
        }
        savedLocations = locations
    }
}
