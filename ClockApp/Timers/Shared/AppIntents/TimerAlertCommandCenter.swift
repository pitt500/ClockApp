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

final class TimerAlertCommandCenter {
    static let shared = TimerAlertCommandCenter()

    weak var handler: TimerAlertCommandHandling?

    private init() {}

    func dismissCurrentAlert() {
        handler?.dismissCurrentTimerAlert()
    }
}

struct DismissTimerAlertIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Dismiss Timer Alert"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        await TimerAlertCommandCenter.shared.dismissCurrentAlert()
        return .result()
    }
}
