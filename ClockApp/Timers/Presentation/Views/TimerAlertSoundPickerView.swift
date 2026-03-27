//
//  TimerAlertSoundPickerView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 27/03/26.
//

import SwiftUI

struct TimerAlertSoundPickerView: View {
    @Binding var selectedSoundName: String?
    @Environment(\.dismiss) private var dismiss

    private let sounds: [(title: String, soundName: String?)] = [
        ("Default", nil),
        ("Alarm Pitt", "alarm_pitt.caf")
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(sounds, id: \.title) { sound in
                    Button {
                        selectedSoundName = sound.soundName
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            if isSelected(sound) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.orange)
                            } else {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.clear)
                            }

                            Text(sound.title)
                                .foregroundStyle(.primary)
                            
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("When Timer Ends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func isSelected(_ sound: (title: String, soundName: String?)) -> Bool {
        selectedSoundName == sound.soundName
    }
}
