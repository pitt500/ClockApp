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
    let alertSoundName: String?
    let manager: TimerManager

    init(
        id: UUID = UUID(),
        label: String,
        configuredDuration: Duration,
        alertSoundName: String? = nil,
        manager: TimerManager
    ) {
        self.id = id
        self.label = label
        self.configuredDuration = configuredDuration
        self.manager = manager
        self.alertSoundName = alertSoundName
    }
}
