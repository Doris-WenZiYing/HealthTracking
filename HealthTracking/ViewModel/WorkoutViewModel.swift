//
//  WorkoutViewModel.swift
//  HealthTracking
//
//  Created by Doris Wen on 2024/3/28.
//

import CoreLocation
import Foundation
import Combine
import MapKit

class WorkoutViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager = CLLocationManager()
    @Published var routes: [Route] = []
    @Published var isTracking = false
    @Published var currentRoute = Route() // Marked @Published to trigger view updates
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        loadRoutes()
    }
    
    func toggleTracking() {
        if isTracking {
            locationManager.stopUpdatingLocation()
            saveCurrentRoute()
            currentRoute = Route() // Reset current route for a new tracking session
        } else {
            locationManager.startUpdatingLocation()
            currentRoute = Route() // Initialize a new route for tracking
        }
        isTracking.toggle()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, isTracking else { return }
        let newLocation = Location(coordinate: location.coordinate)
        DispatchQueue.main.async {
            self.currentRoute.locations.append(newLocation)
            // Force a redraw by notifying the SwiftUI view of the change.
            self.objectWillChange.send()
        }
    }
    
    func saveCurrentRoute() {
        routes.append(currentRoute)
        saveRoutes()
    }
    
    private func saveRoutes() {
        if let encoded = try? JSONEncoder().encode(routes) {
            UserDefaults.standard.set(encoded, forKey: "SavedRoutes")
        }
    }
    
    private func loadRoutes() {
        if let savedRoutes = UserDefaults.standard.data(forKey: "SavedRoutes"),
           let decodedRoutes = try? JSONDecoder().decode([Route].self, from: savedRoutes) {
            routes = decodedRoutes
        }
    }
}

