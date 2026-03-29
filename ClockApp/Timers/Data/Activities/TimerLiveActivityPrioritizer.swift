//
//  TimerLiveActivityPrioritizer.swift
//  ClockApp
//
//  Created by Pedro Rojas on 22/03/26.
//

import Foundation

protocol TimerLiveActivityPrioritizing {
    func highestPriorityTimer(from activeTimers: [TimerItem], at date: Date) -> TimerItem?
    func reconcile(activeTimers: [TimerItem], at date: Date)
}

final class TimerLiveActivityPrioritizer: TimerLiveActivityPrioritizing {
    private func prioritizedTimers(
        from activeTimers: [TimerItem],
        at date: Date
    ) -> (running: [TimerItem], paused: [TimerItem]) {
        let runningTimers = activeTimers
            .filter { $0.manager.status == .running }
            .sorted {
                $0.manager.remainingInterval(at: date) < $1.manager.remainingInterval(at: date)
            }

        let pausedTimers = activeTimers
            .filter { $0.manager.status == .paused }
            .sorted {
                $0.manager.remainingInterval(at: date) < $1.manager.remainingInterval(at: date)
            }

        return (runningTimers, pausedTimers)
    }
    
    func highestPriorityTimer(from activeTimers: [TimerItem], at date: Date = .now) -> TimerItem? {
        let timers = prioritizedTimers(from: activeTimers, at: date)

        if let firstRunning = timers.running.first {
            return firstRunning
        }

        return timers.paused.first
    }
    
    func reconcile(activeTimers: [TimerItem], at date: Date = .now) {
        let timers = prioritizedTimers(from: activeTimers, at: date)

        if !timers.running.isEmpty {
            applyRelevanceScores(to: timers.running, topScore: 100, decrement: 1)
            applyRelevanceScores(to: timers.paused, topScore: 10, decrement: 1)
        } else {
            applyRelevanceScores(to: timers.paused, topScore: 100, decrement: 1)
        }

        let prioritizedIDs = Set(timers.running.map(\.id) + timers.paused.map(\.id))

        for item in activeTimers where !prioritizedIDs.contains(item.id) {
            item.manager.refreshLiveActivity(relevanceScore: 0)
        }
    }

    private func applyRelevanceScores(
        to timers: [TimerItem],
        topScore: Double,
        decrement: Double
    ) {
        for (index, item) in timers.enumerated() {
            let score = max(0, topScore - (Double(index) * decrement))
            item.manager.refreshLiveActivity(relevanceScore: score)
        }
    }
}
