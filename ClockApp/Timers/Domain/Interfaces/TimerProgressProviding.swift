//
//  TimerProgressProviding.swift
//  ClockApp
//
//  Created by Pedro Rojas on 19/02/26.
//


import Foundation

protocol TimerProgressProviding {
    func progress(at date: Date) -> Double
}
