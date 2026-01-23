//
//  TimerItem.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//


import Foundation

// UI-friendly representation of a timer in the list.
// It owns a dedicated TimerManager instance so multiple timers can run independently.
struct TimerItem: Identifiable {
    let id: UUID
    var label: String
    let manager: TimerManager

    init(label: String, manager: TimerManager) {
        self.id = UUID()
        self.label = label
        self.manager = manager
    }
}
