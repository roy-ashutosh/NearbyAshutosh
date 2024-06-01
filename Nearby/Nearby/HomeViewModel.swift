//
//  File.swift
//  Nearby
//
//  Created by Ashutosh Roy on 01/06/24.
//

import Combine

@MainActor
public final class HomeViewModel: ObservableObject {
    
    @Published var location: LocationModel?
    @Published var venues = [Venue]()
    
    let locationProvider: LocationProvider
    let venueService: VenueService
    private var subscriptions = Set<AnyCancellable>()
    
    
    init(locationProvider: LocationProvider, venueService: VenueService) {
        self.locationProvider = locationProvider
        self.venueService = venueService
    }
    
    func prepare() async {
        locationProvider.checkAuthorizationAndRequestLocation()
        subscribeToLocation()
    }
    
    private func subscribeToLocation() {
        locationProvider.locationPublisher.sink { loc in
            guard let loc else { return }
            self.location = loc
            await self.fetchVenues()
        }
        .store(in: &subscriptions)
    }
    
    private func fetchVenues() async {
        guard let location = location else { return }
        do {
            venues = try await venueService
                .fetchVenues(latitude: location.latitude, longitude: location.longitude)
                .map { .init(id: $0.id, name: $0.name, address: $0.address) }
        } catch {
            print(error)
        }
    }
}
