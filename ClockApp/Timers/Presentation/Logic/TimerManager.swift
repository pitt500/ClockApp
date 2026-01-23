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
    var totalTime: Duration = .seconds(0)
    var remainingTime: Duration = .seconds(0)

    private var timer: Timer?
    private let activityHandler: TimerActivityHandling?

    // Event: fired when the timer reaches 0.
    // The manager does not know about UI or the store. It only notifies.
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

    func stop() {
        status = .idle
        timer?.invalidate()
        timer = nil
        totalTime = .seconds(0)
        remainingTime = .seconds(0)
        activityHandler?.end()
    }

    // MARK: - Private

    private func tick() async {
        guard status == .running else { return }

        if remainingTime > .seconds(0) {
            remainingTime -= .seconds(1)
            activityHandler?.update(remainingTime: remainingTime, isPaused: false)
        } else {
            stop()
            onDidFinish?()
        }
    }

    private func startUnderlyingTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { await self.tick() }
        }

        // RunLoop anchor for your RunLoop video: using .common keeps it running
        // during common UI interactions.
        RunLoop.current.add(timer!, forMode: .common)
    }

    deinit {
        timer?.invalidate()
    }
}
