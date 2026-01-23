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
                Section {
                    headerContent
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                if !store.timers.isEmpty {
                    Section("Recents") {
                        ForEach(store.timers) { item in
                            Button {
                                store.focus(item)
                            } label: {
                                TimerRowView(item: item, isFocused: item.id == store.focusedTimerID)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Timers")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Edit") {}
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        store.startQuick(seconds: 20)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var headerContent: some View {
        if store.hasRunningTimers, let focused = store.focusedTimer {
            RunningHeaderView(item: focused)
                .padding(.vertical, 12)
        } else {
            PickerHeaderView(draft: $store.draft) {
                store.startFromDraft()
            }
            .padding(.vertical, 12)
        }
    }
}
