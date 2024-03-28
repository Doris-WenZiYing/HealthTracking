//
//  HealthManager.swift
//  HealthTracking
//
//  Created by Doris Wen on 2024/1/12.
//

import Foundation
import HealthKit
import MapKit
import CoreLocation

class HealthManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    // Access the user data
    let healthStore = HKHealthStore()

    @Published var activities: [String: ActivityModel] = [:]
    @Published var runningRoutes: [MKPolyline] = []
    @Published var cyclingRoutes: [MKPolyline] = []
    @Published var mockActivities: [String: ActivityModel] = [
        "todaySteps" : ActivityModel(id: 0, title: "Today's Steps", subTitle: "Goal: 10,000", image: "figure.walk", tintColor: .green, amount: "12,123"),
        "todayCalorie" : ActivityModel(id: 1, title: "Today's Calories", subTitle: "Goal: 1,000", image: "flame", tintColor: .red, amount: "1,241"),
        "todayWalkLength" : ActivityModel(id: 2, title: "Walk Length", subTitle: "Daily", image: "figure.walk", tintColor: .green, amount: "1.3 km"),
        "running" : ActivityModel(id: 2, title: "Running", subTitle: "This Week", image: "figure.run", tintColor: .blue, amount: "30 min"),
        "cycling" : ActivityModel(id: 3, title: "cycling", subTitle: "This Week", image: "figure.outdoor.cycle", tintColor: .orange, amount: "1 hr")
    ]
    @Published var chartData: [ChartOptions: [DailyStepModel]] = [:]

    override init() {
        super.init()
        // HealthKit instance
        let healthTypes = Set(
            [
                HKQuantityType(
                    .stepCount
                ),
                HKQuantityType(
                    .activeEnergyBurned
                ),
                HKQuantityType(
                    .distanceWalkingRunning
                ),
                HKObjectType.workoutType(),
                HKSeriesType.workoutRoute()
            ]
        )

        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchData()
            } catch {
                print("error fetching health data")
            }
        }

        @Sendable func fetchData() {
            fetchHealthData(type: .stepCount, identifier: "todaySteps")
            fetchHealthData(type: .activeEnergyBurned, identifier: "todayCalories")
            fetchHealthData(type: .distanceWalkingRunning, identifier: "todayWalkLength")
            fetchCurrentWeekWorkoutStats()

            ChartOptions.allCases.forEach { option in
                fetchChartData(for: option)
            }
        }
    }

    func fetchHealthData(type: HKQuantityTypeIdentifier, identifier: String) {
        let quantityType = HKQuantityType(type)
        let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, error == nil else {
                print("Error fetching \(identifier): \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let totalValue = result.sumQuantity()?.doubleValue(for: HKUnit(from: type.unitString))
            let activityModel = self.createActivityModel(for: identifier, with: totalValue)

            DispatchQueue.main.async {
                self.activities[identifier] = activityModel
            }
        }

        healthStore.execute(query)
    }

    func createActivityModel(for identifier: String, with value: Double?) -> ActivityModel {
        switch identifier {
        case "todaySteps":
            print("Steps: \(value?.formattedString(for: .count) ?? "0")")
            return ActivityModel(id: 0, title: "Today's Steps", subTitle: "Goal: 10,000", image: "figure.walk", tintColor: .green, amount: value?.formattedString(for: .count) ?? "0")
        case "todayCalories":
            print("Calories: \(value?.formattedString(for: .energy) ?? "0")")
            return ActivityModel(id: 1, title: "Today's Calories", subTitle: "Goal: 1,000", image: "flame", tintColor: .red, amount: value?.formattedString(for: .energy) ?? "0")
        case "todayWalkLength":
            print("Length: \(value?.formattedString(for: .distance) ?? "0")")
            return ActivityModel(id: 2, title: "Walk Length", subTitle: "Daily", image: "figure.walk", tintColor: .green, amount: value?.formattedString(for: .distance) ?? "0")
        default:
            print("No identifier or value")
            return ActivityModel(id: -1, title: "", subTitle: "", image: "wrongwaysign", tintColor: .clear, amount: "")
        }
    }

    // MARK: For Chart Today's Step Data
    func fetchDailySteps(startDate: Date, endDate: Date = Date(), interval: DateComponents, completion: @escaping ([DailyStepModel]) -> Void) {
        let steps = HKQuantityType(.stepCount)

        // Use a predicate to fetch samples between the start and end date
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(quantityType: steps, quantitySamplePredicate: predicate, anchorDate: startDate, intervalComponents: interval)

        query.initialResultsHandler = { _, result, error in
            guard let result = result else {
                completion([])
                return
            }

            var dailySteps = [DailyStepModel]()

            // Enumerate the statistics from the start date to the end date
            result.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                let stepCount = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0.00
                dailySteps.append(DailyStepModel(date: statistics.startDate, stepCount: stepCount))
            }

            // Sorting the results by date may be necessary if they're not already in order
            let sortedSteps = dailySteps.sorted { $0.date < $1.date }
            completion(sortedSteps)
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
            let todayCalories = ActivityModel(id: 1, title: "Today's Calories", subTitle: "Goal: 1,000", image: "flame", tintColor: .red, amount: calorieBurned.formattedString(for: .energy))

            DispatchQueue.main.async {
                self.activities["todayCalories"] = todayCalories
            }
            print("calorie burned: \(calorieBurned.formattedString(for: .energy))")
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

            var runningDuration: Int = 0
            var cyclingDuration: Int = 0

            for workout in workouts {
                if workout.workoutActivityType == .running {
                    let duration = Int(workout.duration)/60
                    runningDuration += duration
                } else if workout.workoutActivityType == .cycling {
                    let duration = Int(workout.duration)/60
                    cyclingDuration += duration
                }
            }

            let running = ActivityModel(id: 3, title: "Running", subTitle: "This Week", image: "figure.run", tintColor: .blue, amount: "\(runningDuration) min")
            let cycling = ActivityModel(id: 4, title: "cycling", subTitle: "This Week", image: "figure.outdoor.cycle", tintColor: .orange, amount: "\(cyclingDuration) min")

            DispatchQueue.main.async {
                self.activities["weekRunning"] = running
                self.activities["weekcycling"] = cycling
            }
        }
        healthStore.execute(query)
    }

    // MARK: Workout Route
    func fetchRouteData(for workout: HKWorkout) {
        let routeType = HKSeriesType.workoutRoute()
        let predicate = HKQuery.predicateForObjects(from: workout)

        let query = HKSampleQuery(sampleType: routeType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, routeSamples, error in
            guard let routes = routeSamples as? [HKWorkoutRoute], error == nil else {
                print("Error fetching routes: \(String(describing: error))")
                return
            }

            routes.forEach { self.processRoute($0) }
        }

        healthStore.execute(query)
    }

    func processRoute(_ route: HKWorkoutRoute) {
        let routeQuery = HKWorkoutRouteQuery(route: route) { (query, locationsOrNil, done, errorOrNil) in
            guard let locations = locationsOrNil, errorOrNil == nil else {
                print("Error fetching route data: \(String(describing: errorOrNil))")
                return
            }

            // Convert locations to coordinates and create a polyline
            let coordinates = locations.map { $0.coordinate }
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)

            DispatchQueue.main.async {
                // Add the polyline to your map view's overlays
                self.runningRoutes.append(polyline) // Adjust based on your app's logic
            }
        }

        healthStore.execute(routeQuery)
    }
}
