//
//  RouteTrackingView.swift
//  HealthTracking
//
//  Created by Doris Wen on 2024/2/22.
//

import SwiftUI

struct RouteTrackingView: View {
    @StateObject var locationManager = LocationManager()

    var body: some View {
        NavigationView {
            VStack {
                MapView(locationManager: locationManager)
                    .frame(height: 400)
                    .edgesIgnoringSafeArea(.top)

//                Button(action: {
//                    viewModel.toggleTracking()
//                }) {
//                    Text(viewModel.isTracking ? "Stop Tracking" : "Start Tracking")
//                }
//                .padding()
//                .background(viewModel.isTracking ? Color.red : Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(10)

//                NavigationLink(destination: RouteHistoryView(routes: $viewModel.routes)) {
//                    Text("Route History")
//                }
//                .padding()
            }
            .navigationTitle("Route Tracker")
        }
    }
}
