//
//  TimersStore.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//

import SwiftUI

@Observable
final class TimersStore {

    // Temporary selection state from the picker.
    // It becomes a real timer only when the user taps Start.
    struct Draft: Equatable {
        var hours: Int = 0
        var minutes: Int = 15
        var seconds: Int = 20

        var totalSeconds: Int {
            (hours * 3600) + (minutes * 60) + seconds
        }

        var duration: Duration { .seconds(totalSeconds) }
        var isValid: Bool { totalSeconds > 0 }
    }

    var draft = Draft()
    var timers: [TimerItem] = []

    // Controls which timer is shown in the large "hero" header.
    var focusedTimerID: UUID?

    var runningTimers: [TimerItem] {
        timers.filter { $0.manager.status != .idle }
    }

    var hasRunningTimers: Bool { !runningTimers.isEmpty }

    var focusedTimer: TimerItem? {
        if let id = focusedTimerID, let match = timers.first(where: { $0.id == id }) {
            return match
        }
        return runningTimers.first
    }

    func startFromDraft() {
        guard draft.isValid else { return }

        let manager = TimerManager(activityHandler: NoopTimerActivityHandler())

        // Keep it simple for Chapter 1: use a closure event.
        // The store decides what to do when a timer finishes.
        manager.onDidFinish = { [weak self] in
            self?.handleTimerDidFinish()
        }

        let item = TimerItem(label: "Timer", manager: manager)
        timers.insert(item, at: 0)
        focusedTimerID = item.id

        manager.setTimer(totalTime: draft.duration)
        cleanupFinishedTimers()
    }

    // Convenience method for the "+" button demo.
    func startQuick(seconds: Int) {
        draft = Draft(hours: 0, minutes: 0, seconds: seconds)
        startFromDraft()
        draft = Draft()
    }

    func focus(_ item: TimerItem) {
        focusedTimerID = item.id
    }

    // MARK: - Private

    private func handleTimerDidFinish() {
        cleanupFinishedTimers()
    }

    private func cleanupFinishedTimers() {
        // For Chapter 1 we remove finished timers completely.
        // In a later chapter you could keep them as "recents" even after completion.
        timers.removeAll { $0.manager.status == .idle && $0.manager.remainingTime == .seconds(0) }

        // If nothing is running, return to the picker state (no focused timer).
        if !hasRunningTimers {
            focusedTimerID = nil
            return
        }

        // If the focused timer was removed, pick the first running one.
        if let focusedTimerID, !timers.contains(where: { $0.id == focusedTimerID }) {
            self.focusedTimerID = runningTimers.first?.id
        }
    }
}
