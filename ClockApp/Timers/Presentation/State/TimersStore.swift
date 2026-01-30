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

    // Active timers (running or paused). Append at the end.
    var activeTimers: [TimerItem] = []

    // Inactive presets (most recent first). Insert at 0.
    var recentTimers: [TimerItem] = []

    // MARK: - Actions

    func startFromDraft() {
        guard draft.isValid else { return }
        createAndActivateTimer(duration: draft.duration)
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

    func cancel(_ item: TimerItem) {
        item.manager.cancel()
        moveToRecents(item)
    }

    // MARK: - Private

    private func startPreset(_ item: TimerItem) {
        removeFromRecents(item)
        activate(item)
    }

    private func createAndActivateTimer(duration: Duration) {
        let manager = TimerManager(activityHandler: NoopTimerActivityHandler())

        manager.onDidFinish = { [weak self, weak manager] in
            guard let self, let manager else { return }
            self.handleTimerDidFinish(manager)
        }

        let item = TimerItem(
            label: "Timer",
            configuredDuration: duration,
            manager: manager
        )

        activate(item)
    }

    private func activate(_ item: TimerItem) {
        // Active: append at the end (cheap).
        activeTimers.append(item)

        // Ensure the manager starts from the preset duration.
        item.manager.setTimer(totalTime: item.configuredDuration)
    }

    private func handleTimerDidFinish(_ manager: TimerManager) {
        guard let item = activeTimers.first(where: { $0.manager === manager }) else { return }
        moveToRecents(item)
    }

    private func moveToRecents(_ item: TimerItem) {
        activeTimers.removeAll { $0.id == item.id }
        insertIntoRecents(item)
    }

    private func removeFromRecents(_ item: TimerItem) {
        recentTimers.removeAll { $0.id == item.id }
    }
    
    private func insertIntoRecents(_ item: TimerItem) {
        recentTimers.removeAll { $0.id == item.id }
        recentTimers.insert(item, at: 0)
    }
}
