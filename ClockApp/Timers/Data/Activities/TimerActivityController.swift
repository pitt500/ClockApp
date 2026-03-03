//
//  TimerActivityController.swift
//  ClockApp
//
//  Created by Pedro Rojas on 03/03/26.
//


import SwiftUI
import ActivityKit

@Observable
final class TimerActivityController: TimerActivityHandling {
    private var activity: Activity<TimerAttributes>?
    private var totalTime: Duration = .seconds(0)

    func start(for manager: TimerManager, title: String = "Timer Demo") {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        totalTime = manager.totalTimeInSeconds
        
        let attributes = TimerAttributes(title: title)
        let contentState = TimerAttributes.ContentState(
            remainingTime: manager.remainingTimeInSeconds,
            totalTime: manager.totalTimeInSeconds,
            isPaused: false
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(
                    state: contentState,
                    staleDate: nil // Tells the system when your content becomes outdated.
                ),
                pushType: nil, // local-only
            )
        } catch {
            print("Failed to start activity: \(error)")
        }
    }

    func update(remainingTime: Duration, isPaused: Bool) {
        guard let activity else { return }

        let contentState = TimerAttributes.ContentState(
            remainingTime: remainingTime,
            totalTime: totalTime,
            isPaused: isPaused
        )

        Task {
            await activity.update(.init(state: contentState, staleDate: nil))
        }
    }

    func end() {
        guard let activity else { return }
        
        let contentState = TimerAttributes.ContentState(
            remainingTime: .seconds(0),
            totalTime: totalTime,
            isPaused: true
        )
        
        Task {
            await activity.end(.init(state: contentState, staleDate: nil), dismissalPolicy: .immediate)
        }
        self.activity = nil
    }
}

