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
    
    private var remainingTimeWhenNotRunning: TimeInterval = 0
    private var timer: Timer?
    private let activityHandler: TimerActivityHandling?

    var totalTimeInterval: TimeInterval {
        max(0, totalTimeInSeconds.toTimeInterval() + finishGrace)
    }

    var onDidFinish: (() -> Void)?

    init(activityHandler: TimerActivityHandling? = nil) {
        self.activityHandler = activityHandler
    }

    // MARK: - Public API

    func setTimer(totalTime: Duration) {
        totalTimeInSeconds = totalTime
        remainingTimeWhenNotRunning = totalTimeInSeconds.toTimeInterval() + finishGrace
        remainingTimeInSeconds = totalTimeInSeconds
        start()
    }

    func start() {
        guard status == .idle else { return }
        guard remainingTimeWhenNotRunning > 0 else { return }

        enterRunning(
            interval: remainingTimeWhenNotRunning,
            activity: .start(title: "Timer Demo")
        )
    }

    func pause() {
        guard status == .running, let endDate else { return }

        let now = Date.now
        remainingTimeWhenNotRunning = max(0, endDate.timeIntervalSince(now))

        status = .paused
        self.endDate = nil

        stopUnderlyingTimer()

        syncRemainingTime(now: now)
        activityHandler?.update(remainingTime: remainingTimeInSeconds, isPaused: true)
    }

    func resume() {
        guard status == .paused else { return }
        guard remainingTimeWhenNotRunning > 0 else { return }

        enterRunning(
            interval: remainingTimeWhenNotRunning,
            activity: .update(isPaused: false)
        )
    }

    func cancel() {
        stopInternal()
        resetToTotalTime()
    }

    func resetToTotalTime() {
        remainingTimeInSeconds = totalTimeInSeconds
        remainingTimeWhenNotRunning = totalTimeInSeconds.toTimeInterval() + finishGrace
    }
    
    func remainingInterval(at date: Date) -> TimeInterval {
        if status == .running, let endDate {
            return max(0, endDate.timeIntervalSince(date))
        }
        return max(0, remainingTimeWhenNotRunning)
    }

    // MARK: - Private

    private enum ActivityTransition {
        case start(title: String)
        case update(isPaused: Bool)
    }

    private func enterRunning(interval: TimeInterval, activity: ActivityTransition) {
        status = .running
        endDate = Date.now.addingTimeInterval(interval)

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

    private func projectedLabelSeconds(now: Date) -> Int {
        let interval = remainingInterval(at: now)
        let projected = max(0, interval - finishGrace)
        return Int(ceil(projected))
    }

    private func syncRemainingTime(now: Date) {
        let seconds = projectedLabelSeconds(now: now)
        remainingTimeInSeconds = Duration.seconds(seconds)
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
        remainingTimeWhenNotRunning = 0
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
