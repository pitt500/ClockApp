//
//  TimerLiveActivityProgressProvider.swift
//  ClockApp
//
//  Created by Pedro Rojas on 06/03/26.
//


import Foundation

struct TimerLiveActivityProgressProvider: TimerProgressProviding {
    let state: TimerAttributes.ContentState

    func progress(at date: Date) -> Double {
        snapshot.progress(at: date)
    }

    var snapshot: TimerProgressSnapshot {
        TimerProgressSnapshot(
            totalTimeInterval: state.totalTimeInterval,
            endDate: state.endDate,
            remainingWhenNotRunning: state.remainingWhenNotRunning
        )
    }
}
