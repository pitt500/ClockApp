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

            ZStack {
                Circle()
                    .stroke(.secondary.opacity(0.18), lineWidth: lineWidth)

                TimelineView(.animation) { context in
                    Circle()
                        .trim(from: 0, to: provider.progress(at: context.date))
                        .stroke(
                            .orange,
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }

                remainingTimeText
                    .font(.system(size: 84, weight: .light, design: .rounded))
                    .monospacedDigit()
            }
            .frame(width: ClockTimerStyle.ringSize, height: ClockTimerStyle.ringSize)

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


#Preview("Timer Detail - Running") {
    NavigationStack {
        TimerDetailView(
            provider: PreviewTimerDetailProvider.running,
            onCancel: {}
        )
        .preferredColorScheme(.dark)
    }
}

#Preview("Timer Detail - Paused") {
    NavigationStack {
        TimerDetailView(
            provider: PreviewTimerDetailProvider.paused,
            onCancel: {}
        )
        .preferredColorScheme(.dark)
    }
}

#Preview("Timer Detail - Idle") {
    NavigationStack {
        TimerDetailView(
            provider: PreviewTimerDetailProvider.idle,
            onCancel: {}
        )
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview Provider

private struct PreviewTimerDetailProvider: TimerDetailProviding {
    let configuredDuration: Duration
    let remainingDuration: Duration
    let actionTitle: String
    let actionTint: Color
    let progressValue: Double

    static let running = PreviewTimerDetailProvider(
        configuredDuration: .seconds(80),
        remainingDuration: .seconds(69),
        actionTitle: "Pause",
        actionTint: Color(uiColor: .systemOrange),
        progressValue: 0.86
    )

    static let paused = PreviewTimerDetailProvider(
        configuredDuration: .seconds(80),
        remainingDuration: .seconds(69),
        actionTitle: "Resume",
        actionTint: Color(uiColor: .systemGreen),
        progressValue: 0.86
    )

    static let idle = PreviewTimerDetailProvider(
        configuredDuration: .seconds(80),
        remainingDuration: .seconds(80),
        actionTitle: "Start",
        actionTint: Color(uiColor: .systemGreen),
        progressValue: 1.0
    )

    func progress(at date: Date) -> Double {
        progressValue
    }

    func primaryAction() { }

    func cancel() { }
}
