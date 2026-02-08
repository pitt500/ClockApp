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
        let total = max(1.0, item.manager.totalTimeInterval + item.manager.finishGrace)

        let remaining: TimeInterval
        switch item.manager.status {
        case .running:
            if let endDate = item.manager.endDate {
                remaining = max(0.0, endDate.timeIntervalSince(date))
            } else {
                // Should not happen, but keep it stable.
                remaining = max(0.0, item.manager.remainingInterval)
            }

        case .paused, .idle:
            // Stable ring while paused/idle.
            remaining = max(0.0, item.manager.remainingInterval)
        }

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
