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
        timers.filter { $0.manager.status == .running || $0.manager.status == .paused }
    }

    var hasRunningTimers: Bool {
        !runningTimers.isEmpty
    }

    // Focused timer must be running/paused. If not, we show the picker.
    var focusedTimer: TimerItem? {
        if let id = focusedTimerID,
           let match = timers.first(where: { $0.id == id }),
           match.manager.status != .idle {
            return match
        }
        return runningTimers.first
    }

    // Recents accumulates everything, but hides the focused one to avoid duplicates.
    var recents: [TimerItem] {
        guard let focused = focusedTimer else { return timers }
        return timers.filter { $0.id != focused.id }
    }

    // MARK: - Actions

    func startFromDraft() {
        guard draft.isValid else { return }
        createAndStartTimer(duration: draft.duration)
    }

    func startPreset(_ item: TimerItem) {
        // Reuse the same manager to mimic iOS behavior: preset stays, timer starts again.
        focusedTimerID = item.id
        item.manager.setTimer(totalTime: item.configuredDuration)
    }

    func toggle(_ item: TimerItem) {
        switch item.manager.status {
        case .idle:
            startPreset(item)
        case .running:
            item.manager.pause()
        case .paused:
            item.manager.resume()
        }
    }

    // MARK: - Private

    private func createAndStartTimer(duration: Duration) {
        let manager = TimerManager(activityHandler: NoopTimerActivityHandler())

        manager.onDidFinish = { [weak self] in
            self?.ensureFocusIsValid()
        }

        let item = TimerItem(label: "Timer", configuredDuration: duration, manager: manager)
        timers.insert(item, at: 0)
        focusedTimerID = item.id

        manager.setTimer(totalTime: duration)
        ensureFocusIsValid()
    }

    private func ensureFocusIsValid() {
        if !hasRunningTimers {
            focusedTimerID = nil
            return
        }

        if let focused = focusedTimer, focused.manager.status != .idle {
            return
        }

        focusedTimerID = runningTimers.first?.id
    }
}
