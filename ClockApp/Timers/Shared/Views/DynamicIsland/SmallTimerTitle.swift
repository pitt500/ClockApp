//
//  SmallTimerTitle.swift
//  ClockApp
//
//  Created by Pedro Rojas on 28/03/26.
//

import SwiftUI

struct SmallTimerTitle: View {
    let title: String
    @ScaledMetric(relativeTo: .body) private var titleSize: CGFloat = 20
    
    var body: some View {
        Text(title)
            .font(.system(size: titleSize))
            .foregroundStyle(.orange)
            .lineLimit(1)
    }
}

#Preview {
    SmallTimerTitle(title: "Demo")
}
