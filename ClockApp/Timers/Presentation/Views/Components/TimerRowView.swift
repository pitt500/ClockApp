//
//  TimerRowView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//


import SwiftUI

struct TimerRowView: View {
    let item: TimerItem
    let onPrimaryAction: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                mainTimeText
                    .font(.system(size: 54, weight: .light, design: .rounded))
                    .foregroundStyle(item.manager.status == .idle ? .secondary : .primary)

                configuredDurationText
                    .foregroundStyle(.secondary)
            }

            Spacer()
            primaryButton
        }
        .padding(.vertical, 10)
    }

    // If idle, show the preset (totalTime). If running/paused, show remainingTime.
    private var mainTimeText: Text {
        let durationToShow: Duration = (item.manager.status == .idle)
            ? item.manager.totalTime
            : item.manager.remainingTime

        return Text(durationToShow, format: .time(pattern: timePattern(for: durationToShow)))
            .monospacedDigit()
    }

    private var configuredDurationText: Text {
        Text(
            item.configuredDuration,
            format: .units(allowed: [.hours, .minutes, .seconds], width: .wide)
        )
    }

    private func timePattern(for duration: Duration) -> Duration.TimeFormatStyle.Pattern {
        let seconds = Int(duration.components.seconds)
        return seconds >= 3600 ? .hourMinuteSecond : .minuteSecond
    }

    private var primaryButtonIcon: String {
        switch item.manager.status {
        case .idle: return "play.fill"
        case .running: return "pause.fill"
        case .paused: return "play.fill"
        }
    }

    private var primaryButtonTint: Color {
        switch item.manager.status {
        case .idle: return .green
        case .running: return .orange
        case .paused: return .green
        }
    }

    private var primaryButton: some View {
        Button(action: onPrimaryAction) {
            Image(systemName: primaryButtonIcon)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 56, height: 56)
                .foregroundStyle(primaryButtonTint)
                .background(Circle().fill(primaryButtonTint.opacity(0.22)))
        }
        .buttonStyle(.plain)
    }
}
