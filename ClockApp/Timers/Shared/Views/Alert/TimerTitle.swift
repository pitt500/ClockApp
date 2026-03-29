//
//  BigTimerTitle.swift
//  ClockApp
//
//  Created by Pedro Rojas on 28/03/26.
//


import SwiftUI

struct BigTimerTitle: View {
    let title: String
    @ScaledMetric(relativeTo: .body) private var titleSize: CGFloat = 30.6

    var body: some View {
        Text(title)
            .font(.system(size: titleSize, weight: .bold))
            .foregroundStyle(.orange)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
        
    }
}

#Preview {
    BigTimerTitle(title: "Timer")
}