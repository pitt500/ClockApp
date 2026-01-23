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
                if let focused = store.focusedTimer {
                    Section {
                        NavigationLink {
                            TimerDetailView(item: focused)
                        } label: {
                            TimerRowView(item: focused, trailingAction: .pauseResume)
                        }
                    }
                } else {
                    Section {
                        PickerHeaderView(draft: $store.draft) {
                            store.startFromDraft()
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }

                if !store.recents.isEmpty {
                    Section("Recents") {
                        ForEach(store.recents) { item in
                            NavigationLink {
                                TimerDetailView(item: item)
                            } label: {
                                TimerRowView(item: item, trailingAction: .startPreset)
                            }
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
                        store.draft = .init(hours: 0, minutes: 0, seconds: 20)
                        store.startFromDraft()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
