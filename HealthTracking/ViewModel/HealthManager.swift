//
//  HealthManager.swift
//  HealthTracking
//
//  Created by Doris Wen on 2024/1/12.
//

import Foundation
import HealthKit

class HealthManager: ObservableObject {

    // Access the user data
    let healthStore = HKHealthStore()

    @Published var activities: [String: ActivityModel] = [:]
    @Published var mockActivities: [String: ActivityModel] = [
        "todaySteps" : ActivityModel(id: 0, title: "Today's Steps", subTitle: "Goal: 10,000", image: "figure.walk", amount: "12,123"),
        "todayCalorie" : ActivityModel(id: 1, title: "Today's Calories", subTitle: "Goal: 1,000", image: "flame", amount: "1,241")
    ]

    init() {
        // HealthKit instance of step count
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        // users all workout
        let workout = HKObjectType.workoutType()
        let healthTypes: Set = [steps, calories, workout]

        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchTodaySteps()
                fetchTodayCalories()
            } catch {
                print("error fetching health data")
            }
        }
    }

    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        // Specify fetch data time
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: .now)
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error fetching todays step data")
                return
            }

            let stepCount = quantity.doubleValue(for: .count())
            let todayWalk = ActivityModel(id: 0, title: "Today's Steps", subTitle: "Goal: 10,000", image: "figure.walk", amount: stepCount.formattedString())

            DispatchQueue.main.async {
                self.activities["todaySteps"] = todayWalk
            }
            print(stepCount.formattedString())
        }

        healthStore.execute(query)
    }

    func fetchTodayCalories() {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error fetching todays calorie data")
                return
            }

            let calorieBurned = quantity.doubleValue(for: .kilocalorie())
            let todayCalories = ActivityModel(id: 1, title: "Today's Calories", subTitle: "Goal: 1,000", image: "flame", amount: calorieBurned.formattedString())

            DispatchQueue.main.async {
                self.activities["todayCalories"] = todayCalories
            }
            print(calorieBurned.formattedString())
        }

        healthStore.execute(query)
    }
}


extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

extension Double {
    func formattedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0

        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
