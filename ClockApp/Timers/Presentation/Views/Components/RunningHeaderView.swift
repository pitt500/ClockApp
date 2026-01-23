//
//  RunningHeaderView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//


import SwiftUI

struct RunningHeaderView: View {
    let item: TimerItem

    var body: some View {
        VStack(spacing: 16) {
            formattedRemainingTimeText
                .font(.system(size: 64, weight: .light, design: .rounded))

            HStack {
                Button("Cancel") {
                    item.manager.stop()
                }
                .buttonStyle(.bordered)
                .tint(.gray)

                Spacer()

                Button(actionTitle) {
                    switch item.manager.status {
                    case .running: item.manager.pause()
                    case .paused: item.manager.resume()
                    case .idle: break
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(item.manager.status == .idle)
            }
        }
        .padding(.horizontal, 16)
    }

    private var formattedRemainingTimeText: Text {
        Text(item.manager.remainingTime, format: .time(pattern: .minuteSecond))
            .monospacedDigit()
    }

    private var actionTitle: String {
        switch item.manager.status {
        case .running: return "Pause"
        case .paused: return "Resume"
        case .idle: return "Start"
        }
    }
}
