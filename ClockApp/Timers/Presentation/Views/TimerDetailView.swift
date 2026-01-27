//
//  TimerDetailView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 23/01/26.
//


import SwiftUI

struct TimerDetailView: View {
    let item: TimerItem
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 22) {
            configuredDurationText

            ZStack {
                Circle()
                    .stroke(.secondary.opacity(0.18), lineWidth: 14)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        .orange,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .scaleEffect(x: -1, y: 1)

                remainingTimeText
                    .font(.system(size: 84, weight: .light, design: .rounded))
                    .monospacedDigit()
            }
            .frame(width: 320, height: 320)

            HStack {
                Button("Cancel") {
                    onCancel()
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.gray)

                Spacer()

                Button(actionTitle) {
                    switch item.manager.status {
                    case .running:
                        item.manager.pause()
                    case .paused:
                        item.manager.resume()
                    case .idle:
                        // Restart from detail if desired.
                        item.manager.setTimer(totalTime: item.configuredDuration)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(item.manager.status == .paused ? .green : .orange)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding(.top, 24)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var configuredDurationText: Text {
        Text(
            item.configuredDuration,
            format: .units(allowed: [.hours, .minutes, .seconds], width: .wide)
        )
        .foregroundStyle(.secondary)
    }

    private var remainingTimeText: Text {
        Text(item.manager.remainingTime, format: .time(pattern: timePattern))
    }

    private var timePattern: Duration.TimeFormatStyle.Pattern {
        let seconds = Int(item.manager.totalTime.components.seconds)
        return seconds >= 3600 ? .hourMinuteSecond : .minuteSecond
    }

    private var progress: Double {
        let total = max(1, Double(item.manager.totalTime.components.seconds))
        let remaining = max(0, Double(item.manager.remainingTime.components.seconds))
        return remaining / total
    }

    private var actionTitle: String {
        switch item.manager.status {
        case .running: return "Pause"
        case .paused: return "Resume"
        case .idle: return "Start"
        }
    }
}
