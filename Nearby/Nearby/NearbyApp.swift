//
//  NearbyApp.swift
//  Nearby
//
//  Created by Ashutosh Roy on 01/06/24.
//

import SwiftUI

@main
struct NearbyApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel(locationProvider: LocationProviderImpl(), venueService: VenueServiceImpl()))
        }
    }
}
