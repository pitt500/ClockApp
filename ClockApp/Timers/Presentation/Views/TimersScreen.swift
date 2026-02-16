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
                if store.activeTimers.isEmpty {
                    timerPickerSection
                    labelAndSoundSection
                } else {
                    activeSection
                }

                if !store.recentTimers.isEmpty {
                    recentsSection
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

    // MARK: - Sections

    private var timerPickerSection: some View {
        Section {
            PickerHeaderView(draft: $store.draft) {
                store.startFromDraft()
            }
            .listRowInsets(.init())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }

    private var labelAndSoundSection: some View {
        Section {
            HStack {
                Text("Label")
                Spacer()
                TextField("Timer", text: $store.draft.label)
                    .multilineTextAlignment(.trailing)
            }

            HStack {
                Text("When Timer Ends")
                Spacer()
                Text("Radar")
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var activeSection: some View {
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

    private var recentsSection: some View {
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

#Preview {
    TimersScreen()
        .preferredColorScheme(.dark)
}
