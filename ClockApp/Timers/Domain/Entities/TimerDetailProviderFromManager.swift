//
//  TimerDetailProviderFromManager.swift
//  ClockApp
//
//  Created by Pedro Rojas on 01/02/26.
//


import SwiftUI

@Observable
final class TimerDetailProviderFromManager: TimerDetailProviding {
    private let item: TimerItem

    // Use this to route "Start" through the Store, so the timer is moved into activeTimers.
    private let onStartRequested: (TimerItem) -> Void

    init(
        item: TimerItem,
        onStartRequested: @escaping (TimerItem) -> Void
    ) {
        self.item = item
        self.onStartRequested = onStartRequested
    }

    // MARK: - TimerDetailProviding

    var configuredDuration: Duration {
        item.configuredDuration
    }

    var remainingDuration: Duration {
        item.manager.remainingTimeInSeconds
    }

    func progress(at date: Date) -> Double {
        let total = max(1.0, item.manager.totalTimeInterval)
        let remaining = item.manager.remainingInterval(at: date)
        return remaining / total
    }

    var actionTitle: String {
        switch item.manager.status {
        case .running: return "Pause"
        case .paused: return "Resume"
        case .idle: return "Start"
        }
    }

    var actionTint: Color {
        item.manager.status == .paused ? .green : .orange
    }

    func primaryAction() {
        switch item.manager.status {
        case .running:
            item.manager.pause()
        case .paused:
            item.manager.resume()
        case .idle:
            onStartRequested(item)
        }
    }
}
