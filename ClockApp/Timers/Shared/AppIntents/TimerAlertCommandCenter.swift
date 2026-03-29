//
//  TimerAlertCommandCenter.swift
//  ClockApp
//
//  Created by Pedro Rojas on 23/03/26.
//

import AppIntents
import Foundation

protocol TimerAlertCommandHandling: AnyObject {
    func dismissCurrentTimerAlert()
}

@MainActor
final class TimerAlertCommandCenter {
    static let shared = TimerAlertCommandCenter()

    weak var handler: TimerAlertCommandHandling?

    private init() {}

    func dismissCurrentAlert() {
        handler?.dismissCurrentTimerAlert()
    }
}

struct DismissTimerAlertIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Dismiss Timer Alert"

    func perform() async throws -> some IntentResult {
        await TimerAlertCommandCenter.shared.dismissCurrentAlert()
        return .result()
    }
}
