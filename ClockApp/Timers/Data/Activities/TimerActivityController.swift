//
//  TimerActivityController.swift
//  ClockApp
//
//  Created by Pedro Rojas on 03/03/26.
//


import ActivityKit
import Foundation

final class TimerActivityController: TimerActivityHandling {
    private var activity: Activity<TimerAttributes>?
    private var label: String = ""

    func start(for manager: TimerManager, title: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }

        let attributes = TimerAttributes(title: title)
        let state = makeState(from: manager)

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Failed to start activity: \(error)")
        }
    }

    func update(for manager: TimerManager) {
        guard let activity else { return }
        let state = makeState(from: manager)

        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    func end() {
        guard let activity else { return }

        Task {
            await activity.end(
                .init(state: activity.content.state, staleDate: nil),
                dismissalPolicy: .immediate
            )
            self.activity = nil
        }
    }

    private func makeState(from manager: TimerManager) -> TimerAttributes.ContentState {
        let now = Date.now
        let remaining = manager.remainingInterval(at: now)

        let status: TimerStatus
        switch manager.status {
        case .idle:
            status = .idle
        case .running:
            status = .running
        case .paused:
            status = .paused
        }

        let endDate: Date? = manager.status == .running
            ? now.addingTimeInterval(remaining)
            : nil

        let remainingWhenNotRunning: TimeInterval = manager.status == .running
            ? 0
            : remaining
        

        return .init(
            status: status,
            totalTimeInterval: manager.totalTimeInterval,
            endDate: endDate,
            remainingWhenNotRunning: remainingWhenNotRunning,
            displayedRemainingTime: manager.displayedRemainingTime
        )
    }
}
