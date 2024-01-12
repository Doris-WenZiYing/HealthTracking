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

    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tag("Content")
                .tabItem {
                    Image(systemName: "house")
                }
                .environmentObject(manager)

            RootView()
                .tag("Root")
                .tabItem {
                    Image(systemName: "person")
                }
        }
    }
}

#Preview {
    HealthTabView()
}
