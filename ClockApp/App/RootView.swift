//
//  RootView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 15/02/26.
//


import SwiftUI

struct RootView: View {
    @State private var selectedTab: Tab = .timers
    
    enum Tab {
        case worldClock
        case alarms
        case stopwatch
        case timers
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WorldClockPlaceholderView()
                .tabItem {
                    Label("World Clock", systemImage: "globe")
                }
                .tag(Tab.worldClock)

            AlarmsPlaceholderView()
                .tabItem {
                    Label("Alarms", systemImage: "alarm")
                }
                .tag(Tab.alarms)
            
            StopwatchPlaceholderView()
                .tabItem {
                    Label("Stopwatch", systemImage: "stopwatch")
                }
                .tag(Tab.stopwatch)

            TimersScreen()
                .tabItem {
                    Label("Timers", systemImage: "timer")
                }
                .tag(Tab.timers)
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
