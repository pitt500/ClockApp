//
//  NoopTimerActivityHandler.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//

struct NoopTimerActivityHandler: TimerActivityHandling {
    func start(for manager: TimerManager, title: String) {}
    func update(for manager: TimerManager, relevanceScore: Double?) {}
    func showAlert(title: String, soundName: String?) {}
    func end() {}
}
