//
//  Date+Extensions.swift
//  HealthTracking
//
//  Created by Doris Wen on 2024/1/17.
//

import Foundation
import HealthKit

enum UnitType {
    case distance
    case time
    case count
    case energy
}

enum ChartOptions: CaseIterable {
    case oneDay
    case oneWeek
    case oneMonth
    case threeMonth
    case oneYear
}

extension Date {

    // This remains unchanged
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }

    // Adjust to get the start of the current week, not the previous week
    static var startOfWeek: Date {
        let calendar = Calendar.current
        var component = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        component.weekday = 2 // Assuming week starts on Monday
        return calendar.date(from: component) ?? Date()
    }

    // Adjust to get the start of the current month, not one month ago
    static var startOfMonth: Date {
        let calendar = Calendar.current
        let component = calendar.dateComponents([.year, .month], from: Date())
        return calendar.date(from: component) ?? Date()
    }

    // Adjust to get the start of the current year, not one year ago
    static var startOfYear: Date {
        let calendar = Calendar.current
        let component = calendar.dateComponents([.year], from: Date())
        return calendar.date(from: component) ?? Date()
    }

    static var oneDayAgo: Date {
        Calendar.current.date(byAdding: .hour, value: -24, to: Date())!
    }

    static var oneWeekAgo: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
    }

    static var oneMonthAgo: Date {
        Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    }

    static var threeMonthsAgo: Date {
        Calendar.current.date(byAdding: .month, value: -3, to: Date())!
    }

    static var oneYearAgo: Date {
        Calendar.current.date(byAdding: .year, value: -1, to: Date())!
    }

    func formattedForChart(option: ChartOptions) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent formatting
        switch option {
        case .oneDay:
            formatter.dateFormat = "ha" // e.g., "12AM", "6AM", "12PM", "6PM"
        case .oneWeek:
            formatter.dateFormat = "EEE" // e.g., "Sun", "Mon", "Tue"
        case .threeMonth:
            formatter.dateFormat = "MMM" // e.g., "Jan", "Feb", "Mar"
        case .oneYear:
            formatter.dateFormat = "MMM"
            let formattedDate = formatter.string(from: self)
            return String(formattedDate.prefix(1)) // e.g., "J", "F", "M"
        default:
            formatter.dateFormat = "dd" // Default format for other options
        }
        return formatter.string(from: self)
    }
}

extension Double {
    func formattedString(for unitType: UnitType) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal

        switch unitType {
        case .distance:
            // Convert to kilometers if the distance is more than 1000 meters
            let value = self >= 1000 ? self / 1000 : self
            numberFormatter.maximumFractionDigits = self >= 1000 ? 2 : 0
            return self >= 1000 ? "\(numberFormatter.string(from: NSNumber(value: value))!) km" : "\(numberFormatter.string(from: NSNumber(value: value))!) m"
        case .time:
            // Convert to hours if more than 60 minutes
            let value = self >= 60 ? self / 60 : self
            return self >= 60 ? "\(numberFormatter.string(from: NSNumber(value: value))!) hr" : "\(numberFormatter.string(from: NSNumber(value: value))!) min"
        case .count:
            return "\(numberFormatter.string(from: NSNumber(value: self))!)"
        case .energy:
            numberFormatter.maximumFractionDigits = 1
            return "\(numberFormatter.string(from: NSNumber(value: self))!) kcal"
        }
    }
}

extension HKQuantityTypeIdentifier {
    var unitString: String {
        switch self {
        case .stepCount:
            return HKUnit.count().unitString
        case .activeEnergyBurned:
            return HKUnit.kilocalorie().unitString
        case .distanceWalkingRunning:
            return HKUnit.meter().unitString
        default:
            return ""
        }
    }
}

extension HealthManager {

    func fetchChartData(for option: ChartOptions) {
        // Define the start and end dates for each chart option
        let startDate: Date
        let endDate: Date = Date()
        let interval: DateComponents

        switch option {
        case .oneDay:
            startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)!
            interval = DateComponents(hour: 1) // Change to hour for a 1D chart
        case .oneWeek:
            startDate = Calendar.current.date(byAdding: .weekday, value: -7, to: endDate)!
            interval = DateComponents(day: 1) // Change to day for a 1W chart
        case .oneMonth:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)!
            interval = DateComponents(day: 1) // Same daily interval for 1M
        case .threeMonth:
            startDate = Calendar.current.date(byAdding: .month, value: -3, to: endDate)!
            interval = DateComponents(weekOfYear: 1) // Change to week for a 3M chart
        case .oneYear:
            startDate = Calendar.current.date(byAdding: .year, value: -1, to: endDate)!
            interval = DateComponents(month: 1) // Change to month for a 1Y chart
        }

        // Fetch the steps using the appropriate interval
        fetchDailySteps(startDate: startDate, endDate: endDate, interval: interval) { dailySteps in
            DispatchQueue.main.async {
                self.chartData[option] = dailySteps
            }
        }
    }
}
