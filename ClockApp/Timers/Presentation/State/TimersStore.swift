//
//  TimersStore.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//

import SwiftUI

@Observable
final class TimersStore {

    // Temporary picker state before creating a real timer.
    struct Draft: Equatable {
        var hours: Int = 0
        var minutes: Int = 1
        var seconds: Int = 20

        var totalSeconds: Int {
            (hours * 3600) + (minutes * 60) + seconds
        }

        var duration: Duration { .seconds(totalSeconds) }
        var isValid: Bool { totalSeconds > 0 }
    }

    var draft = Draft()
    var timers: [TimerItem] = []

    // Which running timer is highlighted as the focused row.
    var focusedTimerID: UUID?

    var runningTimers: [TimerItem] {
        timers.filter { $0.manager.status != .idle }
    }

    var hasRunningTimers: Bool {
        !runningTimers.isEmpty
    }

    // Determines which timer is shown in the focused section.
    var focusedTimer: TimerItem? {
        if let id = focusedTimerID,
           let match = timers.first(where: { $0.id == id }) {
            return match
        }
        return runningTimers.first
    }

    // Recents accumulates all timers except the currently focused one.
    var recents: [TimerItem] {
        guard let focusedTimer else { return timers }
        return timers.filter { $0.id != focusedTimer.id }
    }

    // MARK: - Actions

    func startFromDraft() {
        guard draft.isValid else { return }

        let duration = draft.duration
        let manager = TimerManager(activityHandler: NoopTimerActivityHandler())

        manager.onDidFinish = { [weak self] in
            self?.handleTimerDidFinish()
        }

        let item = TimerItem(
            label: "Timer",
            configuredDuration: duration,
            manager: manager
        )

        timers.insert(item, at: 0)
        focusedTimerID = item.id

        manager.setTimer(totalTime: duration)
        ensureFocusIsValid()
    }

    func focus(_ item: TimerItem) {
        focusedTimerID = item.id
    }

    // MARK: - Private

    private func handleTimerDidFinish() {
        // Finished timers remain in Recents.
        ensureFocusIsValid()
    }

    private func ensureFocusIsValid() {
        if !hasRunningTimers {
            focusedTimerID = nil
            return
        }

        if let focusedTimer,
           focusedTimer.manager.status == .idle {
            focusedTimerID = runningTimers.first?.id
        }
    }
}
