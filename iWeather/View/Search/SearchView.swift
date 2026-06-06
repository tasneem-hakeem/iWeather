//
//  SearchView.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//

import SwiftUI

struct SearchView: View {

    @ObservedObject var locationStore: LocationStore
    @StateObject private var vm = SearchViewModel()

    @State private var selectedLocation: SavedLocation?
    @State private var navigateToDetail = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 0) {

                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)

                        TextField("Search city...", text: $vm.searchText,
                                  onCommit: { vm.search() })
                            .autocapitalization(.words)
                            .disableAutocorrection(true)

                        if !vm.searchText.isEmpty {
                            Button(action: { vm.reset() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    if vm.isSearching {
                        ProgressView("Searching...")
                            .padding()
                    } else if let result = vm.searchResult {
                        SearchResultCard(
                            response: result,
                            onAdd: {
                                let loc = SavedLocation(
                                    name: result.location.name + ", " + result.location.country,
                                    query: "\(result.location.lat),\(result.location.lon)"
                                )
                                locationStore.add(loc)
                                vm.reset()
                            }
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    } else if let err = vm.errorMessage {
                        Text(err)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                    }


                    List {
                        if !locationStore.savedLocations.isEmpty {
                            Section(header: Text("Saved Locations")) {
                                ForEach(locationStore.savedLocations) { loc in
                                    NavigationLink(
                                        destination: WeatherDetailView(
                                            query: loc.query,
                                            title: loc.name
                                        )
                                    ) {
                                        HStack {
                                            Image(systemName: "location.fill")
                                                .foregroundColor(.accentColor)
                                            Text(loc.name)
                                        }
                                    }
                                }
                                .onDelete { offsets in
                                    locationStore.remove(at: offsets)
                                }
                            }
                        } else {
                            Text("No saved locations yet.\nSearch for a city and tap Add.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Locations")
        }
    }
}

struct SearchResultCard: View {
    let response: WeatherResponse
    let onAdd: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(response.location.name), \(response.location.country)")
                    .font(.headline)
                Text(response.current.condition.text)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(Int(response.current.tempC.rounded()))°C")
                    .font(.title)
                    .fontWeight(.bold)
            }
            Spacer()
            Button(action: onAdd) {
                Label("Add", systemImage: "plus.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
    }
}


struct WeatherDetailView: View {
    let query: String
    let title: String

    @StateObject private var vm = WeatherViewModel()

    var body: some View {
        ZStack {
            WeatherBackground()

            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else if let _ = vm.weatherResponse {
                MainWeatherContent(vm: vm)
            } else if let err = vm.errorMessage {
                Text(err)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .navigationBarTitle(title, displayMode: .inline)
        .onAppear { vm.fetch(query: query) }
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(locationStore: LocationStore())
    }
}
