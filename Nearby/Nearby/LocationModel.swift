//
//  LocationModel.swift
//  Nearby
//
//  Created by Ashutosh Roy on 01/06/24.
//

public struct LocationModel {
    public var latitude: Double
    public var longitude: Double
}

public struct Venue: Identifiable {
    public var id: Int
    public var name: String?
    public var address: String?
}
