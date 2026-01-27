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
    
    var status: Status = .idle
    var totalTime: Duration = .seconds(0)       // Preset duration, always kept
    var remainingTime: Duration = .seconds(0)   // Countdown value

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
        activityHandler?.start(for: self, title: "Timer Demo")
        startUnderlyingTimer()
    }

    func pause() {
        status = .paused
        timer?.invalidate()
        activityHandler?.update(remainingTime: remainingTime, isPaused: true)
    }

    func resume() {
        guard remainingTime > .seconds(0) else { return }
        status = .running
        activityHandler?.update(remainingTime: remainingTime, isPaused: false)
        startUnderlyingTimer()
    }

    // User-driven stop. Does NOT fire onDidFinish.
    func cancel() {
        stopInternal()
    }

    // MARK: - Private

    private func finishNaturally() {
        stopInternal()
        onDidFinish?()
    }

    private func stopInternal() {
        status = .idle
        timer?.invalidate()
        timer = nil

        // Key requirement:
        // After cancel/finish we want the row to show the original preset.
        remainingTime = totalTime

        activityHandler?.end()
    }

    private func tick() async {
        guard status == .running else { return }

        if remainingTime > .seconds(1) {
            remainingTime -= .seconds(1)
            activityHandler?.update(remainingTime: remainingTime, isPaused: false)
        } else {
            // last second: finish now
            remainingTime = .seconds(0)
            finishNaturally()
        }
    }

    private func startUnderlyingTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { await self.tick() }
        }

        // RunLoop anchor for the RunLoop video.
        RunLoop.current.add(timer!, forMode: .common)
    }

    deinit {
        timer?.invalidate()
    }
}
