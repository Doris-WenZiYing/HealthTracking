//
//  LocationManager.swift
//  HealthTracking
//
//  Created by Doris Wen on 2024/3/29.
//

import Foundation
import Combine
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var locations: [CLLocation] = []

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 0.01 // Notify for changes every 10 meters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Check for a significant change
        if let last = self.locations.last, last.distance(from: location) < 0.1 {
            // If the change is less than 10 meters, don't append and print the new location.
            return
        }

        self.userLocation = location
        self.locations.append(location)

        // Print the updated location
        print("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
}

