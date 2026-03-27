//
//  TimerManagerTests.swift
//  TimerManagerTests
//
//  Created by Pedro Rojas on 09/02/26.
//

import Foundation
import Testing
@testable import ClockApp

@Suite
@MainActor
struct TimerManagerTests {

    // MARK: - Test doubles

    final class TestClock {
        var now: Date
        init(now: Date = Date(timeIntervalSince1970: 0)) {
            self.now = now
        }

        func advance(by seconds: TimeInterval) {
            now = now.addingTimeInterval(seconds)
        }
    }

    final class ManualRepeatingTimer: TimerCancellable {
        var handler: (() -> Void)?

        func fire() { handler?() }
        func invalidate() { handler = nil }
    }

    final class ActivitySpy: TimerActivityHandling {
        private(set) var startCalls: [String] = []
        private(set) var updates: [(remaining: Duration, isPaused: Bool)] = []
        private(set) var endCallCount: Int = 0

        func start(for manager: TimerManager, title: String) {
            startCalls.append(title)
        }

        func update(for manager: TimerManager, relevanceScore: Double?) {
            updates.append((remaining: manager.remainingTimeInSeconds, isPaused: manager.status == .paused))
        }

        func showAlert(title: String, soundName: String?) {
            fatalError("This method is called by TimerStore.")
        }

        func end() {
            endCallCount += 1
        }
    }

    private func makeSUT(
        clock: TestClock,
        activity: ActivitySpy? = nil
    ) -> (sut: TimerManager, timer: ManualRepeatingTimer) {

        let timer = ManualRepeatingTimer()

        let sut = TimerManager(
            label: "Timer Demo",
            activityHandler: activity,
            now: { clock.now },
            makeRepeatingTimer: { _, handler in
                timer.handler = handler
                return timer
            }
        )

        return (sut, timer)
    }

    private func drainTickTask() async {
        // The timer callback does not call `tick()` directly.
        // Instead, it schedules `tick()` inside a new `Task`.
        //
        // Yielding gives the Swift concurrency scheduler a chance
        // to run that pending Task before the test continues.
        //
        // Two yields are used to ensure the Task is both scheduled
        // and fully executed in a deterministic way, without relying
        // on real time delays.
        await Task.yield()
        await Task.yield()
    }

    // MARK: - Tests

    @Test
    func `Set timer starts running and label shows preset value`() async {
        let clock = TestClock()
        let activity = ActivitySpy()
        let (timerManager, _) = makeSUT(clock: clock, activity: activity)

        timerManager.setTimer(totalTime: .seconds(2))

        #expect(timerManager.status == .running)
        #expect(timerManager.totalTimeInSeconds == .seconds(2))
        #expect(timerManager.remainingTimeInSeconds == .seconds(2))
        #expect(activity.startCalls == ["Timer Demo"])
    }

    @Test
    func `Pause captures remaining time and stops ticking`() async {
        let clock = TestClock()
        let (timerManager, timer) = makeSUT(clock: clock)

        timerManager.setTimer(totalTime: .seconds(3))

        // Advance time and tick once.
        clock.advance(by: 0.25)
        timer.fire()
        await drainTickTask()

        timerManager.pause()
        #expect(timerManager.status == .paused)

        let first = timerManager.remainingInterval(at: clock.now)

        // Even if time advances and we attempt to fire, paused remaining should not change.
        clock.advance(by: 0.50)
        timer.fire()
        await drainTickTask()

        let second = timerManager.remainingInterval(at: clock.now)
        #expect(first == second)
    }

    @Test
    func `Resume continues countdown and finishes after grace`() async {
        let clock = TestClock()
        let activity = ActivitySpy()
        let (timerManager, timer) = makeSUT(clock: clock, activity: activity)

        var didFinish = false
        timerManager.onDidFinish = { didFinish = true }

        timerManager.setTimer(totalTime: .seconds(1))

        // Run a bit, then pause.
        clock.advance(by: 0.20)
        timer.fire()
        await drainTickTask()

        timerManager.pause()
        #expect(timerManager.status == .paused)

        // While paused, time can pass and it should not finish.
        clock.advance(by: 10.0)
        timer.fire()
        await drainTickTask()
        #expect(didFinish == false)
        #expect(timerManager.status == .paused)

        // Resume and fast-forward to just before finish.
        timerManager.resume()
        #expect(timerManager.status == .running)

        // Timer is 1.0s + 0.5s grace.
        // We already spent 0.2s before pausing.
        // Remaining including grace is ~1.3s.
        clock.advance(by: 1.29)
        timer.fire()
        await drainTickTask()
        #expect(didFinish == false)

        clock.advance(by: 0.02)
        timer.fire()
        await drainTickTask()

        #expect(didFinish == true)
        #expect(timerManager.status == .idle)
        #expect(timerManager.remainingTimeInSeconds == .seconds(0))
        #expect(activity.endCallCount == 0)
    }

    @Test
    func `Cancel resets timer without firing finish callback`() async {
        let clock = TestClock()
        let (timerManager, timer) = makeSUT(clock: clock)

        var didFinish = false
        timerManager.onDidFinish = { didFinish = true }

        timerManager.setTimer(totalTime: .seconds(2))

        // Let it tick once.
        clock.advance(by: 0.10)
        timer.fire()
        await drainTickTask()

        timerManager.cancel()
        #expect(timerManager.status == .idle)
        #expect(timerManager.remainingTimeInSeconds == .seconds(2))
        #expect(didFinish == false)
    }

    @Test
    func `Label reaches zero before finish due to grace period`() async {
        let clock = TestClock()
        let (timerManager, timer) = makeSUT(clock: clock)

        timerManager.setTimer(totalTime: .seconds(1))

        // After ~1.0s the label should hit zero, but finish triggers after grace ends.
        clock.advance(by: 1.01)
        timer.fire()
        await drainTickTask()

        #expect(timerManager.remainingTimeInSeconds == .seconds(0))
        #expect(timerManager.status == .running)
    }

    @Test
    func `Remaining interval decreases when evaluated at a later date`() async {
        let clock = TestClock()
        let (timerManager, _) = makeSUT(clock: clock)

        timerManager.setTimer(totalTime: .seconds(5))

        let now = clock.now
        let later = now.addingTimeInterval(2.0)

        let r1 = timerManager.remainingInterval(at: now)
        let r2 = timerManager.remainingInterval(at: later)

        #expect(r1 > r2)
        #expect(r1 > 0)
    }
}
