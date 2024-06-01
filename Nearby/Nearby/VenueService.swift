//
//  File.swift
//  Nearby
//
//  Created by Ashutosh Roy on 01/06/24.
//

import Foundation

protocol VenueService {
    func fetchVenues(latitude: Double, longitude: Double) async throws ->  [VenueNetworkModel]
}

struct VenueServiceImpl: VenueService {

    enum ServiceError: Error {
        case invalidURL
        case networkError(Error)
        case invalidResponse
        case decodingError(Error)
    }

    func fetchVenues(latitude: Double, longitude: Double) async throws ->  [VenueNetworkModel] {
        let perPage = 10
        let pageNumber = 1
        let clientId = "Mzg0OTc0Njl8MTcwMDgxMTg5NC44MDk2NjY5"
        
        guard let url = URL(string: "https://api.seatgeek.com/2/venues?client_id=\(clientId)&per_page=\(perPage)&page=\(pageNumber)&lat=\(latitude)&lon=\(longitude)") else {
            throw ServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ServiceError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let venues = try decoder.decode(Resp.self, from: data).venues
            return venues
        } catch {
            throw ServiceError.decodingError(error)
        }
    }
}

struct Resp: Codable {
    var venues: [VenueNetworkModel]
}

struct VenueNetworkModel: Codable {
    public var id: Int
    public var name: String?
    public var address: String?
    public var city: String?
}
