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
        ZStack {
            // Background
            Circle()
                .stroke(Color.orange.opacity(0.25), lineWidth: 2)
            
            // Progress
            Circle()
                .trim(from: 0, to: 1 - state.progress)
                .stroke(
                    .orange,
                    style: StrokeStyle(
                        lineWidth: 2,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                
            // Play/Pause Icon
            Image(
                systemName: state.isPaused ? "pause.fill" : "play.fill"
            )
            .font(.system(size: 8))
            .foregroundColor(.orange)
        }
        .frame(width: 16, height: 16)
        .padding(2)
    }
}

#Preview {
    MinimalTimerLiveActivityView(
        state: .init(
            remainingTime: .seconds(27),
            totalTime: .seconds(30),
            isPaused: true
        )
    )
    .frame(width: 100, height: 100)
}
