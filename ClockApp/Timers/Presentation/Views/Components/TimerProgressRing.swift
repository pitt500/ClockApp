//
//  TimerProgressRing.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/02/26.
//


import SwiftUI

struct TimerProgressRing<Center: View>: View {
    let size: CGFloat
    let lineWidth: CGFloat
    let tint: Color
    let track: Color
    let progress: (Date) -> Double
    @ViewBuilder let center: () -> Center

    init(
        size: CGFloat,
        lineWidth: CGFloat,
        tint: Color = .orange,
        track: Color = .secondary.opacity(0.18),
        progress: @escaping (Date) -> Double,
        @ViewBuilder center: @escaping () -> Center
    ) {
        self.size = size
        self.lineWidth = lineWidth
        self.tint = tint
        self.track = track
        self.progress = progress
        self.center = center
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(track, lineWidth: lineWidth)

            TimelineView(.animation) { context in
                Circle()
                    .trim(from: 0, to: clamped(progress(context.date)))
                    .stroke(
                        tint,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }

            center()
        }
        .frame(width: size, height: size)
    }

    private func clamped(_ value: Double) -> Double {
        min(1, max(0, value))
    }
}

extension TimerProgressRing where Center == EmptyView {
    init(
        size: CGFloat,
        lineWidth: CGFloat,
        tint: Color = .orange,
        track: Color = .secondary.opacity(0.18),
        progress: @escaping (Date) -> Double
    ) {
        self.init(
            size: size,
            lineWidth: lineWidth,
            tint: tint,
            track: track,
            progress: progress
        ) {
            EmptyView()
        }
    }
}
