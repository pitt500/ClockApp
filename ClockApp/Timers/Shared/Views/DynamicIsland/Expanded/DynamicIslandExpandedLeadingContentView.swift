//
//  DynamicIslandExpandedLeadingContentView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 26/03/26.
//

import SwiftUI
import AppIntents

struct DynamicIslandExpandedLeadingContentView: View {
    let state: TimerAttributes.ContentState
    let title: String

    var body: some View {
        if isAlerting {
            Text(title)
                .font(.body.scaled(by: 1.8).bold())
                .foregroundStyle(.orange)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        } else {
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
    }

    private var isPaused: Bool {
        state.status == .paused
    }

    private var isAlerting: Bool {
        state.presentationMode == .alerting
    }
}
