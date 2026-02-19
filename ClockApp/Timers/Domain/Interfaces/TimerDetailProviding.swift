//
//  TimerDetailProviding.swift
//  ClockApp
//
//  Created by Pedro Rojas on 01/02/26.
//


import SwiftUI

protocol TimerDetailProviding: TimerProgressProviding {
    var configuredDuration: Duration { get }
    var remainingDuration: Duration { get }

    var actionTitle: String { get }
    var actionTint: Color { get }

    func primaryAction()
}


