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

    // TimerRow (primary button + progress ring)

    static let rowPrimaryButtonSize: CGFloat = 56
    static let rowPrimaryButtonIconSize: CGFloat = 18
    static let rowPrimaryButtonIconWeight: Font.Weight = .semibold

    static let rowRingLineWidth: CGFloat = 4
    static let rowRingPadding: CGFloat = 6

    static var rowRingSize: CGFloat {
        rowPrimaryButtonSize + (rowRingPadding * 2)
    }

    // MARK: - Colors

    static let actionFillOpacity: Double = 0.20
    static let cancelFillOpacity: Double = 0.22

    static let ringTrackOpacity: Double = 0.18

    // TimerRow idle primary button (green fill)
    static let rowIdleButtonFillOpacity: Double = 0.22

    static var cancelFill: Color { Color.white.opacity(cancelFillOpacity) }
    static var cancelForeground: Color { .white }

    static func primaryFill(tint: Color) -> Color { tint.opacity(actionFillOpacity) }
    static func primaryForeground(tint: Color) -> Color { tint }

    static func rowIdleButtonFill(tint: Color = .green) -> Color {
        tint.opacity(rowIdleButtonFillOpacity)
    }

    // Optional: separators for Timers list
    static var separatorTint: Color { Color.white.opacity(0.14) }
}
