//
//  TimerRowView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//


import SwiftUI

struct TimerRowView: View {
    let item: TimerItem
    let isFocused: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                formattedRemainingTimeText
                    .font(.system(size: 38, weight: .light, design: .rounded))

                Text(item.label)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.secondary.opacity(isFocused ? 0.25 : 0.12))
                )
        }
        .padding(.vertical, 6)
    }

    private var formattedRemainingTimeText: Text {
        Text(item.manager.remainingTime, format: .time(pattern: .minuteSecond))
            .monospacedDigit()
    }

    private var iconName: String {
        switch item.manager.status {
        case .running: return "pause.fill"
        case .paused: return "play.fill"
        case .idle: return "arrow.counterclockwise"
        }
    }
}
