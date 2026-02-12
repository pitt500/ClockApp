//
//  TimerDetailProviding.swift
//  ClockApp
//
//  Created by Pedro Rojas on 01/02/26.
//


import SwiftUI

protocol TimerDetailProviding {
    var configuredDuration: Duration { get }
    var remainingDuration: Duration { get }
    func progress(at date: Date) -> Double

    var actionTitle: String { get }
    var actionTint: Color { get }

    func primaryAction()
}


