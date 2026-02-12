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

    // Non-static constants (safe in generic types)
    private let ringSize: CGFloat = 320
    private let buttonSize: CGFloat = 92
    private let horizontalPadding: CGFloat = 24
    private let topPadding: CGFloat = 24
    private let buttonFontSize: CGFloat = 20
    private let cancelFillOpacity: Double = 0.22

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
            .frame(width: ringSize, height: ringSize)

            HStack {
                circleActionButton(
                    title: "Cancel",
                    fill: Color.white.opacity(cancelFillOpacity),
                    foreground: .white
                ) {
                    onCancel()
                    dismiss()
                }

                Spacer()

                circleActionButton(
                    title: provider.actionTitle,
                    fill: provider.actionTint.opacity(0.2),
                    foreground: provider.actionTint
                ) {
                    provider.primaryAction()
                }

            }
            .padding(.horizontal, horizontalPadding)

            Spacer()
        }
        .padding(.top, topPadding)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func circleActionButton(
        title: String,
        fill: Color,
        foreground: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: buttonFontSize, weight: .regular))
                .foregroundStyle(foreground)
                .frame(width: buttonSize, height: buttonSize)
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
