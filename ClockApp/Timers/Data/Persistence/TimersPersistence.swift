//
//  TimersPersistence.swift
//  ClockApp
//
//  Created by Pedro Rojas on 23/02/26.
//


import Foundation

protocol TimersPersistence: Sendable {
    func loadRecentTimers() async throws -> [TimerItem]
    func saveRecentTimers(_ timers: [TimerItem]) async throws
}
