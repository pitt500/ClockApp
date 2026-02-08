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
    private(set) var totalTimeInSeconds: Duration = .seconds(0)
    private(set) var remainingTimeInSeconds: Duration = .seconds(0)
    private(set) var endDate: Date?
    private(set) var finishGrace: TimeInterval = 0.50

    var totalTimeInterval: TimeInterval { totalTimeInSeconds.toTimeInterval() }

    var remainingInterval: TimeInterval {
        remainingIntervalIncludingGrace(now: Date.now)
    }

    private var timeRemainingInPause: TimeInterval = 0
    private var timer: Timer?
    private let activityHandler: TimerActivityHandling?

    var onDidFinish: (() -> Void)?

    init(activityHandler: TimerActivityHandling? = nil) {
        self.activityHandler = activityHandler
    }

    // MARK: - Public API

    func setTimer(totalTime: Duration) {
        totalTimeInSeconds = totalTime
        timeRemainingInPause = totalTimeInterval + finishGrace
        remainingTimeInSeconds = totalTimeInSeconds
        start()
    }

    func start() {
        guard status == .idle else { return }
        guard timeRemainingInPause > 0 else { return }

        enterRunning(
            intervalIncludingGrace: timeRemainingInPause,
            activity: .start(title: "Timer Demo")
        )
    }

    func pause() {
        guard status == .running, let endDate else { return }

        let now = Date.now
        timeRemainingInPause = max(0, endDate.timeIntervalSince(now))

        status = .paused
        self.endDate = nil

        stopUnderlyingTimer()

        syncRemainingTime(now: now)
        activityHandler?.update(remainingTime: remainingTimeInSeconds, isPaused: true)
    }

    func resume() {
        guard status == .paused else { return }
        guard timeRemainingInPause > 0 else { return }

        enterRunning(
            intervalIncludingGrace: timeRemainingInPause,
            activity: .update(isPaused: false)
        )
    }

    func cancel() {
        stopInternal()
        resetToTotalTime()
    }

    func resetToTotalTime() {
        remainingTimeInSeconds = totalTimeInSeconds
        timeRemainingInPause = totalTimeInterval + finishGrace
    }

    // MARK: - Private

    private enum ActivityTransition {
        case start(title: String)
        case update(isPaused: Bool)
    }

    private func enterRunning(intervalIncludingGrace: TimeInterval, activity: ActivityTransition) {
        status = .running
        endDate = Date.now.addingTimeInterval(intervalIncludingGrace)

        switch activity {
        case .start(let title):
            activityHandler?.start(for: self, title: title)
        case .update(let isPaused):
            activityHandler?.update(remainingTime: remainingTimeInSeconds, isPaused: isPaused)
        }

        let now = Date.now
        syncRemainingTime(now: now)
        startUnderlyingTimer()
    }

    private func remainingIntervalIncludingGrace(now: Date) -> TimeInterval {
        if status == .running, let endDate {
            return max(0, endDate.timeIntervalSince(now))
        }
        return max(0, timeRemainingInPause)
    }

    private func projectedLabelSeconds(now: Date) -> Int {
        let interval = remainingIntervalIncludingGrace(now: now)
        let projected = max(0, interval - finishGrace)
        return Int(ceil(projected))
    }

    private func syncRemainingTime(now: Date) {
        let seconds = projectedLabelSeconds(now: now)
        let next = Duration.seconds(Int64(seconds))
        if remainingTimeInSeconds != next {
            remainingTimeInSeconds = next
        }
    }

    private func tick() async {
        guard status == .running, let endDate else { return }

        let now = Date.now
        syncRemainingTime(now: now)
        activityHandler?.update(remainingTime: remainingTimeInSeconds, isPaused: false)

        if now >= endDate {
            finishNaturally()
        }
    }

    private func finishNaturally() {
        stopInternal()
        remainingTimeInSeconds = .seconds(0)
        timeRemainingInPause = 0
        onDidFinish?()
    }

    private func stopInternal() {
        status = .idle
        stopUnderlyingTimer()
        endDate = nil
        activityHandler?.end()
    }

    private func startUnderlyingTimer() {
        stopUnderlyingTimer()

        timer = Timer(timeInterval: 0.10, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { await self.tick() }
        }

        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopUnderlyingTimer() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stopUnderlyingTimer()
    }
}

extension Duration {
    func toTimeInterval() -> TimeInterval {
        max(0, TimeInterval(self.components.seconds))
    }
}
