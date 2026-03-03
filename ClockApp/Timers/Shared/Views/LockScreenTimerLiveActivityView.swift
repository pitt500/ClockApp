//
//  LockScreenTimerLiveActivityView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 03/03/26.
//


import SwiftUI
import WidgetKit

struct LockScreenTimerLiveActivityView: View {
    let state: TimerAttributes.ContentState
    
    var body: some View {
        VStack {
            Text("\(state.remainingTime.components.seconds) seconds")
        }
        .activityBackgroundTint(Color.cyan)
        .activitySystemActionForegroundColor(Color.black)
    }
}
