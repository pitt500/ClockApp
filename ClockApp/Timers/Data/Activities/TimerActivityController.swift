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

        Task {
            await activity.update(content)
        }
    }

    func showAlert(title: String) {
        guard let activity else { return }

        let state = makeAlertState(from: activity, title: title)
        let content = ActivityContent(
            state: state,
            staleDate: nil,
            relevanceScore: 1_000
        )

        Task {
            await activity.update(
                content,
                alertConfiguration: .init(
                    title: .init(stringLiteral: title),
                    body: "",
                    sound: .default
                )
            )
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
            self.relevanceScore = 0
        }
    }

    #warning("Crear dos estados diferentes para cuando esté corriendo y cuando esté detenido")
    private func makeNormalState(from manager: TimerManager) -> TimerAttributes.ContentState {
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
            displayedRemainingTime: manager.displayedRemainingTime,
            presentationMode: .normal
        )
    }

    private func makeAlertState(from activity: Activity<TimerAttributes>, title: String) -> TimerAttributes.ContentState {
        .init(
            status: .idle,
            totalTimeInterval: activity.content.state.totalTimeInterval,
            endDate: nil,
            remainingWhenNotRunning: 0,
            displayedRemainingTime: .seconds(0),
            presentationMode: .alerting
        )
    }
}
