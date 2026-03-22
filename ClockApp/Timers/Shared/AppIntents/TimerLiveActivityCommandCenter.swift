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
    static var title: LocalizedStringResource = "Pause or Resume Timer"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        await TimerLiveActivityCommandCenter.shared.toggleCurrentTimer()
        return .result()
    }
}

struct CancelTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Cancel Timer"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        await TimerLiveActivityCommandCenter.shared.cancelCurrentTimer()
        return .result()
    }
}
