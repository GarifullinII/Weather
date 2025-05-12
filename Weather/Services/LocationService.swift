//
//  LocationService.swift
//  Weather
//
//  Created by Ildar Garifullin on 12.05.2025.
//

import CoreLocation

class LocationService: NSObject {
    private let locationManager = CLLocationManager()
    private var completion: ((CLLocationCoordinate2D?) -> Void)?
    private var shouldStartUpdating = false
    
    func getCurrentLocation(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        self.completion = completion
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            shouldStartUpdating = true
            locationManager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse, .authorizedAlways:
            shouldStartUpdating = true
            locationManagerDidChangeAuthorization(locationManager)
            
        default:
            completion(nil)
            self.completion = nil
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        manager.stopUpdatingLocation()
        completion?(location.coordinate)
        completion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        completion?(nil)
        completion = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if shouldStartUpdating,
           status == .authorizedWhenInUse || status == .authorizedAlways {
            shouldStartUpdating = false
            manager.startUpdatingLocation()
        } else if status == .denied || status == .restricted {
            completion?(nil)
            completion = nil
        }
    }
}
