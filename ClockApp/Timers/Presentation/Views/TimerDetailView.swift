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

            TimerProgressRing(
                style: .detail,
                progress: provider.progress(at:)
            ) {
                remainingTimeText
                    .font(.system(size: 84, weight: .light, design: .rounded))
                    .monospacedDigit()
            }

            HStack {
                circleActionButton(
                    title: "Cancel",
                    fill: ClockTimerStyle.cancelFill,
                    foreground: ClockTimerStyle.cancelForeground
                ) {
                    onCancel()
                    dismiss()
                }

                Spacer()

                circleActionButton(
                    title: provider.actionTitle,
                    fill: ClockTimerStyle.primaryFill(
                        tint: provider.actionTint
                    ),
                    foreground: ClockTimerStyle.primaryForeground(
                        tint: provider.actionTint
                    )
                ) {
                    provider.primaryAction()
                }
            }
            .padding(.horizontal, ClockTimerStyle.horizontalPadding)

            Spacer()
        }
        .padding(.top, ClockTimerStyle.topPadding)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: provider.progress(at: Date.now)) { _, newValue in
            if newValue == 0 {
                dismiss()
            }
        }
    }

    private func circleActionButton(
        title: String,
        fill: Color,
        foreground: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(
                    .system(
                        size: ClockTimerStyle.actionButtonFontSize,
                        weight: .regular
                    )
                )
                .foregroundStyle(foreground)
                .frame(
                    width: ClockTimerStyle.actionButtonSize,
                    height: ClockTimerStyle.actionButtonSize
                )
                .background(Circle().fill(fill))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
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
