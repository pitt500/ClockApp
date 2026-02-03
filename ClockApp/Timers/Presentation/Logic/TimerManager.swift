//
//  TimerManager.swift
//  ClockApp
//
//  Created by Pedro Rojas on 20/01/26.
//

import SwiftUI

@Observable
final class TimerManager {
    enum Status: Equatable {
        case idle
        case running
        case paused
    }

    private(set) var status: Status = .idle
    private(set) var totalTime: Duration = .seconds(0)       // Preset duration, always kept
    private(set) var remainingTime: Duration = .seconds(0)   // Countdown value

    // When running, this marks the expected end time (includes a small grace period).
    private(set) var endDate: Date?

    // Small extra time to keep 0:00 visible before firing onDidFinish.
    private(set) var finishGrace: TimeInterval = 0.50

    // Source of truth for progress (will include grace).
    private(set) var totalInterval: TimeInterval = 0
    private(set) var remainingInterval: TimeInterval = 0

    private var timer: Timer?
    private let activityHandler: TimerActivityHandling?

    // Fired only when the timer reaches 0 naturally (after grace).
    var onDidFinish: (() -> Void)?

    init(activityHandler: TimerActivityHandling? = nil) {
        self.activityHandler = activityHandler
    }

    // MARK: - Public API

    func setTimer(totalTime: Duration) {
        self.totalTime = totalTime
        self.totalInterval = max(0, TimeInterval(totalTime.components.seconds))
        self.remainingInterval = self.totalInterval + finishGrace

        // UI starts at preset seconds.
        self.remainingTime = totalTime

        start()
    }

    func start() {
        guard remainingInterval > 0 else { return }

        status = .running
        endDate = Date.now.addingTimeInterval(remainingInterval)

        activityHandler?.start(for: self, title: "Timer Demo")

        // Sync one update now so UI is consistent immediately.
        syncRemainingTime(now: Date.now)

        startUnderlyingTimer()
    }

    func pause() {
        guard status == .running else { return }
        guard let endDate else { return }

        // Freeze precise remainingInterval.
        remainingInterval = max(0, endDate.timeIntervalSince(Date.now))

        status = .paused
        self.endDate = nil

        timer?.invalidate()
        timer = nil

        // Keep UI text stable at the current derived seconds.
        syncRemainingTime(now: Date.now)

        activityHandler?.update(remainingTime: remainingTime, isPaused: true)
    }

    func resume() {
        guard remainingInterval > 0 else { return }

        status = .running
        endDate = Date.now.addingTimeInterval(remainingInterval)

        // Sync one update now so it does not jump.
        syncRemainingTime(now: Date.now)

        activityHandler?.update(remainingTime: remainingTime, isPaused: false)
        startUnderlyingTimer()
    }

    // User-driven stop. Does NOT fire onDidFinish.
    func cancel() {
        stopInternal()
        resetToTotalTime()
    }

    // Called by the Store after it has moved the timer to Recents.
    func resetToTotalTime() {
        remainingTime = totalTime
        remainingInterval = totalInterval + finishGrace
    }

    // MARK: - Private

    private func finishNaturally() {
        stopInternal()
        remainingTime = .seconds(0)
        remainingInterval = 0
        onDidFinish?()
    }

    private func stopInternal() {
        status = .idle
        timer?.invalidate()
        timer = nil
        endDate = nil

        activityHandler?.end()
    }

    /// Derives a discrete, whole-second value from a continuous time interval.
    /// - Starts from the real remaining interval.
    /// - Subtracts the internal grace offset.
    /// - Collapses sub-second precision into whole seconds.
    /// - Ensures the countdown does not advance early or visually lag behind.
    private func remainingDiscreteSeconds() -> Int {
        let uiInterval = max(0, remainingInterval - finishGrace)
        return Int(ceil(uiInterval))
    }

    private func syncRemainingTime(now: Date) {
        // Update remainingInterval from endDate if running.
        if status == .running, let endDate {
            remainingInterval = max(0, endDate.timeIntervalSince(now))
        }

        let seconds = remainingDiscreteSeconds()
        let next = Duration.seconds(seconds)

        // Avoid extra publishes.
        if remainingTime != next {
            remainingTime = next
        }
    }

    private func tick() async {
        guard status == .running else { return }
        guard let endDate else { return }

        let now = Date.now
        remainingInterval = max(0, endDate.timeIntervalSince(now))

        // Update UI text projection (seconds) at most when it changes.
        syncRemainingTime(now: now)
        activityHandler?.update(remainingTime: remainingTime, isPaused: false)

        // Finish only after grace truly ends.
        if now >= endDate {
            finishNaturally()
        }
    }

    private func startUnderlyingTimer() {
        timer?.invalidate()

        // Small cadence to avoid "skipping" due to drift, but UI updates only on second changes.
        timer = Timer(timeInterval: 0.10, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { await self.tick() }
        }

        // RunLoop anchor for the RunLoop explanation video.
        RunLoop.main.add(timer!, forMode: .common)
    }

    deinit {
        timer?.invalidate()
    }
}
