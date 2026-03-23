//
//  TimerManager.swift
//  ClockApp
//
//  Created by Pedro Rojas on 20/01/26.
//

import SwiftUI

// MARK: - Timer driving (injectable for tests)

protocol TimerCancellable: AnyObject {
    func invalidate()
}

final class AnyTimerCancellable: TimerCancellable {
    private let _invalidate: () -> Void

    init(_invalidate: @escaping () -> Void) {
        self._invalidate = _invalidate
    }

    func invalidate() { _invalidate() }
}

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
    private(set) var liveActivityRelevanceScore: Double = 0
    private(set) var presentationMode: TimerPresentationMode = .normal
    private(set) var alertStartedAt: Date?

    private var endDate: Date?
    private var finishGrace: TimeInterval = 0.50
    private var remainingTimeWhenNotRunning: TimeInterval = 0
    private var timer: TimerCancellable?
    private let activityHandler: TimerActivityHandling?
    private let label: String
    
    // Dependencies (injectable for fast, deterministic tests)
    private let now: () -> Date
    private let makeRepeatingTimer: (_ interval: TimeInterval, _ handler: @escaping () -> Void) -> TimerCancellable


    init(
        label: String,
        activityHandler: TimerActivityHandling? = nil,
        now: @escaping () -> Date = { Date.now },
        makeRepeatingTimer: @escaping (_ interval: TimeInterval, _ handler: @escaping () -> Void) -> TimerCancellable = { interval, handler in
            // Default production implementation uses Foundation.Timer.
            let t = Timer(timeInterval: interval, repeats: true) { _ in handler() }
            RunLoop.main.add(t, forMode: .common)
            return AnyTimerCancellable { t.invalidate() }
        }
    ) {
        self.label = label
        self.activityHandler = activityHandler
        self.now = now
        self.makeRepeatingTimer = makeRepeatingTimer
    }

    /// Configures this manager as an idle "preset" (used for Recents).
    ///
    /// This sets the configured duration and the internal remaining interval (including grace)
    /// without starting the underlying repeating timer.
    func setPreset(totalTime: Duration) {
        stopInternal()
        configure(totalTime: totalTime)
        presentationMode = .normal
        alertStartedAt = nil
    }

    // MARK: - Public API
    var totalTimeInterval: TimeInterval {
        max(0, totalTimeInSeconds.toTimeInterval() + finishGrace)
    }

    var displayedRemainingTime: Duration {
        Duration.seconds(projectedLabelSeconds(now: now()))
    }

    var onDidFinish: (() -> Void)?

    func setTimer(totalTime: Duration) {
        configure(totalTime: totalTime)
        start()
    }

    func start() {
        guard status == .idle else { return }
        guard remainingTimeWhenNotRunning > 0 else { return }

        enterRunning(
            interval: remainingTimeWhenNotRunning,
            activity: .start(title: liveActivityTitle)
        )
    }

    func pause() {
        guard status == .running, let endDate else { return }

        let now = now()
        remainingTimeWhenNotRunning = max(0, endDate.timeIntervalSince(now))

        status = .paused
        presentationMode = .normal
        alertStartedAt = nil
        self.endDate = nil

        stopUnderlyingTimer()

        syncRemainingTime(now: now)
        activityHandler?.update(for: self)
    }

    func resume() {
        guard status == .paused else { return }
        guard remainingTimeWhenNotRunning > 0 else { return }

        enterRunning(
            interval: remainingTimeWhenNotRunning,
            activity: .update
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

    #warning("Is this relevant to manager?")
    func setLiveActivityRelevanceScore(_ score: Double) {
        guard liveActivityRelevanceScore != score else { return }
        liveActivityRelevanceScore = score

        guard status != .idle || presentationMode == .alerting else { return }
        activityHandler?.update(for: self)
    }

    // MARK: - Private

    private enum ActivityTransition {
        case start(title: String)
        case update
    }

    private var liveActivityTitle: String {
        label.isEmpty ? "Timer" : label
    }

    private func configure(totalTime: Duration) {
        totalTimeInSeconds = totalTime
        remainingTimeInSeconds = totalTime
        remainingTimeWhenNotRunning = totalTime.toTimeInterval() + finishGrace
        presentationMode = .normal
        alertStartedAt = nil
    }


    private func enterRunning(interval: TimeInterval, activity: ActivityTransition) {
        status = .running
        presentationMode = .normal
        alertStartedAt = nil
        endDate = now().addingTimeInterval(interval)

        switch activity {
        case .start(let title):
            activityHandler?.start(for: self, title: title)
        case .update:
            activityHandler?.update(for: self)
        }

        syncRemainingTime(now: now())
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

    private func tick() {
        guard status == .running, let endDate else { return }

        let now = now()
        syncRemainingTime(now: now)

        if now >= endDate {
            finishNaturally()
        }
    }

    #warning("Fix this")
    private func finishNaturally() {
        stopUnderlyingTimer()
        endDate = nil
        status = .paused
        remainingTimeInSeconds = .seconds(0)
        remainingTimeWhenNotRunning = 0
        presentationMode = .alerting
        alertStartedAt = now()
        activityHandler?.update(for: self)
        onDidFinish?()
    }

    #warning("Fix this")
    private func stopInternal() {
        status = .idle
        stopUnderlyingTimer()
        endDate = nil
        presentationMode = .normal
        alertStartedAt = nil
        activityHandler?.end()
    }

    private func startUnderlyingTimer() {
        stopUnderlyingTimer()

        timer = makeRepeatingTimer(0.10) { [weak self] in
            self?.tick()
        }
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
