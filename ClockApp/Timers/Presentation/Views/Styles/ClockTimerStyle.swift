//
//  ClockTimerStyle.swift
//  ClockApp
//
//  Created by Pedro Rojas on 13/02/26.
//


import SwiftUI

enum ClockTimerStyle {

    // MARK: - Sizes

    static let ringLineWidth: CGFloat = 10
    static let ringSize: CGFloat = 320

    static let actionButtonSize: CGFloat = 92
    static let actionButtonFontSize: CGFloat = 20

    static let horizontalPadding: CGFloat = 24
    static let topPadding: CGFloat = 24

    // MARK: - Colors

    // Matches the Clock look in dark mode: filled circle with tint at low opacity.
    static let actionFillOpacity: Double = 0.20

    // Matches the Clock cancel button (subtle gray fill).
    static let cancelFillOpacity: Double = 0.22

    static var cancelFill: Color { Color.white.opacity(cancelFillOpacity) }
    static var cancelForeground: Color { .white }

    static func primaryFill(tint: Color) -> Color { tint.opacity(actionFillOpacity) }
    static func primaryForeground(tint: Color) -> Color { tint }

    // Optional: separators for Timers list
    static var separatorTint: Color { Color.white.opacity(0.14) }
}
