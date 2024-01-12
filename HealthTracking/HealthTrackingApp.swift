//
//  HealthTrackingApp.swift
//  HealthTracking
//
//  Created by Doris Wen on 2024/1/12.
//

import SwiftUI

@main
struct HealthTrackingApp: App {

    @StateObject var manager = HealthManager()

    var body: some Scene {
        WindowGroup {
            HealthTabView()
                .environmentObject(manager)
        }
    }
}
