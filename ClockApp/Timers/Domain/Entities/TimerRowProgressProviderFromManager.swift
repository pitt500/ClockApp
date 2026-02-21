//
//  TimerRowProgressProviderFromManager.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/02/26.
//


import Foundation

final class TimerRowProgressProviderFromManager: TimerProgressProviding {
    private let item: TimerItem

    init(item: TimerItem) {
        self.item = item
    }

    func progress(at date: Date) -> Double {
        let total = max(1.0, item.manager.totalTimeInterval)
        let remaining = item.manager.remainingInterval(at: date)
        return remaining / total
    }
}
