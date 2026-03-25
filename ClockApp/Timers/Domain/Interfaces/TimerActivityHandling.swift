//
//  TimerActivityHandling.swift
//  ClockApp
//
//  Created by Pedro Rojas on 20/01/26.
//


import SwiftUI

protocol TimerActivityHandling {
    func start(for manager: TimerManager, title: String)
    func update(for manager: TimerManager)
    func showAlert(title: String)
    func end()
}
