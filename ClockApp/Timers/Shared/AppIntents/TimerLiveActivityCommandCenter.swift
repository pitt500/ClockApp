//
//  TimerLiveActivityCommands.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/03/26.
//

import AppIntents
import Foundation

protocol TimerLiveActivityCommandHandling: AnyObject {
    func toggleCurrentLiveActivityTimer()
    func cancelCurrentLiveActivityTimer()
}

@MainActor
final class TimerLiveActivityCommandCenter {
    static let shared = TimerLiveActivityCommandCenter()

    weak var handler: TimerLiveActivityCommandHandling?

    private init() {}

    func toggleCurrentTimer() {
        handler?.toggleCurrentLiveActivityTimer()
    }

    func cancelCurrentTimer() {
        handler?.cancelCurrentLiveActivityTimer()
    }
}

struct PauseOrResumeTimerIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Pause or Resume Timer"

    func perform() async throws -> some IntentResult {
        await TimerLiveActivityCommandCenter.shared.toggleCurrentTimer()
        return .result()
    }
}

struct CancelTimerIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Cancel Timer"

    func perform() async throws -> some IntentResult {
        await TimerLiveActivityCommandCenter.shared.cancelCurrentTimer()
        return .result()
    }
}
