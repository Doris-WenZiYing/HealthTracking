//
//  ChartDataModel.swift
//  HealthTracking
//
//  Created by Doris Wen on 2024/1/17.
//

import Foundation

struct DailyStepModel: Identifiable {
    let id = UUID()
    let date: Date
    let stepCount: Double
}
