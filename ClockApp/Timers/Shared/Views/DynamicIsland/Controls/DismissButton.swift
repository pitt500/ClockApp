//
//  DismissButton.swift
//  ClockApp
//
//  Created by Pedro Rojas on 28/03/26.
//

import SwiftUI
import AppIntents

struct DismissButton: View {
    var body: some View {
        Button(intent: DismissTimerAlertIntent()) {
            TimerControlButton(
                systemImage: "xmark",
                style: .secondary
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DismissButton()
}
