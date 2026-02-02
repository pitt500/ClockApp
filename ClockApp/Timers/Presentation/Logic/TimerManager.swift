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

    // When running, this marks the expected end time.
    private(set) var endDate: Date?

    private var timer: Timer?
    private let activityHandler: TimerActivityHandling?

    // Fired only when the timer reaches 0 naturally.
    var onDidFinish: (() -> Void)?

    init(activityHandler: TimerActivityHandling? = nil) {
        self.activityHandler = activityHandler
    }

    // MARK: - Public API

    func setTimer(totalTime: Duration) {
        self.totalTime = totalTime
        self.remainingTime = totalTime
        start()
    }

    func start() {
        guard remainingTime > .seconds(0) else { return }

        status = .running
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))

        activityHandler?.start(for: self, title: "Timer Demo")
        startUnderlyingTimer()
    }

    func pause() {
        guard status == .running else { return }

        // Freeze remainingTime based on endDate.
        let secondsLeft = max(0, Int(ceil((endDate ?? Date()).timeIntervalSinceNow)))
        remainingTime = .seconds(secondsLeft)

        status = .paused
        endDate = nil

        timer?.invalidate()
        activityHandler?.update(remainingTime: remainingTime, isPaused: true)
    }

    func resume() {
        guard remainingTime > .seconds(0) else { return }

        status = .running
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))

        activityHandler?.update(remainingTime: remainingTime, isPaused: false)
        startUnderlyingTimer()
    }

    // User-driven stop. Does NOT fire onDidFinish.
    // Requirement: when idle after cancel, the row should show the original preset.
    func cancel() {
        stopInternal(resetRemainingToTotal: true)
    }

    // Called by the Store after it has moved the timer to Recents.
    func resetToTotalTime() {
        remainingTime = totalTime
    }

    // MARK: - Private

    private var remainingSeconds: Int {
        max(0, Int(remainingTime.components.seconds))
    }

    private func finishNaturally() {
        // Stop the underlying timer and show 0 as a stable UI state.
        stopInternal(resetRemainingToTotal: false)
        remainingTime = .seconds(0)

        onDidFinish?()
    }

    private func stopInternal(resetRemainingToTotal: Bool) {
        status = .idle
        timer?.invalidate()
        timer = nil

        endDate = nil

        if resetRemainingToTotal {
            remainingTime = totalTime
        }

        activityHandler?.end()
    }

    private func tick() async {
        guard status == .running else { return }
        guard let endDate else { return }

        let secondsLeft = max(0, Int(ceil(endDate.timeIntervalSinceNow)))

        if secondsLeft > 0 {
            remainingTime = .seconds(secondsLeft)
            activityHandler?.update(remainingTime: remainingTime, isPaused: false)
        } else {
            // The moment we cross 0, finish naturally and keep remainingTime at 0 briefly.
            finishNaturally()
        }
    }

    private func startUnderlyingTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { await self.tick() }
        }

        // RunLoop anchor for the RunLoop explanation video.
        RunLoop.current.add(timer!, forMode: .common)
    }

    deinit {
        timer?.invalidate()
    }
}
