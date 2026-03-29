//
//  SmallTimerTitle.swift
//  ClockApp
//
//  Created by Pedro Rojas on 28/03/26.
//

import SwiftUI

struct SmallTimerTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.body.scaled(by: 1.2))
            .foregroundStyle(.orange)
            .lineLimit(1)
    }
}

#Preview {
    SmallTimerTitle(title: "Demo")
}
