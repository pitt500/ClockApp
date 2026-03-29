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
    private var relevanceScore: Double = 0

    func start(for manager: TimerManager, title: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }

        let attributes = TimerAttributes(title: title.isEmpty ? "Timer" : title)
        let state = makeNormalState(from: manager)
        let content = ActivityContent(
            state: state,
            staleDate: nil,
            relevanceScore: relevanceScore
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("Failed to start activity: \(error)")
        }
    }

    func update(for manager: TimerManager, relevanceScore: Double?) {
        if let relevanceScore {
            self.relevanceScore = relevanceScore
        }

        guard let activity else { return }

        let state = makeNormalState(from: manager)
        let content = ActivityContent(
            state: state,
            staleDate: nil,
            relevanceScore: self.relevanceScore
        )

        Task { [activity, content] in
            await Self.update(activity: activity, content: content)
        }
    }

    func showAlert(title: String, soundName: String?) {
        guard let activity else { return }

        let state = makeAlertState(from: activity)
        let content = ActivityContent(
            state: state,
            staleDate: nil,
            relevanceScore: 1_000
        )

        let sound: AlertConfiguration.AlertSound = if let soundName {
            .named(soundName)
        } else {
            .default
        }

        Task { [activity, content, title, sound] in
            await Self.update(
                activity: activity,
                content: content,
                title: title,
                sound: sound
            )
        }
    }

    func end() {
        guard let activity else { return }
        let state = activity.content.state

        Task { [activity, state] in
            await Self.end(activity: activity, state: state)
            self.activity = nil
            self.relevanceScore = 0
        }
    }

    private func makeNormalState(from manager: TimerManager) -> TimerAttributes.ContentState {
        let now = Date.now
        let remaining = manager.remainingInterval(at: now)
        
        let status = timerStatus(from: manager)
        let endDate: Date? = manager.status == .running
        ? now.addingTimeInterval(remaining)
        : nil
        
        let remainingWhenNotRunning: TimeInterval = manager.status == .running
        ? 0
        : remaining
        
        return makeState(
            status: status,
            totalTimeInterval: manager.totalTimeInterval,
            endDate: endDate,
            remainingWhenNotRunning: remainingWhenNotRunning,
            displayedRemainingTime: manager.displayedRemainingTime,
            presentationMode: .normal
        )
    }
    
    private func makeAlertState(from activity: Activity<TimerAttributes>) -> TimerAttributes.ContentState {
        makeState(
            status: .idle,
            totalTimeInterval: activity.content.state.totalTimeInterval,
            endDate: nil,
            remainingWhenNotRunning: 0,
            displayedRemainingTime: .seconds(0),
            presentationMode: .alerting
        )
    }
    
    private func makeState(
        status: TimerStatus,
        totalTimeInterval: TimeInterval,
        endDate: Date?,
        remainingWhenNotRunning: TimeInterval,
        displayedRemainingTime: Duration,
        presentationMode: TimerPresentationMode
    ) -> TimerAttributes.ContentState {
        .init(
            status: status,
            totalTimeInterval: totalTimeInterval,
            endDate: endDate,
            remainingWhenNotRunning: remainingWhenNotRunning,
            displayedRemainingTime: displayedRemainingTime,
            presentationMode: presentationMode
        )
    }
    
    private func timerStatus(from manager: TimerManager) -> TimerStatus {
        switch manager.status {
        case .idle:
            return .idle
        case .running:
            return .running
        case .paused:
            return .paused
        }
    }

    // Swift 6 strict concurrency requires explicit transfer when using Activity in Task closures;
    // these static helpers isolate the async calls and accept `sending` parameters to avoid
    // data-race diagnostics without changing runtime behavior.
    private static func update(
        activity: sending Activity<TimerAttributes>,
        content: ActivityContent<TimerAttributes.ContentState>
    ) async {
        await activity.update(content)
    }

    private static func update(
        activity: sending Activity<TimerAttributes>,
        content: ActivityContent<TimerAttributes.ContentState>,
        title: String,
        sound: AlertConfiguration.AlertSound
    ) async {
        await activity.update(
            content,
            alertConfiguration: .init(
                title: .init(stringLiteral: title),
                body: "",
                sound: sound
            )
        )
    }

    private static func end(
        activity: sending Activity<TimerAttributes>,
        state: TimerAttributes.ContentState
    ) async {
        await activity.end(
            .init(state: state, staleDate: nil),
            dismissalPolicy: .immediate
        )
    }
}
