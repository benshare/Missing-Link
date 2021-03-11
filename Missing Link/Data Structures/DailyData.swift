//
//  DailyData.swift
//  Missing Link
//
//  Created by Benjamin Share on 12/5/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation

class DailyData: Codable, Equatable {
    var totalDailies: Int
    var streak: Int
    var lastDayInStreak: String
    var longestStreak: Int
    
    static func == (lhs: DailyData, rhs: DailyData) -> Bool {
        return structComparisonFn(lhs: lhs, rhs: rhs)
    }
    
    init() {
        totalDailies = 0
        streak = 0
        lastDayInStreak = "2020-01-01"
        longestStreak = 0
    }
    
    func updateOnDailyComplete() {
        print("Updating daily")
        totalDailies += 1
        streak += 1
        lastDayInStreak = DATE_FORMATTER.string(from: Date())
        if streak > longestStreak {
            longestStreak = streak
        }
    }

    func updateStreakIfExpired() {
        if streak > 0 {
            if lastDayInStreak != DATE_FORMATTER.string(from: Date()) && lastDayInStreak != DATE_FORMATTER.string(from: Date() - 1) {
                streak = 0
            }
        }
    }
}
