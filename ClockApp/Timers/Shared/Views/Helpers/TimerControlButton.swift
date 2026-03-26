//
//  TimerControlButton.swift
//  ClockApp
//
//  Created by Pedro Rojas on 03/03/26.
//


import SwiftUI

struct TimerControlButton: View {
    enum Style {
        case primary   // orange
        case secondary // gray
    }

    let systemImage: String
    let style: Style

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)

            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: 50, height: 50)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color.orange.opacity(0.9)
        case .secondary:
            return Color(.systemGray3)
        }
    }
}

#Preview {
    HStack {
        TimerControlButton(
            systemImage: "pause.fill",
            style: .primary
        )
        TimerControlButton(
            systemImage: "xmark",
            style: .secondary
        )
    }
}
