//
//  ContentView.swift
//  Nearby
//
//  Created by Ashutosh Roy on 01/06/24.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            ForEach(viewModel.venues) { venue in
                HStack{
                    Image(systemName: "photo")
                        .frame(width: 25, height: 25)
                    VStack(alignment: .leading) {
                        Text(venue.name ?? "")
                            .bold()
                        Text(venue.address ?? "")
                    }
                }
            }
        }
        .task {
            await viewModel.prepare()
        }
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(
            locationProvider: LocationProviderImpl(), venueService: VenueServiceImpl()
        )
    )
}
