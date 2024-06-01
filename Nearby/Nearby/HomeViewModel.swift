//
//  File.swift
//  Nearby
//
//  Created by Ashutosh Roy on 01/06/24.
//

import Combine

@MainActor
public final class HomeViewModel: ObservableObject {
    
    @Published var venues = [Venue]()
    
    let locationProvider: LocationProvider
    let venueService: VenueService
    private var subscriptions = Set<AnyCancellable>()
    
    
    init(locationProvider: LocationProvider, venueService: VenueService) {
        self.locationProvider = locationProvider
        self.venueService = venueService
    }
    
    func prepare() async {
        subscribeToLocation()
        locationProvider.checkAuthorizationAndRequestLocation()
    }
    
    private func subscribeToLocation() {
        locationProvider
            .locationPublisher
            .sink { error in
                print(error)
            } receiveValue: { loc in
                Task {
                    await self.fetchVenues(location: loc)
                }
            }
            .store(in: &subscriptions)
    }
    
    private func fetchVenues(location: LocationModel) async {
        do {
            venues = try await venueService
                .fetchVenues(latitude: location.latitude, longitude: location.longitude)
                .map { .init(id: $0.id, name: $0.name, address: $0.address) }
        } catch {
            print(error)
        }
    }
}
