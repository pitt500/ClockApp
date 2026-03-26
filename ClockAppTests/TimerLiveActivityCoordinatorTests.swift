//
//  TimerLiveActivityCoordinatorTests.swift
//  ClockApp
//
//  Created by Pedro Rojas on 22/03/26.
//

import Foundation
import Testing
@testable import ClockApp

@Suite
@MainActor
struct TimerLiveActivityCoordinatorTests {
    private let fixedNow = Date(timeIntervalSinceReferenceDate: 1_000)

    @Test
    func `Highest priority timer prefers running timer with smallest remaining interval`() {
        let coordinator = TimerLiveActivityCoordinator()

        let slow = makeRunningTimerItem(label: "Slow", seconds: 90).item
        let fast = makeRunningTimerItem(label: "Fast", seconds: 20).item

        let result = coordinator.highestPriorityTimer(from: [slow, fast], at: fixedNow)

        #expect(result?.id == fast.id)
    }

    @Test
    func `Highest priority timer prefers running timer over paused timer`() {
        let coordinator = TimerLiveActivityCoordinator()

        let paused = makePausedTimerItem(label: "Paused", seconds: 10).item
        let running = makeRunningTimerItem(label: "Running", seconds: 60).item

        let result = coordinator.highestPriorityTimer(from: [paused, running], at: fixedNow)

        #expect(result?.id == running.id)
    }

    @Test
    func `Highest priority timer prefers paused timer when no running timers exist`() {
        let coordinator = TimerLiveActivityCoordinator()

        let longPaused = makePausedTimerItem(label: "Long", seconds: 60).item
        let shortPaused = makePausedTimerItem(label: "Short", seconds: 10).item

        let result = coordinator.highestPriorityTimer(from: [longPaused, shortPaused], at: fixedNow)

        #expect(result?.id == shortPaused.id)
    }

    @Test
    func `Highest priority timer returns nil for empty timers`() {
        let coordinator = TimerLiveActivityCoordinator()

        let result = coordinator.highestPriorityTimer(from: [], at: fixedNow)

        #expect(result == nil)
    }

    @Test
    func `Reconcile assigns highest relevance score to the most urgent running timer`() {
        let coordinator = TimerLiveActivityCoordinator()

        let first = makeRunningTimerItem(label: "First", seconds: 10)
        let second = makeRunningTimerItem(label: "Second", seconds: 30)

        coordinator.reconcile(activeTimers: [second.item, first.item], at: fixedNow)

        #expect(first.activity.lastRelevanceScore == 100)
        #expect(second.activity.lastRelevanceScore == 99)
    }

    @Test
    func `Reconcile keeps paused timers below running timers`() {
        let coordinator = TimerLiveActivityCoordinator()

        let running = makeRunningTimerItem(label: "Running", seconds: 20)
        let paused = makePausedTimerItem(label: "Paused", seconds: 10)

        coordinator.reconcile(activeTimers: [paused.item, running.item], at: fixedNow)

        #expect(running.activity.lastRelevanceScore == 100)
        #expect(paused.activity.lastRelevanceScore == 10)
    }

    @Test
    func `Reconcile gives highest score to paused timer when no running timers exist`() {
        let coordinator = TimerLiveActivityCoordinator()

        let first = makePausedTimerItem(label: "First", seconds: 10)
        let second = makePausedTimerItem(label: "Second", seconds: 30)

        coordinator.reconcile(activeTimers: [second.item, first.item], at: fixedNow)

        #expect(first.activity.lastRelevanceScore == 100)
        #expect(second.activity.lastRelevanceScore == 99)
    }

    @Test
    func `Reconcile sets idle timers relevance score to zero`() {
        let coordinator = TimerLiveActivityCoordinator()

        let running = makeRunningTimerItem(label: "Running", seconds: 20)
        let idle = makeIdleTimerItem(label: "Idle", seconds: 40)

        coordinator.reconcile(activeTimers: [running.item, idle.item], at: fixedNow)

        #expect(running.activity.lastRelevanceScore == 100)
        #expect(idle.activity.lastRelevanceScore == 0)
    }

    // MARK: - Helpers

    private func makeRunningTimerItem(label: String, seconds: Int) -> (item: TimerItem, activity: ActivitySpy) {
        let activity = ActivitySpy()
        let manager = makeManager(label: label, activity: activity)
        let duration = Duration.seconds(seconds)

        manager.setTimer(totalTime: duration)

        return (
            TimerItem(
                label: label,
                configuredDuration: duration,
                manager: manager
            ),
            activity
        )
    }

    private func makePausedTimerItem(label: String, seconds: Int) -> (item: TimerItem, activity: ActivitySpy) {
        let activity = ActivitySpy()
        let manager = makeManager(label: label, activity: activity)
        let duration = Duration.seconds(seconds)

        manager.setTimer(totalTime: duration)
        manager.pause()

        return (
            TimerItem(
                label: label,
                configuredDuration: duration,
                manager: manager
            ),
            activity
        )
    }

    private func makeIdleTimerItem(label: String, seconds: Int) -> (item: TimerItem, activity: ActivitySpy) {
        let activity = ActivitySpy()
        let manager = makeManager(label: label, activity: activity)
        let duration = Duration.seconds(seconds)

        manager.setPreset(totalTime: duration)

        return (
            TimerItem(
                label: label,
                configuredDuration: duration,
                manager: manager
            ),
            activity
        )
    }

    private func makeManager(label: String, activity: ActivitySpy) -> TimerManager {
        TimerManager(
            label: label,
            activityHandler: activity,
            now: { fixedNow },
            makeRepeatingTimer: { _, _ in AnyTimerCancellable {} }
        )
    }
}

extension TimerLiveActivityCoordinatorTests {
    final class ActivitySpy: TimerActivityHandling {
        private(set) var lastRelevanceScore: Double = 0

        func start(for manager: TimerManager, title: String) {}

        func update(for manager: TimerManager, relevanceScore: Double?) {
            lastRelevanceScore = relevanceScore ?? 0
        }

        func showAlert(title: String) {}

        func end() {}
    }
}
