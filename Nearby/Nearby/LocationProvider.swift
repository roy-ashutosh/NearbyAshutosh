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
    var locationPublisher: AnyPublisher<LocationModel, Error> { get }
}

class LocationProviderImpl: NSObject, ObservableObject, CLLocationManagerDelegate, LocationProvider {
    
    let locationManager = CLLocationManager()
    
    private var subject: PassthroughSubject<LocationModel, Error> = .init()
    
    var locationPublisher: AnyPublisher<LocationModel, Error> {
        subject.eraseToAnyPublisher()
    }
    
    func checkAuthorizationAndRequestLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = self
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestLocation()
        case .denied, .restricted:
            print("Location services are disabled")
        @unknown default:
            print("Unknown authorization status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            subject.send(.init(latitude: coordinate.latitude, longitude: coordinate.longitude))
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            manager.startUpdatingLocation()
        default:
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
