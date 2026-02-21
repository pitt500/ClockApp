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
        track: Color = .secondary.opacity(ClockTimerStyle.ringTrackOpacity)
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
        lineWidth: ClockTimerStyle.ringLineWidth
    )

    static let row = TimerProgressRingStyle(
        size: ClockTimerStyle.rowRingSize,
        lineWidth: ClockTimerStyle.rowRingLineWidth
    )
}
