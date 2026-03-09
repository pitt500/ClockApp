//
//  TimerRowProgressProviderFromManager.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/02/26.
//


import Foundation

final class TimerRowProgressProviderFromManager: TimerProgressProviding {
    private let item: TimerItem

    init(item: TimerItem) {
        self.item = item
    }

    func progress(at date: Date) -> Double {
        snapshot(at: date).progress(at: date)
    }

    private func snapshot(at date: Date) -> TimerProgressSnapshot {
        let manager = item.manager
        let remaining = manager.remainingInterval(at: date)

        return TimerProgressSnapshot(
            totalTimeInterval: manager.totalTimeInterval,
            endDate: manager.status == .running ? date.addingTimeInterval(remaining) : nil,
            remainingWhenNotRunning: manager.status == .running ? 0 : remaining
        )
    }
}
