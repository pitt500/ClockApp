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
        self.remainingTime = totalTime
        start()
    }

    func start() {
        guard remainingTime > .seconds(0) else { return }

        status = .running

        recalculateEndDate()

        activityHandler?.start(for: self, title: "Timer Demo")
        startUnderlyingTimer()
    }

    func pause() {
        guard status == .running else { return }

        // Freeze remainingTime using the display time (endDate minus grace).
        let secondsLeft = secondsLeftExcludingGrace(at: Date.now)
        remainingTime = .seconds(secondsLeft)

        status = .paused
        endDate = nil

        timer?.invalidate()
        activityHandler?.update(remainingTime: remainingTime, isPaused: true)
    }

    func resume() {
        guard remainingTime > .seconds(0) else { return }

        status = .running

        recalculateEndDate()

        activityHandler?.update(remainingTime: remainingTime, isPaused: false)
        startUnderlyingTimer()
    }
    
    func recalculateEndDate() {
        let seconds = TimeInterval(remainingSeconds)
        endDate = Date().addingTimeInterval(seconds + finishGrace)
    }

    // User-driven stop. Does NOT fire onDidFinish.
    func cancel() {
        stopInternal()
        resetToTotalTime()
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
        stopInternal()
        remainingTime = .seconds(0)
        onDidFinish?()
    }

    private func stopInternal() {
        status = .idle
        timer?.invalidate()
        timer = nil
        endDate = nil

        activityHandler?.end()
    }

    private func secondsLeftExcludingGrace(at date: Date) -> Int {
        guard let endDate else { return max(0, Int(remainingTime.components.seconds)) }

        // Display countdown ends at (endDate - finishGrace).
        let displayEnd = endDate.addingTimeInterval(-finishGrace)
        let interval = displayEnd.timeIntervalSince(date)

        // Use ceil so the countdown does not skip numbers at the beginning.
        return max(0, Int(ceil(interval)))
    }

    private func tick() async {
        guard status == .running else { return }
        guard let endDate else { return }

        // Update the displayed remainingTime (can be 0 during the grace window).
        let secondsLeft = secondsLeftExcludingGrace(at: Date.now)
        remainingTime = .seconds(secondsLeft)
        activityHandler?.update(remainingTime: remainingTime, isPaused: false)

        // Finish only after the grace window truly ends.
        if Date.now >= endDate {
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
