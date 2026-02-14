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

    // MARK: - Intents

    /// Creates and starts a new timer from the picker draft.
    func startFromDraft() {
        guard draft.isValid else { return }

        // 1) Ensure the configured duration exists in Recents (unique by duration).
        ensureRecentPresetExists(for: draft.duration)

        // 2) Always create a NEW active instance (Clock.app behavior).
        let active = makeActiveTimer(configuredDuration: draft.duration)
        startActive(active)

        // Reset picker after creating the timer.
        draft = .init()
    }

    /// Starts a new active timer instance from a Recents preset.
    /// Recents is not modified (the preset stays in the list).
    func activate(_ preset: TimerItem) {
        let active = makeActiveTimer(configuredDuration: preset.configuredDuration)
        startActive(active)
    }

    /// Toggles a timer between running and paused.
    /// If it's a Recents preset, it starts a NEW active instance.
    func toggle(_ item: TimerItem) {
        // If this is an active item, toggle its running state.
        if activeTimers.contains(where: { $0.id == item.id }) {
            switch item.manager.status {
            case .running:
                item.manager.pause()
            case .paused:
                item.manager.resume()
            case .idle:
                // Active list shouldn't contain idle items, but don't crash.
                break
            }
            return
        }

        // Otherwise, treat it as a Recents preset: start a NEW active instance.
        activate(item)
    }

    /// Cancels a timer explicitly (user-driven).
    func cancel(_ item: TimerItem) {
        item.manager.cancel()

        // Remove the active instance.
        activeTimers.removeAll { $0.id == item.id }

        // Ensure a unique preset exists in Recents.
        ensureRecentPresetExists(for: item.configuredDuration)
    }

    // MARK: - Finish Handling

    private func handleTimerDidFinish(_ manager: TimerManager) {
        guard let item = activeTimers.first(where: { $0.manager === manager }) else { return }

        // Remove the finished active instance.
        activeTimers.removeAll { $0.id == item.id }

        // Ensure a unique preset exists in Recents.
        ensureRecentPresetExists(for: item.configuredDuration)
    }

    // MARK: - Helpers

    private func ensureRecentPresetExists(for duration: Duration) {
        let key = durationKey(duration)
        guard !recentTimers.contains(where: { durationKey($0.configuredDuration) == key }) else {
            return
        }

        let manager = TimerManager()
        manager.setPreset(totalTime: duration)

        let preset = TimerItem(
            label: "Timer",
            configuredDuration: duration,
            manager: manager
        )

        // New presets are inserted at the end.
        recentTimers.append(preset)
    }

    private func makeActiveTimer(configuredDuration: Duration) -> TimerItem {
        TimerItem(
            label: "Timer",
            configuredDuration: configuredDuration,
            manager: TimerManager()
        )
    }

    private func startActive(_ item: TimerItem) {
        activeTimers.append(item)

        // Store is the single owner of onDidFinish.
        item.manager.onDidFinish = { [weak self, weak manager = item.manager] in
            guard let self, let manager else { return }
            self.handleTimerDidFinish(manager)
        }

        // Always start from the configured duration.
        item.manager.setTimer(totalTime: item.configuredDuration)
    }

    private func durationKey(_ duration: Duration) -> Int {
        // Your app uses whole seconds.
        max(0, Int(duration.components.seconds))
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
