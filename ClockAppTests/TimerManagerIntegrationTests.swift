//
//  TimerManagerIntegrationTests.swift
//  ClockAppTests
//
//  Created by Pedro Rojas on 11/02/26.
//

import Foundation
import Testing
@testable import ClockApp

@Suite(.tags(.integration))
@MainActor
struct TimerManagerIntegrationTests {

    private func sleep(for duration: Duration) async {
        try? await Task.sleep(for: duration)
    }

    @Test
    func `Timer ticks on the main RunLoop and label changes over time`() async {
        let manager = TimerManager(label: "Test")
        manager.setTimer(totalTime: .seconds(3))

        #expect(manager.status == .running)
        let initial = manager.remainingTimeInSeconds

        // Wait long enough for at least one second-boundary update.
        await sleep(for: .seconds(1.2))

        let later = manager.remainingTimeInSeconds
        #expect(later < initial)
    }

    @Test
    func `Timer finishes naturally and fires onDidFinish using real time`() async {
        let manager = TimerManager(label: "Test")

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
    func `Cancelling a running timer stops ticking and does not fire finish`() async {
        let manager = TimerManager(label: "Test")

        var didFinish = false
        manager.onDidFinish = {
            didFinish = true
        }

        manager.setTimer(totalTime: .seconds(3))

        #expect(manager.status == .running)

        // Let it tick at least once
        try? await Task.sleep(for: .seconds(1.2))

        manager.cancel()

        #expect(manager.status == .idle)
        #expect(manager.remainingTimeInSeconds == .seconds(3))

        // Wait longer than the original duration + grace
        try? await Task.sleep(for: .seconds(2.5))

        // It should not restart or finish
        #expect(manager.status == .idle)
        #expect(manager.remainingTimeInSeconds == .seconds(3))
        #expect(didFinish == false)
    }

}

extension Tag {
  @Tag static var integration: Self
}
