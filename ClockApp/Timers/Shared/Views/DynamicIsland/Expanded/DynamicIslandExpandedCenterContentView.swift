//
//  DynamicIslandExpandedCenterContentView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 26/03/26.
//

import SwiftUI

struct DynamicIslandExpandedCenterContentView: View {
    let state: TimerAttributes.ContentState
    let title: String

    var body: some View {
        if !isAlerting {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.orange)
                .lineLimit(1)
        }
    }

    private var isAlerting: Bool {
        state.presentationMode == .alerting
    }
}
