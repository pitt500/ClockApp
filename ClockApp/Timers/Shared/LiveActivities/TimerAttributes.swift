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
        var label: String
    }

    var title: String
}

enum TimerStatus: String, Codable, Hashable {
    case idle
    case running
    case paused
}
