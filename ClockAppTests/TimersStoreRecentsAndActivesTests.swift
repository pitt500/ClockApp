//
//  TimersStoreRecentsAndActivesTests.swift
//  ClockApp
//
//  Created by Pedro Rojas on 14/02/26.
//


import Foundation
import Testing
@testable import ClockApp

@Suite
@MainActor
struct TimersStoreRecentsAndActivesTests {

    @Test
    func `Starting from draft adds a preset to recents and creates one active timer`() {
        let store = TimersStore()

        store.draft = .init(hours: 0, minutes: 0, seconds: 10)
        store.startFromDraft()

        #expect(store.recentTimers.count == 1)
        #expect(store.activeTimers.count == 1)

        let recentSeconds = Int(store.recentTimers[0].configuredDuration.components.seconds)
        let activeSeconds = Int(store.activeTimers[0].configuredDuration.components.seconds)

        #expect(recentSeconds == 10)
        #expect(activeSeconds == 10)
    }

    @Test
    func `Starting the same duration twice does not duplicate recents but creates another active timer`() {
        let store = TimersStore()

        store.draft = .init(hours: 0, minutes: 0, seconds: 10)
        store.startFromDraft()

        store.draft = .init(hours: 0, minutes: 0, seconds: 10)
        store.startFromDraft()

        #expect(store.recentTimers.count == 1)
        #expect(store.activeTimers.count == 2)

        let recentSeconds = Int(store.recentTimers[0].configuredDuration.components.seconds)
        #expect(recentSeconds == 10)

        let activeSeconds = store.activeTimers.map { Int($0.configuredDuration.components.seconds) }
        #expect(activeSeconds.allSatisfy { $0 == 10 })
    }

    @Test
    func `Starting a different duration adds a second preset to recents`() {
        let store = TimersStore()

        store.draft = .init(hours: 0, minutes: 0, seconds: 10)
        store.startFromDraft()

        store.draft = .init(hours: 0, minutes: 0, seconds: 12)
        store.startFromDraft()

        #expect(store.recentTimers.count == 2)
        #expect(store.activeTimers.count == 2)

        // New presets are inserted at the end
        let topRecentSeconds = Int(store.recentTimers[0].configuredDuration.components.seconds)
        let secondRecentSeconds = Int(store.recentTimers[1].configuredDuration.components.seconds)

        #expect(topRecentSeconds == 10)
        #expect(secondRecentSeconds == 12)
    }

    @Test
    func `Starting a recent preset creates a new active timer while keeping the preset in recents`() {
        let store = TimersStore()

        store.draft = .init(hours: 0, minutes: 0, seconds: 10)
        store.startFromDraft()

        // Remove the active instance to isolate this test.
        let firstActive = store.activeTimers[0]
        store.cancel(firstActive)

        #expect(store.activeTimers.count == 0)
        #expect(store.recentTimers.count == 1)

        let preset = store.recentTimers[0]
        store.activate(preset)

        #expect(store.recentTimers.count == 1)
        #expect(store.activeTimers.count == 1)

        let presetSeconds = Int(preset.configuredDuration.components.seconds)
        let activeSeconds = Int(store.activeTimers[0].configuredDuration.components.seconds)

        #expect(presetSeconds == 10)
        #expect(activeSeconds == 10)
    }

    @Test
    func `Starting the same recent preset multiple times creates multiple active timers`() {
        let store = TimersStore()

        store.draft = .init(hours: 0, minutes: 0, seconds: 10)
        store.startFromDraft()

        // Remove the active instance created by draft, we want only activations from recents.
        let firstActive = store.activeTimers[0]
        store.cancel(firstActive)

        let preset = store.recentTimers[0]

        store.activate(preset)
        store.activate(preset)

        #expect(store.recentTimers.count == 1)
        #expect(store.activeTimers.count == 2)

        let activeSeconds = store.activeTimers.map { Int($0.configuredDuration.components.seconds) }
        #expect(activeSeconds.allSatisfy { $0 == 10 })
    }
    
    @Test
    func `Starting same duration with different label adds a second preset to recents`() {
        let store = TimersStore()

        store.draft = .init(hours: 0, minutes: 0, seconds: 10, label: "")
        store.startFromDraft()

        store.draft = .init(hours: 0, minutes: 0, seconds: 10, label: "Alarm")
        store.startFromDraft()

        #expect(store.recentTimers.count == 2)
        #expect(store.activeTimers.count == 2)

        let labels = store.recentTimers.map(\.label)
        #expect(labels.contains(""))
        #expect(labels.contains("Alarm"))
    }

    @Test
    func `Starting same duration with same label does not duplicate recents`() {
        let store = TimersStore()

        store.draft = .init(hours: 0, minutes: 0, seconds: 10, label: "Alarm")
        store.startFromDraft()

        store.draft = .init(hours: 0, minutes: 0, seconds: 10, label: "Alarm")
        store.startFromDraft()

        #expect(store.recentTimers.count == 1)
        #expect(store.activeTimers.count == 2)
    }

}
