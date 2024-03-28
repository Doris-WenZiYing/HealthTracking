//
//  WorkoutModel.swift
//  HealthTracking
//
//  Created by Doris Wen on 2024/3/28.
//

import Foundation
import CoreLocation

struct Location: Codable, Identifiable {
    let id: UUID
    let latitude: Double
    let longitude: Double

    init(coordinate: CLLocationCoordinate2D) {
        self.id = UUID()
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

struct Route: Codable, Identifiable {
    let id: UUID
    var locations: [Location]

    init(locations: [Location] = []) {
        self.id = UUID()
        self.locations = locations
    }
}
