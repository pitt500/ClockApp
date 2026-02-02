//
//  TimerDetailView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 23/01/26.
//


import SwiftUI

struct TimerDetailView<Provider: TimerDetailProviding>: View {
    let provider: Provider
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss

    private let lineWidth: CGFloat = 10

    var body: some View {
        VStack(spacing: 22) {
            configuredDurationText

            TimelineView(.animation) { context in
                let progress = provider.progress(at: context.date)

                ZStack {
                    Circle()
                        .stroke(.secondary.opacity(0.18), lineWidth: lineWidth)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            .orange,
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .scaleEffect(x: 1, y: 1)

                    remainingTimeText
                        .font(.system(size: 84, weight: .light, design: .rounded))
                        .monospacedDigit()
                }
                .frame(width: 320, height: 320)
            }

            HStack {
                Button("Cancel") {
                    provider.cancel()
                    onCancel()
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.gray)

                Spacer()

                Button(provider.actionTitle) {
                    provider.primaryAction()
                }
                .buttonStyle(.borderedProminent)
                .tint(provider.actionTint)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding(.top, 24)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var configuredDurationText: Text {
        Text(
            provider.configuredDuration,
            format: .units(allowed: [.hours, .minutes, .seconds], width: .wide)
        )
        .foregroundStyle(.secondary)
    }

    private var remainingTimeText: Text {
        Text(provider.remainingDuration, format: .time(pattern: timePattern))
    }

    private var timePattern: Duration.TimeFormatStyle.Pattern {
        let seconds = Int(provider.configuredDuration.components.seconds)
        return seconds >= 3600 ? .hourMinuteSecond : .minuteSecond
    }
}


#Preview {
    @Previewable @State var provider = TimerDetailProviderFromManager(
        item: TimerItem(
            label: "Timer",
            configuredDuration: .seconds(10),
            manager: TimerManager()
        ),
        onStartRequested: {_ in }
    )

    return NavigationStack {
        TimerDetailView(provider: provider, onCancel: {})
    }
}
