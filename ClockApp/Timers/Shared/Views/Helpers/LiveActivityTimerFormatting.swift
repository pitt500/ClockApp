//
//  LiveActivityTimerFormatting.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/03/26.
//


//
//  LiveActivityTimerFormatting.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/03/26.
//

import Foundation

enum LiveActivityTimerFormatting {
    static func formattedDisplayTime(_ duration: Duration) -> String {
        let seconds = max(0, Int(duration.components.seconds))

        if seconds < 3600 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60

            return [minutes, remainingSeconds]
                .map { value in
                    value.formatted(.number.precision(.integerLength(2)))
                }
                .joined(separator: ":")
        } else {
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            let remainingSeconds = seconds % 60

            return [hours, minutes, remainingSeconds]
                .map { value in
                    value.formatted(.number.precision(.integerLength(2)))
                }
                .joined(separator: ":")
        }
    }
}