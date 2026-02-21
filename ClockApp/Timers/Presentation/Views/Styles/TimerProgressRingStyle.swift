//
//  TimerProgressRingStyle.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/02/26.
//


import SwiftUI

struct TimerProgressRingStyle: Equatable {
    var size: CGFloat
    var lineWidth: CGFloat
    var tint: Color
    var track: Color

    init(
        size: CGFloat,
        lineWidth: CGFloat,
        tint: Color = .orange,
        track: Color = .secondary.opacity(0.18)
    ) {
        self.size = size
        self.lineWidth = lineWidth
        self.tint = tint
        self.track = track
    }
}

// MARK: - Presets (no parameters)

extension TimerProgressRingStyle {
    static let detail = TimerProgressRingStyle(
        size: ClockTimerStyle.ringSize,
        lineWidth: 10,
        tint: .orange,
        track: .secondary.opacity(0.18)
    )

    static let row: TimerProgressRingStyle = {
        let buttonSize: CGFloat = 56
        let ringPadding: CGFloat = 6
        let ringLineWidth: CGFloat = 4
        let ringSize = buttonSize + (ringPadding * 2)

        return TimerProgressRingStyle(
            size: ringSize,
            lineWidth: ringLineWidth,
            tint: .orange,
            track: .secondary.opacity(0.18)
        )
    }()
}
