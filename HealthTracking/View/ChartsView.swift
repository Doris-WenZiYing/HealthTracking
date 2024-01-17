//
//  ChartsView.swift
//  HealthTracking
//
//  Created by Doris Wen on 2024/1/17.
//

import SwiftUI
import Charts

struct ChartsView: View {

    @EnvironmentObject var manager: HealthManager

    var body: some View {
        VStack {
            Chart {
                ForEach(manager.oneMonthChartData) { daily in
                    BarMark(x: .value(daily.date.formatted(), daily.date, unit: .day), y: .value("Steps", daily.stepCount))
                }
            }
        }
    }
}

#Preview {
    ChartsView()
        .environmentObject(HealthManager())
}
