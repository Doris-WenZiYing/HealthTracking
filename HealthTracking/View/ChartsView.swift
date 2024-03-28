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
    @State var selectedChart: ChartOptions = .oneMonth

    // Define a fixed bar width
    let fixedBarWidth: CGFloat = 20

    var chartWidth: CGFloat {
        // Calculate the chart width based on the number of data points and the fixed bar width
        let spacing: CGFloat = 10 // Spacing between bars, adjust as needed
        let numberOfBars = manager.chartData[selectedChart]?.count ?? 0
        let totalBarWidth = CGFloat(numberOfBars) * (fixedBarWidth + spacing)
        // Ensure that the chart can scroll if the content is wider than the screen
        return max(totalBarWidth, UIScreen.main.bounds.width)
    }

    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    Chart {
                        if let data = manager.chartData[selectedChart] {
                            ForEach(data) { daily in
                                BarMark(
                                    x: .value("Time", daily.date.formattedForChart(option: selectedChart)),
                                    y: .value("Steps", daily.stepCount)
                                )
                            }
                        }
                    }
                    .foregroundStyle(.green)
                    .frame(width: chartWidth, height: 350)
                }
            }

            HStack {
                ChartButton(title: "1D", selectedChart: $selectedChart, chartOption: .oneDay)
                ChartButton(title: "1W", selectedChart: $selectedChart, chartOption: .oneWeek)
                ChartButton(title: "1M", selectedChart: $selectedChart, chartOption: .oneMonth)
                ChartButton(title: "3M", selectedChart: $selectedChart, chartOption: .threeMonth)
                ChartButton(title: "1Y", selectedChart: $selectedChart, chartOption: .oneYear)
            }
        }
        .frame(height: 450)
    }
}

#Preview {
    ChartsView()
        .environmentObject(HealthManager())
}
