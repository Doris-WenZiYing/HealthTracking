//
//  ChartButton.swift
//  HealthTracking
//
//  Created by Doris Wen on 2024/1/17.
//

import SwiftUI

struct ChartButton: View {
    let title: String
    @Binding var selectedChart: ChartOptions
    var chartOption: ChartOptions

    var body: some View {
        Button(title) {
            withAnimation {
                selectedChart = chartOption
            }
        }
        .padding(.all)
        .foregroundColor(selectedChart == chartOption ? .white : .green)
        .background(selectedChart == chartOption ? .green : .clear)
        .cornerRadius(10)
    }
}

//#Preview {
//    ChartButton()
//}
