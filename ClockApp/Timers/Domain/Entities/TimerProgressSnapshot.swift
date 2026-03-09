//
//  TimerProgressSnapshot.swift
//  ClockApp
//
//  Created by Pedro Rojas on 07/03/26.
//


import Foundation

struct TimerProgressSnapshot: Sendable {
    let totalTimeInterval: TimeInterval
    let endDate: Date?
    let remainingWhenNotRunning: TimeInterval

    func remainingInterval(at date: Date) -> TimeInterval {
        if let endDate {
            return max(0, endDate.timeIntervalSince(date))
        }

        return max(0, remainingWhenNotRunning)
    }

    func progress(at date: Date) -> Double {
        let total = max(1.0, totalTimeInterval)
        
        let progress = remainingInterval(at: date) / total
        return progress
    }
}
