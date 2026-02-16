//
//  RootView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 15/02/26.
//


import SwiftUI

struct RootView: View {
    @State private var selectedTab: TabTag = .timers
    
    enum TabTag: String {
        case worldClock
        case alarms
        case stopwatch
        case timers
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(
                "World Clock",
                systemImage: "globe",
                value: .worldClock
            ) {
                WorldClockPlaceholderView()
            }
            
            Tab(
                "Alarms",
                systemImage: "alarm",
                value: .alarms
            ) {
                AlarmsPlaceholderView()
            }
            
            Tab(
                "Stopwatch",
                systemImage: "stopwatch",
                value: .stopwatch
            ) {
                StopwatchPlaceholderView()
            }

            Tab(
                "Timers",
                systemImage: "timer",
                value: .timers
            ) {
                TimersScreen()
            }
        }
        .tint(.orange)
    }
}

// MARK: - Placeholders

struct WorldClockPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("World Clock", systemImage: "globe", description: Text("Placeholder"))
                .navigationTitle("World Clock")
        }
    }
}

struct AlarmsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Alarms", systemImage: "alarm", description: Text("Placeholder"))
                .navigationTitle("Alarms")
        }
    }
}

struct StopwatchPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Stopwatch", systemImage: "stopwatch", description: Text("Placeholder"))
                .navigationTitle("Stopwatch")
        }
    }
}
