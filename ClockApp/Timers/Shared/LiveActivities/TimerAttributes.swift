//
//  TimerAttributes.swift
//  ClockApp
//
//  Created by Pedro Rojas on 03/03/26.
//


import ActivityKit

struct TimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var remainingTime: Duration
        var totalTime: Duration
        var isPaused: Bool
        
        var progress: Double {
            guard totalTime > .seconds(0) else { return 0 }
            let totalSeconds = Double(totalTime.components.seconds)
            let remainingSeconds = Double(remainingTime.components.seconds)
            
            return (totalSeconds - remainingSeconds) / totalSeconds
        }
    }

    // Fixed non-changing properties about your activity go here!
    var title: String
}