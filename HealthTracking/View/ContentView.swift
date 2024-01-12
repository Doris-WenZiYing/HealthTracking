//
//  ContentView.swift
//  HealthTracking
//
//  Created by Doris Wen on 2024/1/12.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var manager: HealthManager

    var body: some View {
        VStack(alignment: .leading) {

            Text("Welcome")
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .padding()

            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                ForEach(manager.mockActivities.sorted(by: { $0.value.id < $1.value.id }), id: \.key) { item in
                    ActivityCardView(activity: item.value)
                }
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthManager())
}
