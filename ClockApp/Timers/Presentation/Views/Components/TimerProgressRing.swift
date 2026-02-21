//
//  TimerProgressRing.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/02/26.
//


import SwiftUI

struct TimerProgressRing<Center: View>: View {
    let style: TimerProgressRingStyle
    let progress: (Date) -> Double
    @ViewBuilder let center: () -> Center

    init(
        style: TimerProgressRingStyle,
        progress: @escaping (Date) -> Double,
        @ViewBuilder center: @escaping () -> Center
    ) {
        self.style = style
        self.progress = progress
        self.center = center
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(style.track, lineWidth: style.lineWidth)

            TimelineView(.animation) { context in
                Circle()
                    .trim(from: 0, to: clamped(progress(context.date)))
                    .stroke(
                        style.tint,
                        style: StrokeStyle(lineWidth: style.lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }

            center()
        }
        .frame(width: style.size, height: style.size)
    }

    private func clamped(_ value: Double) -> Double {
        min(1, max(0, value))
    }
}

extension TimerProgressRing where Center == EmptyView {
    init(
        style: TimerProgressRingStyle,
        progress: @escaping (Date) -> Double
    ) {
        self.init(style: style, progress: progress) { EmptyView() }
    }
}
