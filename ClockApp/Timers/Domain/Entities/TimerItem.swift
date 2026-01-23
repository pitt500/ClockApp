//
//  TimerItem.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//


import Foundation

// Represents a timer entry shown in the UI (Focused or Recents).
// It keeps the original configured duration so presets persist.
struct TimerItem: Identifiable {
    let id: UUID
    var label: String
    let configuredDuration: Duration
    let manager: TimerManager

    init(label: String, configuredDuration: Duration, manager: TimerManager) {
        self.id = UUID()
        self.label = label
        self.configuredDuration = configuredDuration
        self.manager = manager
    }
}
