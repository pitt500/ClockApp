//
//  TimersStore.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//

import SwiftUI

@Observable
final class TimersStore {

    // MARK: - Draft (Picker State)

    struct Draft: Equatable {
        var hours: Int = 0
        var minutes: Int = 0
        var seconds: Int = 12

        var isValid: Bool { hours > 0 || minutes > 0 || seconds > 0 }

        var duration: Duration {
            let totalSeconds = hours * 3600 + minutes * 60 + seconds
            return .seconds(totalSeconds)
        }
    }

    var draft: Draft = .init()

    // MARK: - Timers State

    private(set) var activeTimers: [TimerItem] = []
    private(set) var recentTimers: [TimerItem] = []

    private enum Layout {
        static let naturalFinishFeedbackDelay: TimeInterval = 0.25
    }

    // MARK: - Intents

    /// Creates and starts a new timer from the picker draft.
    func startFromDraft() {
        guard draft.isValid else { return }

        let item = TimerItem(
            label: "Timer",
            configuredDuration: draft.duration,
            manager: TimerManager()
        )

        activate(item)

        // Reset picker after creating the timer.
        draft = .init()
    }

    /// Activates a timer (moves it to active and starts it).
    func activate(_ item: TimerItem) {
        // Remove from recents if present.
        recentTimers.removeAll { $0.id == item.id }

        // Active timers: append at the end (Clock.app behavior).
        if !activeTimers.contains(where: { $0.id == item.id }) {
            activeTimers.append(item)
        }

        // Store is the single owner of onDidFinish.
        item.manager.onDidFinish = { [weak self, weak manager = item.manager] in
            guard let self, let manager else { return }
            self.handleTimerDidFinish(manager)
        }

        // Always start from the configured duration.
        item.manager.setTimer(totalTime: item.configuredDuration)
    }

    /// Toggles a timer between running and paused.
    /// If the timer is idle (e.g. from recents), it gets activated.
    func toggle(_ item: TimerItem) {
        switch item.manager.status {
        case .running:
            item.manager.pause()

        case .paused:
            item.manager.resume()

        case .idle:
            activate(item)
        }
    }

    /// Cancels a timer explicitly (user-driven).
    func cancel(_ item: TimerItem) {
        item.manager.cancel()
        moveToRecents(item)
        item.manager.resetToTotalTime()
    }

    // MARK: - Finish Handling

    private func handleTimerDidFinish(_ manager: TimerManager) {
        guard let item = activeTimers.first(where: { $0.manager === manager }) else { return }

        moveToRecents(item)

        // Reset so the recents row shows the preset duration.
        item.manager.resetToTotalTime()
    }

    // MARK: - Helpers

    private func moveToRecents(_ item: TimerItem) {
        activeTimers.removeAll { $0.id == item.id }

        // Recents should never contain duplicates.
        recentTimers.removeAll { $0.id == item.id }

        // Recents: insert at the beginning (most recent first).
        recentTimers.insert(item, at: 0)
    }
}

extension TimersStore {
    func deleteActiveTimers(at offsets: IndexSet) {
        activeTimers.remove(atOffsets: offsets)
    }

    func deleteRecentTimers(at offsets: IndexSet) {
        recentTimers.remove(atOffsets: offsets)
    }
}
