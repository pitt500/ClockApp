//
//  TimersScreen.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//


import SwiftUI

struct TimersScreen: View {
    @State private var store = TimersStore()

    var body: some View {
        NavigationStack {
            List {

                // Picker should be visible whenever there are no active timers.
                if store.activeTimers.isEmpty {
                    Section {
                        PickerHeaderView(draft: $store.draft) {
                            store.startFromDraft()
                        }
                        .listRowInsets(.init())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                } else {
                    // Active timers section (all active timers are "focused")
                    Section {
                        ForEach(store.activeTimers) { item in
                            NavigationLink {
                                TimerDetailView(
                                    provider: TimerDetailProviderFromManager(
                                        item: item,
                                        onStartRequested: { item in
                                            store.activate(item)
                                        }
                                    ),
                                    onCancel: { store.cancel(item) }
                                )
                            } label: {
                                TimerRowView(
                                    item: item,
                                    onPrimaryAction: { store.toggle(item) }
                                )
                            }
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(ClockTimerStyle.separatorTint)
                        }
                        .onDelete { offsets in
                            store.deleteActiveTimers(at: offsets)
                        }
                    }
                }

                if !store.recentTimers.isEmpty {
                    Section("Recents") {
                        ForEach(store.recentTimers) { item in
                            NavigationLink {
                                TimerDetailView(
                                    provider: TimerDetailProviderFromManager(
                                        item: item,
                                        onStartRequested: { item in
                                            store.activate(item)
                                        }
                                    ),
                                    onCancel: { store.cancel(item) }
                                )
                            } label: {
                                TimerRowView(
                                    item: item,
                                    onPrimaryAction: { store.toggle(item) }
                                )
                            }
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(ClockTimerStyle.separatorTint)
                        }
                        .onDelete { offsets in
                            store.deleteRecentTimers(at: offsets)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Timers")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
        }
    }
}


#Preview {
    TimersScreen()
        .preferredColorScheme(.dark)
}
