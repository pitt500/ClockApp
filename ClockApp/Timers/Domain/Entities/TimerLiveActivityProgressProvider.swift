//
//  TimerLiveActivityProgressProvider.swift
//  ClockApp
//
//  Created by Pedro Rojas on 06/03/26.
//


import Foundation

struct TimerLiveActivityProgressProvider: TimerProgressProviding {
    let state: TimerAttributes.ContentState

#warning("Fix this")
    func progress(at date: Date) -> Double {
        let total = max(1.0, state.totalTimeInterval)

        let remaining: TimeInterval
        if state.status == .running, let endDate = state.endDate {
            remaining = max(0, endDate.timeIntervalSince(date))
        } else {
            remaining = max(0, state.remainingWhenNotRunning)
        }

        return remaining / total
    }
}
