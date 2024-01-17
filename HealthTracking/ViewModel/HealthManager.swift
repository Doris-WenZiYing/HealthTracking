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
    @Published var oneMonthChartData = [DailyStepModel]()
    @Published var mockActivities: [String: ActivityModel] = [
        "todaySteps" : ActivityModel(id: 0, title: "Today's Steps", subTitle: "Goal: 10,000", image: "figure.walk", tintColor: .green, amount: "12,123"),
        "todayCalorie" : ActivityModel(id: 1, title: "Today's Calories", subTitle: "Goal: 1,000", image: "flame", tintColor: .red, amount: "1,241"),
        "running" : ActivityModel(id: 2, title: "Running", subTitle: "This Week", image: "figure.run", tintColor: .blue, amount: "30 minutes"),
        "soccer" : ActivityModel(id: 3, title: "Soccer", subTitle: "This Week", image: "figure.soccer", tintColor: .orange, amount: "10 minutes")
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
                fetchCurrentWeekWorkoutStats()
            } catch {
                print("error fetching health data")
            }
        }
    }

    // MARK: Today's Step
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
            let todayWalk = ActivityModel(id: 0, title: "Today's Steps", subTitle: "Goal: 10,000", image: "figure.walk", tintColor: .green, amount: stepCount.formattedString())

            DispatchQueue.main.async {
                self.activities["todaySteps"] = todayWalk
            }
            print("step count: \(stepCount.formattedString())")
        }
        healthStore.execute(query)
    }

    // MARK: Today's Calories
    func fetchTodayCalories() {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("error fetching todays calorie data")
                return
            }

            let calorieBurned = quantity.doubleValue(for: .kilocalorie())
            let todayCalories = ActivityModel(id: 1, title: "Today's Calories", subTitle: "Goal: 1,000", image: "flame", tintColor: .red, amount: calorieBurned.formattedString())

            DispatchQueue.main.async {
                self.activities["todayCalories"] = todayCalories
            }
            print("calorie burned: \(calorieBurned.formattedString())")
        }
        healthStore.execute(query)
    }

    // MARK: HealthKit Workout Type
    func fetchCurrentWeekWorkoutStats() {
        let workout = HKSampleType.workoutType()
        let timePredicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        let query = HKSampleQuery(sampleType: workout, predicate: timePredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, sample, error in
            guard let workouts = sample as? [HKWorkout], error == nil else {
                print("error fetching week workouts data")
                return
            }

            var runningCount: Int = 0
            var soccerCount: Int = 0
            for workout in workouts {
                if workout.workoutActivityType == .running {
                    let duration = Int(workout.duration)/60
                    runningCount += duration
                } else if workout.workoutActivityType == .soccer {
                    let duration = Int(workout.duration)/60
                    soccerCount += duration
                }
            }

            let running = ActivityModel(id: 2, title: "Running", subTitle: "This Week", image: "figure.run", tintColor: .blue, amount: "\(runningCount) minutes")
            let soccer = ActivityModel(id: 3, title: "Soccer", subTitle: "This Week", image: "figure.soccer", tintColor: .orange, amount: "\(soccerCount) minutes")

            DispatchQueue.main.async {
                self.activities["weekRunning"] = running
                self.activities["weekSoccer"] = soccer
            }
        }
        healthStore.execute(query)
    }
}


extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }

    static var startOfWeek: Date {
        let calendar = Calendar.current
        var component = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        component.weekday = 2

        return calendar.date(from: component)!
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
