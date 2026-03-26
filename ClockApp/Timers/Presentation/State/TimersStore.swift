//
//  TimersStore.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//

import SwiftUI

@Observable
final class TimersStore {

    struct AlertState {
        let id: UUID
        let label: String
        let configuredDuration: Duration
        let manager: TimerManager
    }

    // MARK: - Draft (Picker State)

    struct Draft: Equatable {
        var hours: Int = 0
        var minutes: Int = 0
        var seconds: Int = 12

        var label: String = ""

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
    private var currentAlert: AlertState?

    // MARK: - Persistence

    private let persistence: TimersPersistence
    private let liveActivityCoordinator: TimerLiveActivityCoordinating
    private let makeActivityHandler: () -> TimerActivityHandling

    init(
        persistence: TimersPersistence = FileTimersPersistence(),
        liveActivityCoordinator: TimerLiveActivityCoordinating = TimerLiveActivityCoordinator(),
        makeActivityHandler: @escaping () -> TimerActivityHandling = { TimerActivityController() }
    ) {
        self.persistence = persistence
        self.liveActivityCoordinator = liveActivityCoordinator
        self.makeActivityHandler = makeActivityHandler
        TimerLiveActivityCommandCenter.shared.handler = self
        TimerAlertCommandCenter.shared.handler = self
    }

    #warning("Is this necessary?")
    deinit {
        if TimerLiveActivityCommandCenter.shared.handler === self {
            TimerLiveActivityCommandCenter.shared.handler = nil
        }

        if TimerAlertCommandCenter.shared.handler === self {
            TimerAlertCommandCenter.shared.handler = nil
        }
    }

    // MARK: - Persistence API

    func loadRecentTimers() async {
        if let loaded = try? await persistence.loadRecentTimers() {
            recentTimers = loaded
        }
    }

    private func persistRecents() {
        let snapshot = recentTimers
        Task { [persistence] in
            try? await persistence.saveRecentTimers(snapshot)
        }
    }

    // MARK: - Intents

    /// Creates and starts a new timer from the picker draft.
    func startFromDraft() {
        guard draft.isValid else { return }

        // 1) Ensure the configured duration exists in Recents (unique by duration + label).
        ensureRecentPresetExists(for: draft.duration, label: draft.label)

        // 2) Always create a NEW active instance.
        let active = makeActiveTimer(configuredDuration: draft.duration, label: draft.label)
        startActive(active)

        draft = .init()
    }

    /// Starts a new active timer instance from a Recents preset.
    /// Recents is not modified (the preset stays in the list).
    func activate(_ preset: TimerItem) {
        let active = makeActiveTimer(configuredDuration: preset.configuredDuration, label: preset.label)
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

            reconcileLiveActivities()
            return
        }

        // Otherwise, treat it as a Recents preset: start a NEW active instance.
        activate(item)
    }

    /// Cancels a timer explicitly (user-driven).
    func cancel(_ item: TimerItem) {
        item.manager.cancel()

        // Remove the active instance.
        removeActiveTimer(item)

        ensureRecentPresetExists(for: item.configuredDuration, label: item.label)
        reconcileLiveActivities()
    }

    // MARK: - Finish Handling
    
    private func handleTimerDidFinish(_ manager: TimerManager) {
        guard let item = activeTimers.first(where: { $0.manager === manager }) else { return }

        removeActiveTimer(item)

        ensureRecentPresetExists(for: item.configuredDuration, label: item.label)

        if let currentAlert {
            currentAlert.manager.cancel()
        }

        currentAlert = AlertState(
            id: item.id,
            label: item.label,
            configuredDuration: item.configuredDuration,
            manager: item.manager
        )
        item.manager.showAlert()
        reconcileLiveActivities()
    }

    // MARK: - Helpers

    private func removeActiveTimer(_ timer: TimerItem) {
        activeTimers.removeAll { $0.id == timer.id }
    }

    private func ensureRecentPresetExists(for duration: Duration, label: String) {
        let key = recentKey(duration: duration, label: label)
        guard !recentTimers.contains(where: { recentKey(duration: $0.configuredDuration, label: $0.label) == key }) else {
            return
        }

        let manager = TimerManager(label: label)
        manager.setPreset(totalTime: duration)

        let preset = TimerItem(
            label: label,
            configuredDuration: duration,
            manager: manager
        )

        // New presets are inserted at the top.
        recentTimers.insert(preset, at: 0)
        persistRecents()
    }

    private func makeActiveTimer(configuredDuration: Duration, label: String) -> TimerItem {
        TimerItem(
            label: label,
            configuredDuration: configuredDuration,
            manager: TimerManager(
                label: label,
                activityHandler: makeActivityHandler()
            )
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
        reconcileLiveActivities()
    }

    private func reconcileLiveActivities() {
        liveActivityCoordinator.reconcile(activeTimers: activeTimers, at: .now)
    }

    private func dismissAlert(_ alert: AlertState) {
        alert.manager.cancel()
        currentAlert = nil
        reconcileLiveActivities()
    }

    private func durationKey(_ duration: Duration) -> Int {
        max(0, Int(duration.components.seconds))
    }

    private func recentKey(duration: Duration, label: String) -> String {
        "\(durationKey(duration))|\(label)"
    }
}

extension TimersStore {
    func deleteActiveTimers(at offsets: IndexSet) {
        cancelActiveTimers(at: offsets)
        
        // This is required because there's a SwiftUI Glitch when you delete elements in a list and you have a header like the one I have in this app.
        //If you are reading this, forgive me and feel free to improve this if you have a better idea.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }

            self.activeTimers.remove(atOffsets: offsets)
            reconcileLiveActivities()
        }
    }

    private func cancelActiveTimers(at offsets: IndexSet) {
        let timersToCancel = offsets
            .compactMap { index in
                activeTimers.indices.contains(index) ? activeTimers[index] : nil
            }

        timersToCancel.forEach { $0.manager.cancel() }
    }

    func deleteRecentTimers(at offsets: IndexSet) {
        recentTimers.remove(atOffsets: offsets)
        persistRecents()
    }
}

extension TimersStore: TimerLiveActivityCommandHandling {
    func toggleCurrentLiveActivityTimer() {
        guard let current = liveActivityCoordinator.highestPriorityTimer(from: activeTimers, at: .now) else { return }
        toggle(current)
    }

    func cancelCurrentLiveActivityTimer() {
        guard let current = liveActivityCoordinator.highestPriorityTimer(from: activeTimers, at: .now) else { return }
        cancel(current)
    }
}

extension TimersStore: TimerAlertCommandHandling {
    func dismissCurrentTimerAlert() {
        guard let current = currentAlert else { return }
        dismissAlert(current)
    }
}
