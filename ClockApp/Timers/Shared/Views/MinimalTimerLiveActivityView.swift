//
//  MinimalTimerLiveActivityView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 03/03/26.
//


import SwiftUI
import WidgetKit

struct MinimalTimerLiveActivityView: View {
    let state: TimerAttributes.ContentState
    
    var body: some View {
        let provider = TimerLiveActivityProgressProvider(state: state)

        TimelineView(.animation) { timeline in
            TimerProgressRing(
                style: .liveActivity,
                progress: { _ in provider.progress(at: timeline.date) }
            )
        }
    }
}

#Preview {
    MinimalTimerLiveActivityView(
        state: .init(
            status: .running,
            totalTimeInterval: 30.5,
            endDate: Date.now.addingTimeInterval(25),
            remainingWhenNotRunning: 0,
            label: "Preview"
        )
    )
    .frame(width: 100, height: 100)
}
