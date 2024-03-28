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
    @StateObject var workoutViewModel = WorkoutViewModel()

    var body: some Scene {
        WindowGroup {
            HealthTabView(viewModel: workoutViewModel)
                .environmentObject(manager)
        }
    }
}
