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
        item.manager.remainingTime
    }

    func progress(at date: Date) -> Double {
        let totalSeconds = max(1.0, Double(item.manager.totalTime.components.seconds))

        switch item.manager.status {
        case .running:
            // Continuous progress while running.
            if let endDate = item.manager.endDate {
                let remaining = max(0.0, endDate.timeIntervalSince(date))
                return remaining / totalSeconds
            } else {
                // Fallback if endDate is missing.
                let remaining = max(0.0, Double(item.manager.remainingTime.components.seconds))
                return remaining / totalSeconds
            }

        case .paused, .idle:
            // Stable progress when paused/idle.
            let remaining = max(0.0, Double(item.manager.remainingTime.components.seconds))
            return remaining / totalSeconds
        }
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

    func cancel() {
        item.manager.cancel()
    }

    func primaryAction() {
        switch item.manager.status {
        case .running:
            item.manager.pause()

        case .paused:
            item.manager.resume()

        case .idle:
            // Important: route through the Store so the timer is activated and tracked correctly.
            onStartRequested(item)
        }
    }
}
