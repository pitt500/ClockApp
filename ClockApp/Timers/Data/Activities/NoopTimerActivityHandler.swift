//
//  NoopTimerActivityHandler.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//


// No-op implementation used in Chapter 1 so we can keep the timer logic ready
// without introducing Live Activities yet.
struct NoopTimerActivityHandler: TimerActivityHandling {
    func start(for manager: TimerManager, title: String) {}
    func update(for manager: TimerManager) {}
    func showAlert(title: String) {}
    func end() {}
}
