//
//  ClockAppTests.swift
//  ClockAppTests
//
//  Created by Pedro Rojas on 09/02/26.
//

import Foundation
import Testing
@testable import ClockApp

@Suite
@MainActor
struct TimerManagerTests {

    // MARK: - Helpers

    private func sleep(for duration: Duration) async {
        try? await Task.sleep(for: duration)
    }

    // MARK: - Tests

    @Test
    func `Set timer starts running and label shows preset value`() async {
        let manager = TimerManager()
        manager.setTimer(totalTime: .seconds(5))

        #expect(manager.status == .running)
        #expect(manager.remainingTimeInSeconds == .seconds(5))
    }

    @Test
    func `Pause captures remaining time and stops ticking`() async {
        let manager = TimerManager()
        manager.setTimer(totalTime: .seconds(3))

        await sleep(for: .seconds(1.2))

        manager.pause()
        let frozen = manager.remainingTimeInSeconds

        await sleep(for: .seconds(1.5))

        #expect(manager.status == .paused)
        #expect(manager.remainingTimeInSeconds == frozen)
    }

    @Test
    func `Resume continues countdown from paused value`() async {
        let manager = TimerManager()
        manager.setTimer(totalTime: .seconds(3))

        await sleep(for: .seconds(1.0))
        manager.pause()
        let pausedValue = manager.remainingTimeInSeconds

        await sleep(for: .seconds(1.0))
        manager.resume()

        await sleep(for: .seconds(1.0))

        #expect(manager.status == .running)
        #expect(manager.remainingTimeInSeconds < pausedValue)
    }

    @Test
    func `Cancel resets timer without firing finish callback`() async {
        let manager = TimerManager()

        var didFinish = false
        manager.onDidFinish = { didFinish = true }

        manager.setTimer(totalTime: .seconds(3))
        await sleep(for: .seconds(1.0))

        manager.cancel()

        #expect(manager.status == .idle)
        #expect(manager.remainingTimeInSeconds == .seconds(3))

        // Give time for any accidental finish callback.
        await sleep(for: .seconds(1.0))
        #expect(didFinish == false)
    }

    @Test
    func `Timer finishing naturally fires finish callback and ends idle`() async {
        let manager = TimerManager()

        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            manager.onDidFinish = {
                cont.resume()
            }

            manager.setTimer(totalTime: .seconds(1))
        }

        #expect(manager.status == .idle)
        #expect(manager.remainingTimeInSeconds == .seconds(0))
    }

    @Test
    func `Label reaches zero before finish due to grace period`() async {
        let manager = TimerManager()
        manager.setTimer(totalTime: .seconds(1))

        // After ~1s the label should be zero, but grace has not ended yet.
        await sleep(for: .seconds(1.1))

        #expect(manager.remainingTimeInSeconds == .seconds(0))
        #expect(manager.status == .running)
    }

    @Test
    func `Remaining interval decreases when evaluated at a later date`() async {
        let manager = TimerManager()
        manager.setTimer(totalTime: .seconds(5))

        let now = Date.now
        let future = now.addingTimeInterval(2.0)

        let remainingAtNow = manager.remainingInterval(at: now)
        let remainingAtFuture = manager.remainingInterval(at: future)

        #expect(remainingAtNow > remainingAtFuture)
    }
}
