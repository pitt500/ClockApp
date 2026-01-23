//
//  TimerActivityHandling.swift
//  ClockApp
//
//  Created by Pedro Rojas on 20/01/26.
//


import SwiftUI

// Abstraction for Live Activity integration (we'll implement it in a future chapter).
protocol TimerActivityHandling {
    func start(for manager: TimerManager, title: String)
    func update(remainingTime: Duration, isPaused: Bool)
    func end()
}
