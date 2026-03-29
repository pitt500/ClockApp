//
//  PauseResumeButtonsView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 28/03/26.
//

import SwiftUI
import AppIntents

struct PauseResumeButtonsView: View {
    let state: TimerAttributes.ContentState
    
    var body: some View {
        HStack(spacing: 12) {
            Button(intent: PauseOrResumeTimerIntent()) {
                TimerControlButton(
                    systemImage: isPaused ? "play.fill" : "pause.fill",
                    style: .primary
                )
            }
            .buttonStyle(.plain)

            Button(intent: CancelTimerIntent()) {
                TimerControlButton(
                    systemImage: "xmark",
                    style: .secondary
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var isPaused: Bool {
        state.status == .paused
    }
}

#Preview {
    PauseResumeButtonsView(
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
