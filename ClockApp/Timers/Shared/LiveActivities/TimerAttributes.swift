//
//  TimerAttributes.swift
//  ClockApp
//
//  Created by Pedro Rojas on 03/03/26.
//


import ActivityKit
import Foundation

struct TimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: TimerStatus
        var totalTimeInterval: TimeInterval
        var endDate: Date?
        var remainingWhenNotRunning: TimeInterval
        var displayedRemainingTime: Duration
    }

    var title: String
}

enum TimerStatus: String, Codable, Hashable {
    case idle
    case running
    case paused
}

extension TimerAttributes.ContentState {
    var runningTimeInterval: ClosedRange<Date>? {
        guard status == .running, let endDate else { return nil }
        let startDate = endDate.addingTimeInterval(-totalTimeInterval)
        return startDate...endDate
    }
}

extension TimerAttributes.ContentState {
    var progressSnapshot: TimerProgressSnapshot {
        TimerProgressSnapshot(
            totalTimeInterval: totalTimeInterval,
            endDate: endDate,
            remainingWhenNotRunning: remainingWhenNotRunning
        )
    }
}
