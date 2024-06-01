//
//  LocationProvider.swift
//  Nearby
//
//  Created by Ashutosh Roy on 01/06/24.
//

import CoreLocation
import Combine

protocol LocationProvider {
    func checkAuthorizationAndRequestLocation()
    var location: LocationModel? { get }
    var locationPublisher: AnyPublisher<LocationModel?, Never> { get }
}

class LocationProviderImpl: NSObject, ObservableObject, CLLocationManagerDelegate, LocationProvider {
    let locationManager = CLLocationManager()

    @Published var location: LocationModel?

    var locationPublisher: AnyPublisher<LocationModel?, Never> {
        return $location.removeDuplicates { old, new in
            old?.latitude == new?.latitude && old?.longitude == new?.longitude
        }.eraseToAnyPublisher()
    }

    override init() {
        super.init()
    }

    func checkAuthorizationAndRequestLocation() {
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location available")
            locationManager.requestLocation()
        case .notDetermined:
            requestLocation()
        case .denied, .restricted:
            print("Location services are disabled")
        @unknown default:
            print("Unknown authorization status")
        }
    }
    
    private func requestLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.first?.coordinate {
            location = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
}
