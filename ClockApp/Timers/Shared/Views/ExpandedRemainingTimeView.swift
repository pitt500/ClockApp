//
//  ExpandedRemainingTimeView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 28/03/26.
//

import SwiftUI

struct ExpandedRemainingTimeView: View {
    let state: TimerAttributes.ContentState
    
    var body: some View {
        if state.runningTimeInterval != nil {
            remainingTimeView
                .font(.body.scaled(by: 3.0))
                .monospacedDigit()
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .foregroundStyle(.orange)
                .multilineTextAlignment(.trailing)
                .frame(maxHeight: .infinity, alignment: .center)
        } else {
            Text(formattedPausedTime)
                .font(.body.scaled(by: 3.0))
                .monospacedDigit()
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .foregroundStyle(.orange)
                .multilineTextAlignment(.trailing)
                .frame(maxHeight: .infinity, alignment: .center)
        }
    }
    
    @ViewBuilder
    private var remainingTimeView: some View {
        if let timerInterval = state.runningTimeInterval {
            Text(
                timerInterval: timerInterval,
                pauseTime: nil,
                countsDown: true,
                showsHours: showsHours
            )
        } else {
            Text(formattedPausedTime)
        }
    }
    
    private var showsHours: Bool {
        let seconds = Int(max(0, state.totalTimeInterval))
        return seconds >= 3600
    }

    private var formattedPausedTime: String {
        LiveActivityTimerFormatting.formattedDisplayTime(state.displayedRemainingTime)
    }
}

#Preview {
    ExpandedRemainingTimeView(
        state: .init(
            status: .running,
            totalTimeInterval: 300.5,
            endDate: Date.now.addingTimeInterval(245),
            remainingWhenNotRunning: 0,
            displayedRemainingTime: .seconds(245),
            presentationMode: .normal
        )
    )
}
