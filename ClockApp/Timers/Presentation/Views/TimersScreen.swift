//
//  TimersScreen.swift
//  ClockApp
//
//  Created by Pedro Rojas on 21/01/26.
//


import SwiftUI

struct TimersScreen: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var store = TimersStore()
    @State private var didLoadRecents = false
    @State private var isShowingWhenTimerEndsDialog = false
    @State private var selectedSound: TimerAlertSound = .default

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
        .sheet(isPresented: $isShowingWhenTimerEndsDialog) {
            TimerAlertSoundPickerView(selectedSound: $selectedSound)
        }
        .onChange(of: scenePhase) { _, newValue in
            guard newValue == .active else { return }
            store.dismissCurrentTimerAlert()
        }
    }

    // MARK: - Sections

    private var timerPickerSection: some View {
        Section {
            PickerHeaderView(draft: $store.draft) {
                store.startFromDraft(sound: selectedSound)
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
            isShowingWhenTimerEndsDialog = true
        } label: {
            HStack(spacing: 12) {
                Text("When Timer Ends")
                    .foregroundStyle(.primary)

                Spacer(minLength: 8)

                Text(selectedSound.title)
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
        Section {
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
        } header: {
            Text("Recents")
                .font(.title3.bold())
                .foregroundStyle(.primary)
                .headerProminence(.increased)
        }
    }
}

#Preview {
    TimersScreen()
        .preferredColorScheme(.dark)
}
