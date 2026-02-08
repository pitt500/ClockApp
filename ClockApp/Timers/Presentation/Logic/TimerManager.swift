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

    // Preset duration (without grace). This is the configured value used by Recents.
    private(set) var totalTimeInSeconds: Duration = .seconds(0)

    // Discrete, whole-second projection for the label.
    private(set) var remainingTimeInSeconds: Duration = .seconds(0)

    // When running, this marks the expected end time (includes grace).
    private(set) var endDate: Date?

    // Small extra time to keep 0:00 visible before firing onDidFinish.
    private(set) var finishGrace: TimeInterval = 0.50

    // Source-of-truth for progress, expressed as TimeInterval.
    // Kept for compatibility with existing views/providers, but derived from totalTime.
    var totalTimeInterval: TimeInterval { totalTimeInSeconds.toTimeInterval()
    }

    // Continuous remaining interval INCLUDING grace.
    // When running: derived from endDate - now.
    // When paused/idle: stable snapshot stored in storedRemainingInterval.
    var remainingInterval: TimeInterval {
        switch status {
        case .running:
            guard let endDate else { return 0 }
            return max(0, endDate.timeIntervalSince(Date.now))
        case .paused, .idle:
            return max(0, storedRemainingInterval)
        }
    }

    private var storedRemainingInterval: TimeInterval = 0
    private var timer: Timer?
    private let activityHandler: TimerActivityHandling?

    // Fired only when the timer reaches 0 naturally (after grace).
    var onDidFinish: (() -> Void)?

    init(activityHandler: TimerActivityHandling? = nil) {
        self.activityHandler = activityHandler
    }

    // MARK: - Public API

    func setTimer(totalTime: Duration) {
        self.totalTimeInSeconds = totalTime
        
        // Internal continuous interval starts at preset + grace.
        storedRemainingInterval = totalTimeInterval + finishGrace
        
        // Label starts at preset seconds (without grace).
        remainingTimeInSeconds = totalTimeInSeconds

        start()
    }

    func start() {
        guard status == .idle else { return }
        guard storedRemainingInterval > 0 else { return }

        status = .running
        endDate = Date.now.addingTimeInterval(storedRemainingInterval)

        activityHandler?.start(for: self, title: "Timer Demo")

        // Sync one update now so UI is consistent immediately.
        syncRemainingTime(now: Date.now)

        startUnderlyingTimer()
    }

    func pause() {
        guard status == .running else { return }
        guard let endDate else { return }

        let now = Date.now

        // Freeze precise remaining interval (includes grace).
        storedRemainingInterval = max(0, endDate.timeIntervalSince(now))

        status = .paused
        self.endDate = nil

        timer?.invalidate()
        timer = nil

        // Keep label stable at the current derived seconds.
        syncRemainingTime(now: now)

        activityHandler?.update(remainingTime: remainingTimeInSeconds, isPaused: true)
    }

    func resume() {
        guard status == .paused else { return }
        guard storedRemainingInterval > 0 else { return }

        status = .running
        endDate = Date.now.addingTimeInterval(storedRemainingInterval)

        // Sync one update now so it does not jump.
        syncRemainingTime(now: Date.now)

        activityHandler?.update(remainingTime: remainingTimeInSeconds, isPaused: false)
        startUnderlyingTimer()
    }

    // User-driven stop. Does NOT fire onDidFinish.
    func cancel() {
        stopInternal()
        resetToTotalTime()
    }

    // Called by the Store after it has moved the timer to Recents.
    func resetToTotalTime() {
        remainingTimeInSeconds = totalTimeInSeconds
        storedRemainingInterval = totalTimeInSeconds.toTimeInterval() + finishGrace
    }

    // MARK: - Private
    private func finishNaturally() {
        stopInternal()
        remainingTimeInSeconds = .seconds(0)
        storedRemainingInterval = 0
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
    /// - Starts from the real remaining interval (includes grace).
    /// - Subtracts the internal grace offset.
    /// - Collapses sub-second precision into whole seconds.
    /// - Ensures the countdown does not advance early or visually lag behind.
    private func remainingDiscreteSeconds(now: Date) -> Int {
        let interval: TimeInterval
        switch status {
        case .running:
            if let endDate {
                interval = max(0, endDate.timeIntervalSince(now))
            } else {
                interval = 0
            }
        case .paused, .idle:
            interval = max(0, storedRemainingInterval)
        }

        let projected = max(0, interval - finishGrace)
        return Int(ceil(projected))
    }

    private func syncRemainingTime(now: Date) {
        let seconds = remainingDiscreteSeconds(now: now)
        let next = Duration.seconds(Int64(seconds))

        // Avoid extra publishes.
        if remainingTimeInSeconds != next {
            remainingTimeInSeconds = next
        }
    }

    private func tick() async {
        guard status == .running else { return }
        guard let endDate else { return }

        let now = Date.now

        // Update label projection (seconds) at most when it changes.
        syncRemainingTime(now: now)
        activityHandler?.update(remainingTime: remainingTimeInSeconds, isPaused: false)

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

extension Duration {
    func toTimeInterval() -> TimeInterval {
        max(0, TimeInterval(self.components.seconds))
    }
}
