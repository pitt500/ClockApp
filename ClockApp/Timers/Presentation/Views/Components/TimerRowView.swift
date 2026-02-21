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

    private let buttonSize: CGFloat = 56
    private let ringLineWidth: CGFloat = 4
    private let ringPadding: CGFloat = 6

    private var ringSize: CGFloat { buttonSize + (ringPadding * 2) }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                mainTimeText
                    .font(.system(size: 54, weight: .light, design: .rounded))
                    .foregroundStyle(item.manager.status == .idle ? .secondary : .primary)

                subtitleText
                    .foregroundStyle(.secondary)
            }

            Spacer()
            primaryButton
        }
        .padding(.vertical, 10)
    }

    private var subtitleText: Text {
        if item.label.isEmpty {
            configuredDurationText
        } else {
            Text(item.label)
        }
    }

    private var mainTimeText: Text {
        let durationToShow: Duration = (item.manager.status == .idle)
            ? item.manager.totalTimeInSeconds
            : item.manager.remainingTimeInSeconds

        return Text(
            durationToShow,
            format: .time(pattern: timePattern(for: durationToShow))
        )
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

    // MARK: - Button Styling

    private var isIdle: Bool {
        item.manager.status == .idle
    }

    private var iconName: String {
        switch item.manager.status {
        case .idle: return "play.fill"
        case .running: return "pause.fill"
        case .paused: return "play.fill"
        }
    }

    private var iconColor: Color {
        isIdle ? .green : .orange
    }

    private var primaryButton: some View {
        let progressProvider = TimerRowProgressProviderFromManager(item: item)

        return Button(action: onPrimaryAction) {
            ZStack {

                // Ring solo cuando no está idle
                if !isIdle {
                    TimerProgressRing(
                        size: ringSize,
                        lineWidth: ringLineWidth,
                        tint: .orange,
                        track: .secondary.opacity(0.18),
                        progress: progressProvider.progress(at:)
                    )
                }

                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: buttonSize, height: buttonSize)
                    .foregroundStyle(iconColor)
                    .background(
                        isIdle
                        ? Circle().fill(Color.green.opacity(0.22))
                        : nil
                    )
                    .contentShape(Circle())
            }
        }
        .buttonStyle(.plain)
    }
}
