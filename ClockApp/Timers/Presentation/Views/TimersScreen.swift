//
//  TimersScreen.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//


import SwiftUI

struct TimersScreen: View {
    @State private var store = TimersStore()
    @State private var didLoadRecents = false

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
        .task {
            guard !didLoadRecents else { return }
            await store.loadRecentTimers()
            didLoadRecents = true
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
            VStack(spacing: 0) {
                labelRow
                Divider()
                    .padding([.leading, .trailing], 16)
                whenTimerEndsRow
            }
            .background {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
            .listRowSeparator(.hidden)
        }
    }

    private var labelRow: some View {
        HStack(spacing: 12) {
            Text("Label")
                .foregroundStyle(.primary)

            Spacer(minLength: 8)

            TextField("Timer", text: $store.draft.label)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var whenTimerEndsRow: some View {
        Button {
            // Placeholder: no behavior yet
        } label: {
            HStack(spacing: 12) {
                Text("When Timer Ends")
                    .foregroundStyle(.primary)

                Spacer(minLength: 8)

                Text("Radar")
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
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
