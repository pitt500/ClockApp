//
//  CompactRemainingTime.swift
//  ClockApp
//
//  Created by Pedro Rojas on 28/03/26.
//

import SwiftUI

struct CompactRemainingTime: View {
    let state: TimerAttributes.ContentState
    
    var body: some View {
        let placeholder = placeholderFormat

        if let timerInterval = state.runningTimeInterval {
            Text(placeholder)
                .hidden()
                .overlay(alignment: .leading) {
                    Text(
                        timerInterval: timerInterval,
                        pauseTime: nil,
                        countsDown: true,
                        showsHours: showsHours
                    )
                    .monospacedDigit()
                    .lineLimit(1)
                }
        } else {
            Text(placeholder)
                .hidden()
                .overlay(alignment: .leading) {
                    Text(formattedPausedTime)
                        .monospacedDigit()
                        .lineLimit(1)
                }
        }
    }

    private var isAlerting: Bool {
        state.presentationMode == .alerting
    }

    /*
     This placeholder is required because Text(timerInterval:) expands to the maximum possible width of its content in the Dynamic Island, causing layout issues. By providing a fixed-width placeholder (e.g. "00:00" or "00:00:00") and overlaying the real timer on top, we ensure the layout remains stable and only occupies the necessary space.
    */
    private var placeholderFormat: String {
        showsHours ? "00:00:00" : "00:00"
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
    CompactRemainingTime(
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
