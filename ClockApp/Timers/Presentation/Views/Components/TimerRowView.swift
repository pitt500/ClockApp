//
//  TimerRowView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//


import SwiftUI

struct TimerRowView: View {

    enum TrailingAction {
        case pauseResume
        case startPreset
    }

    let item: TimerItem
    let trailingAction: TrailingAction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                remainingTimeText
                    .font(.system(size: 54, weight: .light, design: .rounded))
                    .foregroundStyle(
                        item.manager.status == .idle ? .secondary : .primary
                    )

                configuredDurationText
                    .foregroundStyle(.secondary)
            }

            Spacer()
            trailingButton
        }
        .padding(.vertical, 10)
    }

    private var remainingTimeText: Text {
        Text(item.manager.remainingTime, format: .time(pattern: timePattern))
            .monospacedDigit()
    }

    private var configuredDurationText: Text {
        Text(
            item.configuredDuration,
            format: .units(
                allowed: [.hours, .minutes, .seconds],
                width: .wide
            )
        )
    }

    private var timePattern: Duration.TimeFormatStyle.Pattern {
        let seconds = Int(item.manager.totalTime.components.seconds)
        return seconds >= 3600 ? .hourMinuteSecond : .minuteSecond
    }

    @ViewBuilder
    private var trailingButton: some View {
        switch trailingAction {

        case .pauseResume:
            Button {
                switch item.manager.status {
                case .running:
                    item.manager.pause()
                case .paused:
                    item.manager.resume()
                case .idle:
                    break
                }
            } label: {
                Image(systemName: item.manager.status == .running ? "pause.fill" : "play.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 56, height: 56)
                    .background(
                        Circle().fill(Color.orange.opacity(0.22))
                    )
            }
            .buttonStyle(.plain)

        case .startPreset:
            Image(systemName: "play.fill")
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 56, height: 56)
                .foregroundStyle(.green)
                .background(
                    Circle().fill(Color.green.opacity(0.22))
                )
        }
    }
}
