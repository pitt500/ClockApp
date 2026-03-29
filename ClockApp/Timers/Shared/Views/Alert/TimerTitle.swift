//
//  BigTimerTitle.swift
//  ClockApp
//
//  Created by Pedro Rojas on 28/03/26.
//


import SwiftUI

struct BigTimerTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.body.scaled(by: 1.8).bold())
            .foregroundStyle(.orange)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
        
    }
}
