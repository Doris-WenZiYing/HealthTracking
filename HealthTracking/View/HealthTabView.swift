//
//  HealthTabView.swift
//  HealthTracking
//
//  Created by Doris Wen on 2024/1/12.
//

import SwiftUI

struct HealthTabView: View {

    @State var selectedTab = "Home"
    @EnvironmentObject var manager: HealthManager
    var viewModel: WorkoutViewModel

    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tag("Content")
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .environmentObject(manager)

            ChartsView()
                .tag("Charts")
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Charts")
                }
//            RouteTrackingView(viewModel: viewModel)
            RouteTrackingView(locationManager: LocationManager())
                .tag("Routes")
                .tabItem {
                    Image(systemName: "map")
                    Text("Routes")
                }
        }
    }
}

#Preview {
    HealthTabView(viewModel: WorkoutViewModel())
        .environmentObject(HealthManager())
}
