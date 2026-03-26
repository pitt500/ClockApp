//
//  DynamicIslandCompactLeadingContentView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 26/03/26.
//

import SwiftUI

struct DynamicIslandCompactLeadingContentView: View {
    let state: TimerAttributes.ContentState

    var body: some View {
        if isAlerting {
            Image(systemName: "bell.fill")
                .foregroundStyle(.orange)
        } else {
            MinimalTimerLiveActivityView(state: state)
        }
    }

    private var isAlerting: Bool {
        state.presentationMode == .alerting
    }
}
