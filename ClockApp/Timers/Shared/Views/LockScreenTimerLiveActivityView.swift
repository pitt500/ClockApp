//
//  LockScreenTimerLiveActivityView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 03/03/26.
//


import SwiftUI

struct LockScreenTimerLiveActivityView: View {
    let state: TimerAttributes.ContentState
    let title: String

    var body: some View {
        HStack {
            DynamicIslandExpandedLeadingContentView(
                state: state,
                title: title
            )

            DynamicIslandExpandedCenterContentView(
                state: state,
                title: title
            )
            .frame(maxWidth: .infinity, alignment: .trailing)

            DynamicIslandExpandedTrailingContentView(state: state)
        }
        .padding()
        .background(Color.black)
    }
}

#Preview("Running") {
    LockScreenTimerLiveActivityView(
        state: .init(
            status: .running,
            totalTimeInterval: 300.5,
            endDate: Date.now.addingTimeInterval(245),
            remainingWhenNotRunning: 0,
            displayedRemainingTime: .seconds(245),
            presentationMode: .normal
        ), 
        title: "Tea"
    )
}

#Preview("Paused") {
    LockScreenTimerLiveActivityView(
        state: .init(
            status: .paused,
            totalTimeInterval: 300.5,
            endDate: nil,
            remainingWhenNotRunning: 125,
            displayedRemainingTime: .seconds(125),
            presentationMode: .normal
        ), 
        title: "Workout"
    )
}

#Preview("Alerting") {
    LockScreenTimerLiveActivityView(
        state: .init(
            status: .idle,
            totalTimeInterval: 300.5,
            endDate: nil,
            remainingWhenNotRunning: 0,
            displayedRemainingTime: .seconds(0),
            presentationMode: .alerting
        ), 
        title: "Pasta"
    )
}
