//
//  SearchView.swift
//  iWeather
//
//  Created by Tasneem Hakeem on 06/06/2026.
//
import SwiftUI

struct SearchView: View {

    @ObservedObject var locationStore: LocationStore
    @StateObject private var searchVM = SearchViewModel()
    @StateObject private var locationsVM = SavedLocationsViewModel()

    @State private var showDeleteAlert = false
    @State private var offsetsToDelete: IndexSet?

    private var textColor: Color { .white }
    private var backgroundColor: Color {
        Color(red: 0.357, green: 0.400, blue: 0.478)
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            VStack(spacing: 0) {
                searchBar
                suggestionsDropdown
                searchStateSection
                savedLocationsList
            }
        }
        .navigationTitle("Locations")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            locationsVM.sync(with: locationStore.savedLocations)
            UINavigationBar.appearance().largeTitleTextAttributes = [
                .foregroundColor: UIColor(textColor)
            ]
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: UIColor(textColor)
            ]
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Location"),
                message: Text("Are you sure you want to delete this saved location?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let offsets = offsetsToDelete {
                        locationStore.remove(at: offsets)
                        locationsVM.sync(with: locationStore.savedLocations)
                    }
                    offsetsToDelete = nil
                },
                secondaryButton: .cancel {
                    offsetsToDelete = nil
                }
            )
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(textColor.opacity(0.7))

            TextField("Search city...", text: $searchVM.searchText,
                      onCommit: { searchVM.search() })
                .foregroundColor(textColor)
                .accentColor(textColor)
                .autocapitalization(.words)
                .disableAutocorrection(true)
                .onChange(of: searchVM.searchText) { value in
                    searchVM.onSearchTextChanged()
                }

            if !searchVM.searchText.isEmpty {
                Button(action: { searchVM.reset() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(textColor.opacity(0.7))
                }
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var suggestionsDropdown: some View {
        if !searchVM.suggestions.isEmpty {
            SuggestionsListView(
                suggestions: searchVM.suggestions,
                textColor: textColor,
                onSelect: { suggestion in
                    searchVM.select(suggestion: suggestion)
                }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private var searchStateSection: some View {
        if searchVM.isSearching {
            ProgressView("Searching...")
                .foregroundColor(textColor)
                .padding()
        } else if let result = searchVM.searchResult {
            SearchResultCard(
                response: result,
                textColor: textColor,
                onAdd: {
                    let loc = SavedLocation(
                        name: result.location.name + ", " + result.location.country,
                        query: "\(result.location.lat),\(result.location.lon)"
                    )
                    locationStore.add(loc)
                    locationsVM.sync(with: locationStore.savedLocations)
                    searchVM.reset()
                }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        } else if let err = searchVM.errorMessage {
            Text(err)
                .font(.footnote)
                .foregroundColor(.red)
                .padding(.horizontal, 16)
        }
    }

    private var savedLocationsList: some View {
        Group {
            if locationStore.savedLocations.isEmpty {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "location.slash")
                        .font(.system(size: 40))
                        .foregroundColor(textColor.opacity(0.5))

                    Text("No saved locations yet")
                        .font(.headline)
                        .foregroundColor(.black)

                    Text("Search for a city and tap Add")
                        .font(.footnote)
                        .foregroundColor(textColor.opacity(0.7))
                }

                Spacer()
            } else {
                List {
                    Section(
                        header:
                            Text("Saved Locations")
                            .foregroundColor(textColor.opacity(0.7))
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .tracking(1.2)
                    ) {
                        ForEach(locationStore.savedLocations) { loc in
                            let detailVM = locationsVM.viewModel(for: loc)

                            NavigationLink(
                                destination: WeatherDetailView(
                                    title: loc.name,
                                    vm: detailVM
                                )
                            ) {
                                SavedLocationCard(
                                    vm: detailVM,
                                    locationName: loc.name
                                )
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(
                                EdgeInsets(
                                    top: 6,
                                    leading: 16,
                                    bottom: 6,
                                    trailing: 16
                                )
                            )
                        }
                        .onDelete { offsets in
                            offsetsToDelete = offsets
                            showDeleteAlert = true
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
                .onAppear {
                    UITableView.appearance().backgroundColor = .clear
                    UITableViewCell.appearance().backgroundColor = .clear
                }
            }
        }
    }
}

struct SuggestionsListView: View {
    let suggestions: [LocationSuggestion]
    let textColor: Color
    let onSelect: (LocationSuggestion) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(suggestions) { suggestion in
                Button(action: { onSelect(suggestion) }) {
                    HStack(spacing: 10) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(textColor.opacity(0.6))
                            .font(.system(size: 16))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(suggestion.name)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(textColor)
                            Text("\(suggestion.region.isEmpty ? "" : suggestion.region + ", ")\(suggestion.country)")
                                .font(.system(size: 12))
                                .foregroundColor(textColor.opacity(0.65))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }
                .buttonStyle(PlainButtonStyle())

                if suggestion.id != suggestions.last?.id {
                    Divider()
                        .background(textColor.opacity(0.2))
                        .padding(.horizontal, 14)
                }
            }
        }
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }
}

struct SearchResultCard: View {
    let response: WeatherResponse
    let textColor: Color
    let onAdd: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(response.location.name), \(response.location.country)")
                    .font(.headline)
                    .foregroundColor(textColor)
                Text(response.current.condition.text)
                    .font(.subheadline)
                    .foregroundColor(textColor.opacity(0.7))
                Text("\(Int(response.current.tempC.rounded()))°C")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(textColor)
            }
            Spacer()
            Button(action: onAdd) {
                Label("Add", systemImage: "plus.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(textColor)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(14)
    }
}

struct WeatherDetailView: View {

    let title: String
    @ObservedObject var vm: WeatherViewModel

    var body: some View {
        ZStack {
            WeatherBackground(timeOfDay: vm.timeOfDay)

            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            } else if vm.weatherResponse != nil {
                MainWeatherContent(vm: vm)
            } else if let err = vm.errorMessage {
                Text(err)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .navigationBarTitle(title, displayMode: .inline)
    }
}

struct SavedLocationCard: View {
    @ObservedObject var vm: WeatherViewModel
    let locationName: String

    private var cardTimeOfDay: TimeOfDay { vm.timeOfDay }

    private var gradientColors: [Color] {
        switch cardTimeOfDay {
        case .morning:
            return [
                Color(red: 0.96, green: 0.45, blue: 0.33),
                Color(red: 0.98, green: 0.65, blue: 0.30)
            ]
        case .evening:
            return [
                Color(red: 0.10, green: 0.12, blue: 0.32),
                Color(red: 0.18, green: 0.22, blue: 0.50)
            ]
        }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {

            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(18)

            Circle()
                .fill(Color.white.opacity(cardTimeOfDay == .morning ? 0.18 : 0.07))
                .frame(width: 90, height: 90)
                .offset(x: 230, y: -30)

            HStack(alignment: .center, spacing: 12) {

                VStack(alignment: .leading, spacing: 6) {
                    Text(locationName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    if vm.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text(vm.conditionText)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(1)

                        HStack(spacing: 4) {
                            Image(systemName: "thermometer.medium")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.75))
                            Text("Feels like \(vm.feelsLike)")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                }

                Spacer()

                if !vm.conditionIcon.isEmpty {
                    WeatherIcon(urlString: vm.conditionIcon, size: 52)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
        }
        .frame(height: 90)
        .buttonStyle(PlainButtonStyle())
    }
}
